# Key Considerations When Using LiveSvelte

## Security First
1. ⚠️ **Client-Side Exposure**
   - All Svelte code is visible to clients
   - Conditional renders are exposed in bundle
   - Never include sensitive logic in Svelte components

2. 🔒 **Data Protection**
   - Avoid sending sensitive data in props
   - Use server-side conditions for sensitive content
   - Consider traditional LiveView for sensitive UIs

## Performance Critical
1. 📦 **JSON Handling**
   - Use `live_json` for large, frequently changing objects
   - Use regular props for small, simple data
   - Be mindful of unnecessary state updates

2. 🔄 **State Management**
   - Always export props in Svelte components
   - Use `phx-` prefix for server events
   - Verify component names match exports

## Common Gotchas
1. 🚫 **Component Syntax**
   ```elixir
   # Always use this syntax
   <.svelte name="Counter" props={%{count: @count}} />
   
   # Never use this
   <.svelte component="Counter" />
   ```

2. 🔍 **Struct Serialization**
   ```elixir
   # Always derive Jason.Encoder
   @derive {Jason.Encoder, only: [:safe_fields]}
   ```

3. ⚡ **Event Handling**
   ```elixir
   # Server events
   <button phx-click="increment">
   
   # Local events
   <button on:click={() => localCount += 1}>
   ```

## Development Checklist
1. ✅ **Before Deployment**
   - Verify SSR configuration
   - Check JSON serialization
   - Test navigation state persistence
   - Validate build pipeline setup

2. 🔄 **During Development**
   - Keep server/client state separation clear
   - Use proper event delegation
   - Monitor JSON payload sizes
   - Test with SSR enabled/disabled

## Architecture Guidelines
1. 📋 **State Division**
   - Server: Complex business logic
   - Client: UI interactions only
   - Avoid duplicating state

2. 🎯 **Component Design**
   - Keep components focused
   - Minimize prop passing
   - Use stores for shared state
   - Consider SSR impact
