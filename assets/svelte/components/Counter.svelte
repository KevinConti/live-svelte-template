<script>
  // Props must be exported for SSR
  export let count = 0;
</script>

<div class="counter flex items-center space-x-2">
  <button 
    class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600" 
    phx-click="decrement"
  >
    -
  </button>
  
  <span class="px-4 py-2 bg-gray-100 rounded">{count}</span>
  
  <button 
    class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600" 
    phx-click="increment"
  >
    +
  </button>
</div>

<style>
  .counter {
    display: inline-flex;
    align-items: center;
  }
</style>
