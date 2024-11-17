/*
 * Custom build script for Phoenix + LiveSvelte integration
 * 
 * This replaces Phoenix's default esbuild configuration because:
 * 1. Phoenix's default esbuild (via Elixir wrapper) doesn't support plugins
 * 2. LiveSvelte requires a more complex setup with esbuild plugins
 * 3. We use esbuild directly as a node_module instead of the Elixir package
 * 
 * LiveSvelte + LiveView Integration:
 * LiveSvelte enables seamless integration of Svelte components within Phoenix LiveView by:
 * 1. Server-Side Rendering (SSR):
 *    - LiveView calls LiveSvelte to render Svelte components on the server
 *    - Components are pre-rendered to HTML before sending to the client
 *    - Initial page load is fast and SEO-friendly
 * 
 * 2. Client-Side Hydration:
 *    - Browser receives pre-rendered HTML and JavaScript
 *    - Svelte "hydrates" the static HTML, making it interactive
 *    - Components maintain full reactivity after hydration
 * 
 * 3. Live Updates:
 *    - LiveView manages real-time updates via WebSocket
 *    - When server state changes, only affected components re-render
 *    - Svelte handles smooth DOM updates on the client side
 * 
 * Build Process Overview:
 * - Client Build (optsClient):
 *   - Handles the browser-side bundle (js/app.js)
 *   - Compiles Svelte components for client-side hydration
 *   - Outputs to priv/static/assets/app.js for browser consumption
 *   - Includes browser-specific optimizations and bundling
 * 
 * - Server Build (optsServer):
 *   - Handles server-side rendering (js/server.js)
 *   - Compiles Svelte components for SSR (Server-Side Rendering)
 *   - Outputs to priv/static/assets/server/server.js
 *   - Enables LiveSvelte to render components on the server before sending to client
 */

// Required build tools and plugins
const esbuild = require('esbuild')
const sveltePlugin = require('esbuild-svelte')
const importGlobPlugin = require('esbuild-plugin-import-glob').default
const sveltePreprocess = require('svelte-preprocess')

// Parse command line arguments for build modes
const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

// Shared Svelte plugin configuration for both client and server builds
const sveltePluginConfig = {
  preprocess: sveltePreprocess(),  // Enables preprocessing of Svelte components
  compilerOptions: {
    dev: !deploy,      // Development mode when not deploying
    hydratable: true,  // Enables client-side hydration of server-rendered components
    css: true          // Include component CSS in the build
  }
}

// Configuration for client-side build (browser bundle)
const optsClient = {
  entryPoints: ['js/app.js'],        // Main client entry point
  bundle: true,                      // Bundle all dependencies together
  target: 'es2017',                  // Target modern browsers
  outdir: '../priv/static/assets',   // Output directory for client assets
  logLevel: 'info',                  // Show detailed build information
  sourcemap: !deploy,                // Generate source maps in development
  minify: deploy,                    // Minify code in production
  plugins: [
    importGlobPlugin(),              // Allow glob imports (e.g., import * as x from './dir/*.js')
    sveltePlugin(sveltePluginConfig) // Use shared Svelte configuration
  ]
}

// Configuration for server-side build (NodeJS bundle for SSR)
const optsServer = {
  entryPoints: ['js/server.js'],           // Server entry point for SSR
  bundle: true,                            // Bundle dependencies
  platform: 'node',                        // Target NodeJS platform
  target: 'node20',                        // Target Node.js version for compatibility
  outdir: '../_build/dev/lib/nodejs/priv', // Output directory for server bundle
  logLevel: 'info',                        // Show detailed build information
  format: 'cjs',                           // Use CommonJS format for Node.js compatibility
  plugins: [
    importGlobPlugin(),
    sveltePlugin({
      ...sveltePluginConfig,               // Extend shared config
      compilerOptions: {
        ...sveltePluginConfig.compilerOptions,
        generate: 'ssr',                   // Generate SSR-compatible code
        hydratable: true                   // Enable hydration of server-rendered content
      }
    })
  ]
}

// Main build function with error handling
async function build() {
  try {
    // Build client-side bundle
    const clientResult = await esbuild.build(optsClient)
    console.log('Client build completed:', clientResult)

    // Build server-side bundle for SSR
    const serverResult = await esbuild.build(optsServer)
    console.log('Server build completed:', serverResult)

    if (watch) {
      console.log('Watching for changes...')
    }
  } catch (err) {
    console.error('Build failed:', err)
    process.exit(1)  // Exit with error code
  }
}

// Handle watch mode for development
if (watch) {
  // Start initial build then watch for changes
  build().then(() => {
    require('chokidar')
      .watch(['js/**/*.js', 'js/**/*.svelte', 'css/**/*.css'], {
        interval: 0,
        ignoreInitial: true,
      })
      .on('all', (event, path) => {
        console.log(`File ${path} changed (${event})`)
        build()  // Rebuild on any file change
      })
  })
} else {
  // Single build for production
  build()
}
