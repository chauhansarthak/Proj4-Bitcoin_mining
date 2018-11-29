defmodule Parent do
  @moduledoc false
  


  use GenServer

  def updateMiners(server_id,nodeList) do
    GenServer.cast(server_id,{:updateMiners,nodeList})

  end

  def got_block(server_id,block) do
    GenServer.cast(server_id,{:got_block,block})
  end

  def print_blocks(server_id) do
    GenServer.cast(server_id,{:print_blocks})
  end

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def print(server_id) do
    GenServer.cast(server_id,{:print})
  end

  def init(nodeName) do
    map = %{
    nodeList: [],
    blockList: []
    }
    {:ok, map}
  end

  def handle_cast({:print_blocks},state) do
    IO.inspect(state.blockList)
    {:noreply,state}
  end

  def handle_cast({:got_block,block},state) do
#    new_map = if Enum.member?(state.blockList,block) do
#      IO.puts("found already")
#    else
##      Enum.each(state.nodeList, fn x -> Process.exit(x,:kill)  end)
#      nodeList = Enum.map(1..10, fn x -> BITCOIN.createNode(x) end)
#      block = String.downcase(block)
#      new_map = %{
#        nodeList:  nodeList,
#        blockList: state.blockList ++ [block]
#      }
#      Enum.each(nodeList, fn x ->BITCOIN.start_mining(x,block,1,self())  end)
#    end
#    {:noreply,new_map}
    block = String.downcase(block)
    new_map =
      if Enum.member?(state.blockList,block) do
#        IO.puts"doing nothing"
        new_map = %{
        nodeList: state.nodeList,
        blockList: state.blockList
        }
        new_map
      else
        Enum.each(state.nodeList, fn x -> Process.exit(x,:kill)  end)
        nodeListNew = Enum.map(1..10, fn x -> BITCOIN.createNode(x) end)
        IO.puts"FOUND A BLOCK #{inspect(block)}"
        new_map = %{
        nodeList: nodeListNew,
        blockList: state.blockList ++ [block]
        }
        IO.puts"Num of Blocks in Chain :#{inspect(Enum.count(state.blockList))}"
        IO.puts"-------------------"
        Enum.each(nodeListNew, fn x ->BITCOIN.start_mining(x,block,1,self())  end)
        new_map
    end
#    Enum.each(node, fn x ->BITCOIN.start_mining(x,block,1,self())  end)
    {:noreply,new_map}
  end

  def handle_cast({:updateMiners,nodeList},state) do
#    IO.puts"updating parent---->#{inspect(nodeList)}"
    new_map = %{
    nodeList: nodeList,
    blockList: []
    }
    {:noreply,new_map}
  end

  def handle_cast({:print},state) do
    IO.inspect(state.nodeList)
    {:noreply,state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end