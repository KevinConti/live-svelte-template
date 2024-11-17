defmodule UxExpressWeb.PageController do
  use UxExpressWeb, :controller
  require Logger

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  # Helper function to check module exports
  defp check_module_exports(module_path) do
    node_path = Application.get_env(:nodejs, :path)
    check_script = """
    try {
      const mod = require('#{module_path}');
      console.log('Module exports:', JSON.stringify({
        hasRender: typeof mod.render === 'function',
        exportedKeys: Object.keys(mod),
        renderType: typeof mod.render,
        moduleType: typeof mod
      }));
    } catch(e) {
      console.error('Module load error:', e.message);
      console.error('Module path:', '#{module_path}');
      console.error('Current directory:', process.cwd());
      console.error('__dirname:', __dirname);
    }
    """
    
    case System.cmd(node_path, ["-e", check_script], stderr_to_stdout: true) do
      {output, 0} -> 
        Logger.info("Module exports check: #{output}")
        {:ok, output}
      {error, _} -> 
        Logger.error("Module exports check failed: #{error}")
        {:error, error}
    end
  end

  def debug_ssr(conn, _params) do
    bundle_path = Application.get_env(:live_svelte, :server_bundle_path)
    assets_path = Application.get_env(:nodejs, :node_path)
    
    # Get NodeJS configuration and pool status
    nodejs_config = %{
      path: Application.get_env(:nodejs, :path),
      pool_size: Application.get_env(:nodejs, :pool_size),
      debug: Application.get_env(:nodejs, :debug),
      node_path: assets_path
    }
    
    # Enhanced bundle verification
    bundle_info = %{
      exists: File.exists?(bundle_path),
      size: if(File.exists?(bundle_path), do: File.stat!(bundle_path).size, else: 0),
      last_modified: if(File.exists?(bundle_path), do: File.stat!(bundle_path).mtime, else: nil),
      content_preview: if(File.exists?(bundle_path), do: File.read!(bundle_path) |> String.slice(0..200), else: nil)
    }
    
    Logger.info("Bundle info: #{inspect(bundle_info, pretty: true)}")
    
    # Check NodeJS pool status
    pool_status = :sys.get_status(NodeJS.Supervisor)
    Logger.info("NodeJS pool status: #{inspect(pool_status, pretty: true)}")
    
    # Try to render a component with detailed error handling
    ssr_result = try do
      # Use just "server" as the module name
      module_name = "server"
      Logger.info("Using module name: #{module_name}")
      
      # Check module exports before calling
      {:ok, exports_info} = check_module_exports(module_name)
      Logger.info("Module exports info: #{exports_info}")
      
      # Debug log the call parameters
      Logger.info("""
      Calling NodeJS.call with:
        module_name: #{inspect(module_name)}
        function: render
        args: #{inspect(["Counter", %{"count" => 0}, %{}])}
      """)
      
      # Call with just the module name
      case NodeJS.call(module_name, :render, ["Counter", %{"count" => 0}, %{}]) do
        {:ok, result} -> 
          Logger.info("SSR Success: #{inspect(result, pretty: true)}")
          result
        {:error, error} -> 
          Logger.error("SSR Error: #{inspect(error, pretty: true)}")
          %{error: inspect(error)}
      end
    rescue
      e -> 
        Logger.error("SSR Exception: #{inspect(e)}")
        Logger.error("Stacktrace: #{Exception.format_stacktrace(__STACKTRACE__)}")
        %{
          error: inspect(e),
          stack: Exception.format_stacktrace(__STACKTRACE__),
          module_path: bundle_path,
          bundle_info: bundle_info
        }
    end

    render(conn, :debug_ssr, 
      layout: false,
      bundle_path: bundle_path,
      bundle_exists: bundle_info.exists,
      bundle_size: bundle_info.size,
      nodejs_config: nodejs_config,
      ssr_result: ssr_result,
      bundle_info: bundle_info
    )
  end
end
