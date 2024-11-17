defmodule UxExpressWeb.Watchers.NodeWatcher do
  @moduledoc """
  Custom watcher for running Node.js build scripts.
  """
  use GenServer
  require Logger

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @impl true
  def init(_args) do
    # Get absolute paths
    node_path = System.find_executable("node") || "c:/Program Files/nodejs/node.exe"
    
    # Get the project root directory (where mix.exs is located)
    project_root = Path.join(File.cwd!(), "")
    build_path = Path.join([project_root, "assets", "build.js"])
    cd_path = Path.join([project_root, "assets"])

    Logger.info("Starting Node.js watcher with:")
    Logger.info("  node_path: #{node_path}")
    Logger.info("  build_path: #{build_path}")
    Logger.info("  cd_path: #{cd_path}")

    if not File.exists?(node_path) do
      Logger.error("Node.js executable not found at: #{node_path}")
      {:stop, :node_not_found}
    else
      if not File.exists?(build_path) do
        Logger.error("Build script not found at: #{build_path}")
        {:stop, :build_script_not_found}
      else
        port = Port.open({:spawn_executable, node_path},
          [:binary, :exit_status, {:args, [build_path, "--watch"]}, {:cd, cd_path}])
        {:ok, %{port: port}}
      end
    end
  end

  @impl true
  def handle_info({port, {:data, data}}, %{port: port} = state) do
    Logger.debug("[Node Watcher] #{data}")
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.warning("[Node Watcher] Node.js process exited with status #{status}")
    {:stop, :normal, state}
  end

  def handle_info(msg, state) do
    Logger.debug("[Node Watcher] Unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, %{port: port}) do
    Logger.info("[Node Watcher] Terminating with reason: #{inspect(reason)}")
    Port.close(port)
    :ok
  end
end
