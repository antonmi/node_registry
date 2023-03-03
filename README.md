# NodeRegistry

**A simple node registry built on top of the Erlang's :global module**

## Installation

```elixir
def deps do
  [
    {:node_registry, github: "antonmi/node_registry"}
  ]
end
```

## Usage
Add `{NodeRegistry, :my_service}` to the supervisor's children list.

Then you can find it and do rpc.call like:
```elixir
:my_service
|> NodeRegistry.node_with_name()
|> :rpc.call(Module, function, args)
```

If you have services with identical functionality on different nodes, you can register them with the same prefix:

```elixir
{NodeRegistry, :my_service_1} # on node1
{NodeRegistry, :my_service_2} # on node2
```

Then you can find them and do rpc.call like:
```elixir
:my_service
|> NodeRegistry.random_node_with_prefix()
|> :rpc.call(Module, function, args)

# or

:my_service
|> NodeRegistry.nodes_with_prefix()
|> :rpc.multicall(Module, function, args)
```






