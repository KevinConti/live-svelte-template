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

  def handle_event("countChange", %{"count" => count}, socket) when is_number(count) do
    {:noreply, assign(socket, count: count)}
  end

  def handle_event("countChange", %{"count" => count}, socket) do
    case Integer.parse(count) do
      {value, _} -> {:noreply, assign(socket, count: value)}
      :error -> {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <div class="max-w-md mx-auto bg-white rounded-xl shadow-lg p-8">
        <h1 class="text-3xl font-bold mb-6 text-center text-gray-800">Counter Demo</h1>

        <div class="flex justify-center mb-8">
          <.svelte
            name="Counter"
            props={%{count: @count}}
            ssr={true}
          />
        </div>

        <div class="text-center text-gray-600">
          <p class="text-sm">Server count: <span class="font-mono bg-gray-100 px-2 py-1 rounded">@count</span></p>
          <p class="text-xs mt-2 text-gray-500">Changes are synchronized with the server</p>
        </div>
      </div>
    </div>
    """
  end
end
