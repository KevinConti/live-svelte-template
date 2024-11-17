/**
 * Custom build script for Phoenix + LiveSvelte integration
 * 
 * This script handles building both client and server bundles for the application.
 * It replaces Phoenix's default esbuild configuration to support:
 * 1. Svelte component compilation
 * 2. Server-side rendering (SSR)
 * 3. Import glob patterns
 * 4. Development and production modes
 */

const path = require('path')
const esbuild = require('esbuild')
const sveltePlugin = require('esbuild-svelte')
const importGlobPlugin = require('esbuild-plugin-import-glob').default
const sveltePreprocess = require('svelte-preprocess')

// Parse command line arguments for build modes
const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

// Get absolute paths for better reliability
const assetsDir = __dirname
const outDir = path.join(assetsDir, '..', 'priv', 'static', 'assets')
const serverOutDir = path.join(outDir, 'server')

// Shared Svelte plugin configuration for both client and server builds
const sveltePluginConfig = {
    preprocess: sveltePreprocess(),
    compilerOptions: {
        dev: !deploy,
        hydratable: true,
        css: 'injected'  // Modern approach instead of deprecated boolean
    }
}

// Configuration for client-side build (browser bundle)
const optsClient = {
    entryPoints: [path.join(assetsDir, 'js', 'app.js')],
    bundle: true,
    target: 'es2017',
    outdir: outDir,
    logLevel: 'info',
    sourcemap: !deploy,
    minify: deploy,
    plugins: [
        importGlobPlugin(),
        sveltePlugin(sveltePluginConfig)
    ]
}

// Configuration for server-side build (NodeJS bundle for SSR)
const optsServer = {
    entryPoints: [path.join(assetsDir, 'js', 'server.js')],
    bundle: true,
    platform: 'node',
    target: 'node20',
    outdir: serverOutDir,
    logLevel: 'info',
    format: 'cjs',
    plugins: [
        importGlobPlugin(),
        sveltePlugin({
            ...sveltePluginConfig,
            compilerOptions: {
                ...sveltePluginConfig.compilerOptions,
                generate: 'ssr',
                hydratable: true
            }
        })
    ]
}

// Build both client and server bundles
async function build() {
    console.log('\n[Build] Starting build process...')
    
    try {
        // Build client bundle
        console.log('\n[Client] Building client bundle...')
        await esbuild.build(optsClient)
        console.log('[Client] Build completed: files written to disk')
        
        // Build server bundle
        console.log('\n[Server] Building SSR bundle...')
        await esbuild.build(optsServer)
        console.log('[Server] Build completed. Output files:')
        console.log(`  - priv/static/assets/server/server.js`)
        
        // Verify server bundle exists
        const fs = require('fs')
        const serverBundlePath = path.join(serverOutDir, 'server.js')
        if (fs.existsSync(serverBundlePath)) {
            const stats = fs.statSync(serverBundlePath)
            console.log(`[Server] Bundle verified at ${serverBundlePath} (${stats.size} bytes)`)
        } else {
            console.error('[Server] ERROR: Server bundle not found at', serverBundlePath)
            process.exit(1)
        }
    } catch (error) {
        console.error('\n[Build] Error during build:', error)
        process.exit(1)
    }
}

// Handle watch mode for development
if (watch) {
    // Start initial build then watch for changes
    build().then(() => {
        require('chokidar')
            .watch([
                path.join(assetsDir, 'js', '**/*.js'),
                path.join(assetsDir, 'js', '**/*.svelte'),
                path.join(assetsDir, 'css', '**/*.css')
            ], {
                interval: 0,
                ignoreInitial: true,
            })
            .on('all', (event, path) => {
                console.log(`File ${path} changed (${event})`)
                build().catch(error => {
                    console.error('Error rebuilding:', error)
                })
            })
        console.log('\n[Watch] Watching for changes...')
    })
} else {
    build().catch(() => process.exit(1))
}
