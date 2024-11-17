defmodule UxExpressWeb.CounterLive do
  @moduledoc """
  LiveView module demonstrating LiveSvelte integration with a Counter component.

  This LiveView showcases:
  1. Server-Side Rendering (SSR):
     - The Svelte Counter component is rendered on the server first
     - Initial HTML includes the pre-rendered component

  2. Client-Side Hydration:
     - When the page loads, Svelte hydrates the component
     - The counter becomes interactive without a full page reload

  3. Real-time Updates:
     - State changes in LiveView are reflected in the Svelte component
     - The component maintains reactivity while staying in sync with the server
  """
  use UxExpressWeb, :live_view
  use LiveSvelte.Components

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end

  def handle_event("countChange", %{"count" => count}, socket) do
    {:noreply, assign(socket, count: count)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Counter Demo</h1>
      <.svelte
        name="Counter"
        props={%{count: @count}}
        ssr={false}
      />
      <div class="mt-4 text-gray-600">
        Server count: <%= @count %>
      </div>
    </div>
    """
  end
end
