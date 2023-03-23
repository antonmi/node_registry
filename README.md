# NodeRegistry

[![Hex.pm](https://img.shields.io/hexpm/v/node_registry.svg?style=flat-square)](https://hex.pm/packages/node_registry)

**A simple node registry built on top of the Erlang :global module**

## Installation

```elixir
def deps do
  [
    {:node_registry, "~> 0.1"},
    # or
    {:node_registry, github: "antonmi/node_registry"}
  ]
end
```

## Motivation
Assuming:
- you have a cluster of nodes;
- different services are running on different nodes;
- some nodes may run identical services;
- some nodes may run different versions of the same service;
- you want to find a node with a specific service and do, for example, rpc.call to it.

## Solution
NodeRegistry provides a simple way to register node with a specific name.

It uses Erlang's :global module to register a node with a specific name.
It then uses :global.whereis_name to find a node by name.
Or it queries the `:global_names` ETS table to search nodes by name prefix.


## Usage
Add `{NodeRegistry, :my_service}` to the end of supervisor's children list.

Name is any arbitrary atom or string.

Examples:

`:my_service` (`"my_service"`), if you have only one "instance" of the service

`:my_service_v1` (`"my_service_v1"`), if you have multiple versions of the same service

`"web_service_v1_#{postfix}"`, if you have multiple versions / instances of the same service

Then you can find it and do `rpc.call` like:
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

## NodeRegistry.Remote
One can `import NodeRegistry.Remote` and call remotely any function on random node with a specific name prefix.

```elixir
defmodule MyApp do
  import NodeRegistry.Remote
    
  def call_my_service do
    remote(:my_service, Mod, :fun, [1,2])
  end
end
```






