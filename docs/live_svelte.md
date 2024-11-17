# LiveSvelte Knowledge Base

## Core Technology Definition

LiveSvelte integrates Svelte with Phoenix LiveView for end-to-end reactivity:
- Combines Phoenix LiveView's server-side capabilities with Svelte's client-side reactivity
- Eliminates need for separate API layer
- Enables real-time updates through websockets
- Supports NPM ecosystem integration

## Implementation Patterns

### Server-Side Integration
```elixir
defmodule ExampleWeb.LiveExample do
  use ExampleWeb, :live_view
  use LiveSvelte.Components  # Required for component integration

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _values, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end
end
```

### Client-Side Component
```svelte
<script>
  export let count = 0  // Server-synced state
  let localCount = 0    // Client-only state
</script>

<button phx-click="increment">Server Count: {count}</button>
<button on:click={() => localCount += 1}>Local Count: {localCount}</button>
```

## Technical Architecture

### Build Pipeline
1. Server-side:
   - Phoenix LiveView handles routing and state
   - Node.js performs SSR for Svelte components
   - Websocket manages real-time updates

2. Client-side:
   - Svelte components hydrate on load
   - Client state managed by Svelte
   - DOM updates handled locally

### Data Flow
1. Initial Load:
   - Server renders HTML with Svelte components
   - Client receives pre-rendered content
   - Components hydrate for interactivity

2. Updates:
   - Server events use `phx-` prefix
   - Client events use Svelte syntax
   - State syncs automatically via websocket

## Advanced Features

### Live Navigation
```html
<!-- Push Navigate -->
<a href="/path" data-phx-link="redirect" data-phx-link-state="push">Redirect</a>

<!-- Push Patch -->
<a href="/path" data-phx-link="patch" data-phx-link-state="push">Patch</a>
```

### Server-Side Rendering (SSR)
1. Global Configuration:
```elixir
# config/config.exs
config :live_svelte,
  ssr: false  # Disable SSR globally
```

2. Component-Level:
```elixir
<.svelte name="Example" ssr={false} />
```

### Live JSON Optimization
```elixir
def render(assigns) do
  ~H"""
    <.svelte 
      name="Component" 
      live_json_props={%{prop: @json_prop}} 
      socket={@socket} 
    />
  """
end

def mount(_, _, socket) do
  {:ok, LiveJson.initialize("prop", large_json)}
end
```

### Struct Serialization
```elixir
# Basic struct
defmodule User do
  @derive Jason.Encoder
  defstruct name: "John", age: 27
end

# Selective fields
defmodule User do
  @derive {Jason.Encoder, only: [:name]}
  defstruct name: "John", age: 27
end

# Ecto schema
defmodule Planet do
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "planets" do
    field :name, :string
  end
end
```

## Security Considerations

### State Visibility
1. Client-Side Exposure:
   - All Svelte code visible to client
   - Conditional renders exposed in bundle
   - JSON data transmitted instead of HTML

2. Sensitive Data:
   - Avoid sending sensitive data in props
   - Use server-side conditions for sensitive content
   - Consider traditional LiveView for sensitive UIs

## Performance Optimizations

### JSON Transmission
1. Live JSON:
   - Sends diffs instead of full objects
   - Optimal for large, frequently changing data
   - Adds overhead for small objects

2. When to Use:
   - Large JSON objects: Use live_json
   - Small, simple data: Use regular props
   - Frequent updates: Consider live_json

### Navigation Performance
1. Store Persistence:
   - Svelte stores maintain state during navigation
   - Useful for client-side state management
   - No page refresh required

## Common Patterns

### Preprocessor Integration
```bash
# TypeScript setup
cd assets && npm install --save-dev typescript
```

### Experimental Features

#### Slot Support
- Experimental feature
- Works with SSR initial render
- Limited dynamic updates
- Use with caution in production

## Troubleshooting Guide

### SSR Issues
1. Blank Page Flash:
   - Enable SSR globally
   - Verify Node.js supervisor
   - Check component SSR setting

2. State Synchronization:
   - Verify JSON serialization
   - Check struct derivation
   - Validate live_json setup

### Navigation Problems
1. Store State Loss:
   - Use proper navigation links
   - Verify store initialization
   - Check navigation event handlers

## Configuration Reference

### Required Setup
```elixir
# Application supervision
children = [
  {NodeJS.Supervisor, []}  # Required for SSR
]

# Config
config :live_svelte,
  app_name: :your_app,
  build_path: "priv/static/svelte"
```

## Common Use Cases

### Recommended For
1. Real-time applications:
   - Chat systems
   - Live dashboards
   - Collaborative tools

2. Interactive UIs:
   - Complex forms
   - Dynamic visualizations
   - Games and animations

### Not Recommended For
1. Static content sites
2. Traditional CRUD applications
3. SEO-critical pages without SSR

## Limitations and Constraints

### Technical Limitations
1. Server-side:
   - No direct Elixir template access
   - Limited Phoenix component usage
   - Requires Node.js for SSR

2. Client-side:
   - Must use Svelte syntax
   - No direct LiveView hooks
   - Limited slot support

### Performance Considerations
1. Initial load:
   - SSR adds rendering time
   - Additional JS bundle size
   - Hydration overhead

2. Runtime:
   - Websocket connection required
   - State synchronization overhead
   - Memory usage for dual state

## Error Scenarios

### Common Issues
1. Component Loading:
   ```elixir
   # Incorrect
   <.svelte component="Counter" />
   
   # Correct
   <.svelte name="Counter" props={%{count: @count}} />
   ```

2. State Synchronization:
   ```svelte
   <!-- Incorrect -->
   <button on:click={() => count += 1}>
   
   <!-- Correct -->
   <button phx-click="increment">
   ```

### Error Prevention
1. Always export props in Svelte components
2. Use `phx-` prefix for server events
3. Ensure component names match exports
4. Verify build pipeline configuration

## Required Dependencies
```elixir
# mix.exs
{:live_svelte, "~> 0.14.0"}
{:nodejs, "~> 3.1"}
```

## Build Configuration
```javascript
// build.js
{
  entryPoints: ['js/app.js'],
  mainFields: ['svelte', 'browser', 'module', 'main'],
  plugins: [sveltePlugin({
    compilerOptions: { hydratable: true }
  })]
}