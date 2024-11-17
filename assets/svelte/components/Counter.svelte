<script>
  import { getContext } from 'svelte';
  
  /**
   * Counter component that demonstrates LiveSvelte integration
   * with bi-directional state synchronization between client and server.
   */
  
  // Props must be exported for SSR
  export let count = 0;
  
  // Get pushEvent from LiveSvelte context
  const { pushEvent } = getContext('live-svelte') || {};
  
  // Ensure pushEvent is available
  if (typeof window !== 'undefined' && !pushEvent) {
    console.error('LiveSvelte context not found. Make sure the component is mounted with LiveSvelte.');
  }
  
  // Log initialization in SSR context
  if (typeof window === 'undefined') {
    console.log('[Counter SSR] Initializing with count:', count);
  }
  
  // Local state for client-side reactivity
  let localCount = count;
  
  // Update local count when server prop changes
  $: {
    localCount = count;
    if (typeof window === 'undefined') {
      console.log('[Counter SSR] State updated:', { count, localCount });
    }
  }
  
  // Handle increment with client-side update
  function handleIncrement() {
    if (!pushEvent) return;
    localCount += 1;
    pushEvent("countChange", { count: localCount });
  }
  
  // Handle decrement with client-side update
  function handleDecrement() {
    if (!pushEvent) return;
    localCount -= 1;
    pushEvent("countChange", { count: localCount });
  }
</script>

<div class="counter flex items-center space-x-4">
  <button 
    class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors duration-200" 
    on:click={handleDecrement}
  >
    -
  </button>
  
  <div class="flex flex-col items-center">
    <span class="px-6 py-3 bg-gray-100 rounded-lg text-xl font-semibold">{localCount}</span>
    <span class="text-sm text-gray-500 mt-1">Click to update</span>
  </div>
  
  <button 
    class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors duration-200" 
    on:click={handleIncrement}
  >
    +
  </button>
</div>

<style>
  .counter {
    display: inline-flex;
    align-items: center;
  }
  
  button {
    min-width: 3rem;
    font-weight: bold;
  }
</style>
