defmodule BITCOIN do
  use GenServer

  #API's
  def print(server_id) do
    print = GenServer.call(server_id,{:print})
    IO.puts " #{inspect(server_id)} ---->#{inspect(print)}"
  end

  def start_mining(server_id,prev_block,nonce,parent_id) do
    GenServer.cast(server_id,{:start_mining,prev_block,nonce,parent_id})
  end

  #Cast Functions
  def handle_cast({:start_mining,prev_block,nonce,parent_id},state) do
    ver = "00000001"
#    prev_block = "81cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000"
    #    mrkl_root  = "3BA3EDFD7A7B12B27AC72C3E67768F617FC81BC3888A51323A9FB8AA4B1E5E4A"
    mrkle_root = "e320b6c2fffc8d750423db8b1eb942ae710e951ed797f7affc8892b0f1fc122b"
    time = DateTime.utc_now |> DateTime.to_string |> String.slice(15,4) |> Base.encode16(case: :lower)
    bits = "f2b9441a"
    nonce_string = nonce |> :binary.encode_unsigned |> Base.encode16(case: :lower)
    #adding required zeros
    zero_req = 8 - String.length(nonce_string)
    zero_req_string = String.duplicate("0", zero_req)
    nonce_final = zero_req_string <> nonce_string
    header_hex = ver <> prev_block <> mrkle_root <> time <> bits <> nonce_final
#    IO.puts"header_hex--------------->#{inspect(header_hex)}"
    header_bin  = Base.decode16!(header_hex, case: :lower)
    hash = :crypto.hash(:sha256,header_bin)
    hash2 = :crypto.hash(:sha256,hash)
    hash2_encoded = Base.encode16(hash2)
    h2_1 = :binary.decode_unsigned(hash2_encoded,:little)
    h2_2 = :binary.encode_unsigned(h2_1,:big)
    hash_final = hash2 |> Base.encode16 |> :binary.decode_unsigned(:little) |> :binary.encode_unsigned(:big)
    lead = String.slice(hash_final,0,3)
    block_mined = cond do
      lead == "000"
      ->
#        IO.puts"FOUND A BLOCK at pid=#{inspect(self())}------block=#{inspect(hash_final)}"
         Parent.got_block(parent_id,hash_final)
#         IO.inspect(hash_final)
         hash_final
      true
      ->
#        IO.puts"nonce ----> #{inspect(nonce)} &&&&&& slice ------> #{inspect(lead)}"
         BITCOIN.start_mining(self(),prev_block,nonce+1,parent_id)
    end
#    block_mined
    {:noreply,state}
  end


  #Call Functions
  def handle_call({:print},_caller,state) do
    #    IO.inspect(state.identifier)
    {:reply,state.amount,state}
  end


  def init(name) do
    wallet =%{
    amount: 0
    }
    {:ok,wallet}
  end

  def createNode(nodeNumber) do
    nodeName = String.to_atom("node#{nodeNumber}")
    {:ok, pid} = GenServer.start(BITCOIN, name: nodeName)
    pid
  end

  def createParentNode do
    nodeName = String.to_atom("node1")
    {:ok,pid} = GenServer.start(Parent,name: nodeName)
    pid
  end

  def main do
    nodeList = Enum.map(1..10, fn x -> createNode(x) end)
#    IO.inspect(nodeList)
    parentNode = createParentNode
#    IO.inspect(parentNode)
#    Enum.each(nodeList, fn x -> BITCOIN.print(x)  end)
    Parent.updateMiners(parentNode,nodeList)
#    Parent.print(parentNode)

#    Enum.map(nodeList, fn x -> Process.exit(x,:kill)  end)
#    map=Enum.map(nodeList, fn x -> Process.alive?(x) end)
#    new_block = Test1.tt1(1)
#    IO.puts"the new block is -----> #{inspect(new_block)}"
      prev_block = "81cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000"
    Enum.each(nodeList, fn x ->BITCOIN.start_mining(x,prev_block,1,parentNode)  end)
  end

end
