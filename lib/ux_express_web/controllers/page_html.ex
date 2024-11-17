defmodule UxExpressWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use UxExpressWeb, :html

  embed_templates "page_html/*"

  # Helper to format datetime tuples
  defp format_datetime(nil), do: "N/A"
  defp format_datetime({{year, month, day}, {hour, minute, second}}) do
    "#{year}-#{pad(month)}-#{pad(day)} #{pad(hour)}:#{pad(minute)}:#{pad(second)}"
  end

  # Helper to pad single digits with leading zero
  defp pad(number) when number < 10, do: "0#{number}"
  defp pad(number), do: "#{number}"

  def debug_ssr(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>SSR Debug Info</title>
        <style>
          body { font-family: system-ui; padding: 2rem; max-width: 80rem; margin: 0 auto; }
          pre { background: #f5f5f5; padding: 1rem; border-radius: 0.5rem; overflow-x: auto; }
          .section { margin-bottom: 2rem; }
          .error { color: #dc2626; }
          .success { color: #059669; }
          .info { color: #3b82f6; }
          .warning { color: #f59e0b; }
          details { margin: 1rem 0; }
          summary { cursor: pointer; padding: 0.5rem; background: #f3f4f6; border-radius: 0.25rem; }
        </style>
      </head>
      <body>
        <h1>SSR Debug Information</h1>

        <div class="section">
          <h2>Bundle Information</h2>
          <details open>
            <summary>Bundle Details</summary>
            <ul>
              <li>Path: <%= @bundle_path %></li>
              <li>Exists: <span class={if @bundle_exists, do: "success", else: "error"}><%= @bundle_exists %></span></li>
              <li>Size: <%= @bundle_size %> bytes</li>
              <li>Last Modified: <%= format_datetime(@bundle_info.last_modified) %></li>
            </ul>
            <details>
              <summary>Content Preview</summary>
              <pre><code><%= @bundle_info.content_preview %></code></pre>
            </details>
          </details>
        </div>

        <div class="section">
          <h2>NodeJS Configuration</h2>
          <details open>
            <summary>Configuration Details</summary>
            <pre><%= inspect(@nodejs_config, pretty: true) %></pre>
          </details>
        </div>

        <div class="section">
          <h2>SSR Result</h2>
          <details open>
            <summary>Result Details</summary>
            <pre class={if Map.has_key?(@ssr_result, :error), do: "error", else: "success"}>
              <%= inspect(@ssr_result, pretty: true) %>
            </pre>
          </details>
        </div>

        <div class="section">
          <h2>Test Component</h2>
          <%= if is_map(@ssr_result) and not is_nil(@ssr_result[:html]) do %>
            <details open>
              <summary>Rendered Component</summary>
              <h3>Rendered HTML:</h3>
              <div style="border: 1px solid #e5e7eb; padding: 1rem; border-radius: 0.5rem; margin-top: 1rem;">
                <%= raw(@ssr_result[:html]) %>
              </div>
            </details>
          <% end %>
        </div>
      </body>
    </html>
    """
  end
end
