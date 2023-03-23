defmodule NodeRegistry do
  @moduledoc """
    A simple registry for nodes.
    It uses the Erlang :global module. https://www.erlang.org/doc/man/global.html
    One must start the registry on each node:
    Add {NodeRegistry, :my_service} to the supervisor's children list.
  """
  use GenServer

  defstruct [:node, :name, :pid]

  @type t :: %__MODULE__{node: node, name: atom, pid: pid}

  @lookup_prefix :node_registry

  @spec start_link(atom()) :: GenServer.on_start()
  def start_link(name) when is_atom(name) do
    name = :"#{name}_#{Node.self()}"
    GenServer.start_link(__MODULE__, name, name: __MODULE__)
  end

  @impl true
  def init(name) do
    case :global.register_name({@lookup_prefix, name}, self()) do
      :yes ->
        :global.sync()
        {:ok, %__MODULE__{node: Node.self(), name: name, pid: self()}}

      :no ->
        {:stop, :cannot_register}
    end
  end

  @impl true
  def handle_call(:state, _from, state), do: {:reply, state, state}

  @spec list() :: list(NodeRegistry.t())
  def list, do: all()

  @spec all() :: list(NodeRegistry.t())
  def all do
    :global_names
    |> :ets.match({{@lookup_prefix, :"$1"}, :"$2", :_, :_})
    |> Enum.reduce(%{}, fn [name, pid], acc ->
      Map.put(acc, name, :erlang.node(pid))
    end)
  end

  @spec info(node | atom) :: NodeRegistry.t()
  def info(:self) do
    GenServer.call(__MODULE__, :state)
  end

  def info(:all) do
    Enum.map(all(), fn {_name, node} -> info(node) end)
  end

  def info(node) do
    :rpc.call(node, NodeRegistry, :info, [:self])
  end

  @spec node_with_name(atom) :: node | nil
  def node_with_name(name) when is_atom(name) do
    case :global.whereis_name({@lookup_prefix, name}) do
      :undefined ->
        nil

      pid when is_pid(pid) ->
        :erlang.node(pid)
    end
  end

  @spec nodes_with_prefix(atom) :: list(node)
  def nodes_with_prefix(prefix) when is_atom(prefix) do
    all()
    |> Enum.filter(fn {name, _node} -> String.starts_with?("#{name}", "#{prefix}") end)
    |> Enum.map(fn {_name, node} -> node end)
  end

  @spec random_node_with_prefix(atom) :: node
  def random_node_with_prefix(prefix) when is_atom(prefix) do
    case nodes_with_prefix(prefix) do
      [] -> nil
      nodes -> Enum.random(nodes)
    end
  end
end
