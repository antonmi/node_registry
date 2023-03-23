defmodule NodeRegistry.Remote do
  @moduledoc """
    Defines remote/4 function to call a function on a remote node.
  """

  @spec remote(atom(), module(), atom(), list()) :: any() | no_return()
  def remote(name, mod, fun, args) do
    case NodeRegistry.random_node_with_prefix(name) do
      nil ->
        raise "No node with prefix #{name} found"

      node ->
        :rpc.call(node, mod, fun, args)
    end
  end
end
