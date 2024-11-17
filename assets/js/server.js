// Server-side rendering entry point
const { Counter } = require('../svelte/components/Counter.svelte');

// Debug logging helper
function debugLog(...args) {
  console.log('[SSR Debug]', ...args);
}

// Error logging helper
function errorLog(...args) {
  console.error('[SSR Error]', ...args);
}

// Map of available components
const components = {
  Counter: Counter
};

// The render function that LiveSvelte calls
function render(componentName, props, options) {
  debugLog('render called with:', { componentName, props, options });
  
  try {
    const Component = components[componentName];
    if (!Component) {
      throw new Error(`Component ${componentName} not found. Available: ${Object.keys(components)}`);
    }
    
    debugLog('Found component:', Component);
    
    const result = Component.render(props);
    debugLog('Render result:', result);
    
    return {
      html: result.html,
      css: { code: result.css?.code || '', map: result.css?.map },
      head: result.head
    };
  } catch (error) {
    errorLog('Render error:', error);
    throw error;
  }
}

// Export for LiveSvelte SSR
module.exports = {
  render: render
};
