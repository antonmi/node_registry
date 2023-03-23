defmodule NodeRegistry.RemoteTest do
  use ExUnit.Case

  defmodule Mod do
    import NodeRegistry.Remote

    def do_remote_call do
      remote(:service_a, NodeRegistry, :list, [])
    end
  end

  setup do
    {:ok, _pid} = NodeRegistry.start_link(:service_a)

    on_exit(fn ->
      :global.unregister_name(:service_a)
    end)
  end

  test "remote call" do
    assert Mod.do_remote_call() == %{service_a_nonode@nohost: :nonode@nohost}
  end
end
