defmodule UxExpressWeb.SSR.NodeJS do
  @moduledoc """
  Custom SSR implementation for UxExpress that handles NodeJS.call differently
  than LiveSvelte's default implementation.
  """
  @behaviour LiveSvelte.SSR
  require Logger

  def render(name, props, slots) do
    try do
      Logger.debug("SSR render called for component: #{name}, props: #{inspect(props)}")
      
      # Use the configured module format
      NodeJS.call!(
        Application.get_env(:nodejs, :module),
        [name, props, slots],
        binary: true,
        esm: Application.get_env(:nodejs, :module_format) == :esm
      )
    catch
      :exit, {:noproc, _} ->
        message = """
        NodeJS is not configured. Please add the following to your application.ex:
        {NodeJS.Supervisor, [path: LiveSvelte.SSR.NodeJS.server_path(), pool_size: 4]},
        """
        raise %LiveSvelte.SSR.NotConfigured{message: message}

      kind, error ->
        Logger.error("SSR Error - kind: #{inspect(kind)}, error: #{inspect(error)}")
        case error do
          :function_clause ->
            # Module not found or incorrect format
            message = """
            Failed to render component. Module not found or incorrect format.
            Make sure the server bundle is properly built and the NODE_PATH is correct.
            Component: #{name}
            Props: #{inspect(props)}
            """
            raise %LiveSvelte.SSR.NotConfigured{message: message}
          _ ->
            reraise error, __STACKTRACE__
        end
    end
  end

  def server_path do
    Application.get_env(:live_svelte, :server_bundle_path)
  end
end
