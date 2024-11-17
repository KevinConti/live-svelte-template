/*
 * Server-side entry point for LiveSvelte components
 * 
 * This file is crucial for Server-Side Rendering (SSR) in LiveSvelte:
 * 1. It exports Svelte components that LiveView needs to render on the server
 * 2. LiveSvelte uses NodeJS to run this file and render components
 * 3. The rendered HTML is then sent to the client for hydration
 * 
 * Flow:
 * - LiveView template uses <.svelte> component
 * - LiveSvelte calls NodeJS to render the component using this file
 * - Rendered HTML is injected into the LiveView response
 * - Client receives pre-rendered HTML and hydrates it
 */

// Import Svelte components that need SSR
import Counter from '../svelte/components/Counter.svelte'

// Export components with their render function for SSR
// Note: Counter.default handles ES modules, Counter handles CommonJS
export default {
  Counter: Counter.default || Counter
};
