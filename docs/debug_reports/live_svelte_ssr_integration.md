# LiveSvelte SSR Integration Debug Report

## Current Problem
We're encountering issues with server-side rendering (SSR) in a Phoenix/LiveSvelte application. The core issue manifests as a `:badarg` error in `port_command` when attempting to communicate between Elixir and Node.js for SSR of Svelte components.

## Error Analysis
The error occurs in the NodeJS worker when trying to send commands to the Node.js process:
```elixir
{:badarg, [{:erlang, :port_command, [#Port<0.9>, "[[...]]"], [file: ~c"erlang.erl", line: 4713]}]}
```

## Failed Approaches

### 1. Windows-Specific OTP Port Workaround
**Hypothesis**: The issue was related to known Windows bugs in OTP 25/26 port handling.
**Implementation**: Created a custom wrapper using `System.cmd` instead of ports.
**Result**: Failed - The underlying issue wasn't with port communication itself.

### 2. Direct Path Resolution
**Hypothesis**: The module path resolution was incorrect.
**Implementation**: Tried using absolute paths to the server.js bundle.
**Result**: Failed - Led to module resolution errors and invalid tuple format.

### 3. Custom Module Name Format
**Hypothesis**: The NodeJS.Supervisor expected a different module name format.
**Implementation**: Modified the module name to be a single-element tuple.
**Result**: Failed - Didn't match the expected protocol between LiveSvelte and NodeJS.

## Current Approach
**Hypothesis**: LiveSvelte's original approach was correct, but the NODE_PATH configuration needs adjustment.

### Key Insights
1. The NodeJS worker sets up `NODE_PATH` to include the module directory
2. Module names should be relative to `NODE_PATH`
3. LiveSvelte's `{"server", "render"}` format matches the worker's protocol

### Current Implementation
```elixir
NodeJS.call!({"server", "render"}, [name, props, slots], binary: true)
```

### Next Steps
1. Verify the `NODE_PATH` configuration in the NodeJS worker
2. Ensure server.js is properly placed in the assets directory
3. Add detailed logging for module resolution attempts

## Questions to Investigate
1. Is the server.js bundle being generated in the correct location?
2. Does the Node.js process have the correct working directory?
3. Are the module paths in the bundle using the expected format?

## Current Status
We've reverted to LiveSvelte's original module name format but with enhanced error handling and logging. Awaiting test results to determine if this resolves the port communication issue.

## Environment Details
- Operating System: Windows
- Elixir Version: 1.15.7
- OTP Version: 26
- Phoenix Version: 1.7.14
- LiveSvelte Version: 0.14.0
- NodeJS Version: 20

## Relevant Code Locations
- `lib/ux_express_web/ssr/node_js.ex`: Custom SSR implementation
- `deps/live_svelte/lib/ssr/node_js.ex`: LiveSvelte's SSR implementation
- `deps/nodejs/lib/nodejs/worker.ex`: NodeJS worker implementation
- `assets/js/server.js`: Server-side rendering entry point

## Configuration
```elixir
# config/config.exs
config :live_svelte,
  app_name: :ux_express,
  build_path: "priv/static/svelte",
  server_bundle_path: Path.join(["priv", "static", "assets", "server", "server.js"])

config :nodejs,
  path: "c:/Program Files/nodejs/node.exe",
  pool_size: 4,
  node_path: [
    Path.join(["priv", "static", "assets", "server"]),
    Path.join(["priv", "static", "assets"])
  ]
```

## Related Issues
- [OTP Windows Port Issues](https://github.com/erlang/otp/issues/2797)
- [NodeJS Port Communication](https://github.com/phoenixframework/phoenix_live_view/issues/2219)

## Updates
*(Latest update at top)*

### 2024-02-17 (Update 12) - FINAL 
**Final Code Review and Documentation**
- Added comprehensive JSDoc documentation to all JavaScript files
- Improved error handling throughout the codebase
- Updated build script with better logging and error reporting
- Added null checks and safety guards in component code
- Marked debug investigation as complete

**Status: RESOLVED** 
- Server-side rendering is working correctly
- Client-side hydration is successful
- Event handling between Svelte and LiveView is functioning
- All components are properly documented and error-handled

### 2024-02-17 (Update 11)
**Context-Based Event Handling**
- Switched to LiveSvelte context for event handling
- Added `getContext('live-svelte')` in Counter component
- Removed global `window.pushEvent` in favor of context-based approach
- Updated hook to properly set up LiveSvelte context with `pushEvent`

### 2024-02-17 (Update 10)
**Event Handling Fix**
- Added `pushEvent` function to window context in Svelte hook
- Improved cleanup by removing `pushEvent` on component destruction
- Fixed event communication between Svelte and LiveView
- Rebuilt client assets with updated event handling

### 2024-02-17 (Update 9)
**Hook Registration Fix**
- Added `SvelteHook` alias to match LiveView's expected hook name
- Improved component instance management in hooks.js
- Enhanced error handling for component initialization
- Rebuilt client assets with updated hook configuration

### 2024-02-17 (Update 8)
**Build Script Fixes**
- Fixed build script paths using Node.js `path` module
- Updated to use absolute paths for better reliability
- Successfully rebuilt server bundle (22.3kb)
- Next step: Test SSR with newly built bundle

### 2024-02-17 (Update 7)
**Build Configuration Investigation**
- Found server bundle build configuration in `assets/build.js`
- Confirmed it's set to use CommonJS format: `format: 'cjs'`
- Added better error handling for module resolution failures
- Next step: Rebuild server bundle to ensure correct format

### 2024-02-17 (Update 6)
**Module Format Configuration**
- Found that the server bundle uses ESM internally but exports via CommonJS
- Updated NodeJS configuration to explicitly handle module format:
  ```elixir
  config :nodejs,
    module: {"server", "render"},
    module_format: :cjs
  ```
- Modified SSR module to use configured format and module name
- Next step: Test if explicit module format resolves port communication issue

### 2024-02-17 (Update 5)
**NODE_PATH Configuration Update**
- Updated NodeJS configuration to include both server and assets directories:
  ```elixir
  config :nodejs,
    node_path: [
      Path.join(["priv", "static", "assets", "server"]),
      Path.join(["priv", "static", "assets"])
    ]
  ```
- This should help Node.js find the server module when LiveSvelte calls `{"server", "render"}`
- Next step: Test if module resolution works with updated paths

### 2024-02-17 (Update 4)
**Bundle Location Investigation**
- Found multiple versions of server.js in `priv/static/assets/server/`:
  - `server.js` (22,474 bytes)
  - `server-0dd2ab1a5fa1a48fb059202c20e4d08b.js` (14,792 bytes)
  - `server-5fc64d8ce345be6d7b5f585f2a95d734.js` (15,220 bytes)
- The bundle is being generated and copied correctly
- However, NodeJS is failing to find the module with just `"server"`
- Next step: Modify NODE_PATH to include the full path to server directory

### 2024-02-17 (Update 3)
**Server Bundle Investigation**
- Examined `assets/js/server.js`
- Found it's using CommonJS (CJS) format correctly:
  - Uses `require()` for imports
  - Uses `module.exports` for exports
- The bundle structure matches what `requireModule` expects
- However, the error suggests the module isn't being found
- Next step: Verify the bundle is being copied to the correct location in `priv/static/assets/server/`

### 2024-02-17 (Update 2)
**NodeJS Module Resolution Investigation**
- Examined `deps/nodejs/priv/server.js` which handles module loading
- Found that module resolution happens in two ways:
  1. `requireModule`: Standard Node.js require (used for CJS)
  2. `importModuleRespectingNodePath`: Custom resolution for ESM
- The worker tries to resolve modules relative to each path in `NODE_PATH`
- For our case, using `{"server", "render"}`, it's using `requireModule`
- Next step: Check if our server.js bundle is in the correct format (CJS vs ESM)

### 2024-02-17 (Update 1)
- Reverted to LiveSvelte's original module name format
- Added enhanced error logging
- Investigating NODE_PATH configuration
