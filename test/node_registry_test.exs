defmodule NodeRegistryTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = NodeRegistry.start_link(:service_a)

    on_exit(fn ->
      :global.unregister_name(:service_a)
    end)

    %{pid: pid}
  end

  test "check :global.registered_names()", %{pid: pid} do
    assert :global.registered_names() == [{:node_registry, :service_a}]
    assert :global.whereis_name({:node_registry, :service_a}) == pid
  end

  test "all/0" do
    assert NodeRegistry.all() == %{service_a: :nonode@nohost}
  end

  test "info/1", %{pid: pid} do
    info = %NodeRegistry{
      node: :nonode@nohost,
      name: :service_a,
      pid: pid
    }

    assert NodeRegistry.info(:self) == info
    assert NodeRegistry.info(:nonode@nohost) == info
    assert NodeRegistry.info(:all) == [info]
  end

  test "node_with_name/1" do
    assert NodeRegistry.node_with_name(:service_a) == :nonode@nohost
    assert NodeRegistry.node_with_name(:no_such_service) == nil
  end

  test "nodes_with_prefix/1" do
    assert NodeRegistry.nodes_with_prefix(:serv) == [:nonode@nohost]
    assert NodeRegistry.nodes_with_prefix(:no_such_service) == []
  end

  test "random_node_with_prefix/1" do
    assert NodeRegistry.random_node_with_prefix(:serv) == :nonode@nohost
    assert NodeRegistry.random_node_with_prefix(:no_such_service) == nil
  end
end
