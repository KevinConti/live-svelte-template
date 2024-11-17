defmodule UxExpressWeb.SSR.NodeWrapper do
  @moduledoc """
  A wrapper around NodeJS.call that works around Windows-specific OTP port issues.
  """
  require Logger

  def call!(path, function, args, opts \\ []) do
    # Create a temporary file to store the arguments
    tmp_dir = System.tmp_dir!()
    tmp_file = Path.join(tmp_dir, "node_args_#{:erlang.unique_integer([:positive])}.json")
    wrapper_path = Path.join(tmp_dir, "node_wrapper_#{:erlang.unique_integer([:positive])}.js")
    
    # Write arguments to temp file
    args_json = Jason.encode!(%{
      path: path,
      function: function,
      args: args,
      opts: opts
    })
    File.write!(tmp_file, args_json)

    try do
      # Create a wrapper script that reads from the temp file
      wrapper_script = """
      const fs = require('fs');
      const args = JSON.parse(fs.readFileSync('#{String.replace(tmp_file, "\\", "/")}', 'utf8'));
      const module = require(args.path);
      const result = module[args.function](...args.args);
      console.log(JSON.stringify(result));
      """

      File.write!(wrapper_path, wrapper_script)

      # Run node with the wrapper script
      node_path = Application.get_env(:nodejs, :path)
      case System.cmd(node_path, [wrapper_path], stderr_to_stdout: true) do
        {output, 0} ->
          case Jason.decode(String.trim(output)) do
            {:ok, result} -> result
            {:error, error} ->
              Logger.error("Failed to decode NodeJS output: #{inspect(error)}")
              raise "Failed to decode NodeJS output: #{inspect(error)}"
          end
        {error, _} ->
          Logger.error("NodeJS execution failed: #{inspect(error)}")
          raise "NodeJS execution failed: #{inspect(error)}"
      end
    after
      # Clean up temp files
      File.rm(tmp_file)
      File.rm(wrapper_path)
    end
  end
end
