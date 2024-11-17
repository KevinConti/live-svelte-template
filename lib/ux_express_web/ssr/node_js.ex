defmodule UxExpressWeb.SSR.NodeJS do
  @moduledoc """
  SSR implementation for UxExpress using LiveSvelte's NodeJS integration.
  """
  @behaviour LiveSvelte.SSR
  require Logger

  def render(name, props, slots) do
    try do
      NodeJS.call!("server.js", [name, props, slots], binary: true)
    catch
      :exit, {:noproc, _} ->
        message = """
        NodeJS is not configured. Please add the following to your application.ex:
        {NodeJS.Supervisor, [path: LiveSvelte.SSR.NodeJS.server_path(), pool_size: 4]},
        """
        raise %LiveSvelte.SSR.NotConfigured{message: message}
    end
  end

  def server_path do
    Application.get_env(:live_svelte, :server_bundle_path)
  end
end
