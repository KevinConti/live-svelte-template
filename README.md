# LiveSvelte Template

A powerful template for building modern web applications with Phoenix LiveView and Svelte components. This template demonstrates the seamless integration of server-side rendering (SSR) and client-side interactivity using LiveSvelte.

## Features

- **Phoenix LiveView** - Real-time server-rendered pages
- **Svelte Components** - Reactive UI components with SSR support
- **LiveSvelte Integration** - Seamless Phoenix-Svelte interop
- **Server-Side Rendering** - Enhanced performance and SEO
- **TailwindCSS** - Utility-first CSS framework
- **Modern Build System** - Optimized esbuild configuration

## Quick Start

### Prerequisites

- Elixir 1.14 or later
- Node.js 20.10.0 or later
- Phoenix 1.7

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/KevinConti/live-svelte-template.git
   cd live-svelte-template
   ```

2. Install dependencies:
   ```bash
   mix setup
   ```

3. Start the development server:
   ```bash
   mix phx.server
   ```

Visit [`localhost:4000`](http://localhost:4000) to see your app in action!

## Project Structure

```
.
├── assets/                  # Frontend assets
│   ├── build.js            # esbuild configuration
│   ├── js/                 # JavaScript files
│   └── svelte/             # Svelte components
├── lib/                    # Phoenix application code
│   ├── ux_express/         # Business logic
│   └── ux_express_web/     # Web-related code
└── docs/                   # Documentation
    ├── key_considerations.md
    └── live_svelte.md
```

## Example Components

### Counter Component

The template includes a Counter component demonstrating:
- Server-side state management
- Client-side reactivity
- Event handling between LiveView and Svelte
- SSR configuration

Check out `lib/ux_express_web/live/counter_live.ex` and `assets/svelte/components/Counter.svelte`.

## Build Configuration

The template includes a robust build configuration (`assets/build.js`) that handles:
- Client-side bundling
- Server-side rendering
- Development and production modes
- Source maps and minification

## Documentation

For more detailed information, check out:
- [Key Considerations](docs/key_considerations.md)
- [LiveSvelte Integration](docs/live_svelte.md)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
- [Svelte](https://svelte.dev/)
- [LiveSvelte](https://github.com/woutdp/live_svelte)
