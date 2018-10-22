defmodule Implementation do
  def chord(numNodes,numRequests,failNodes) do
    # m = get_next_pow(numNodes,0)
    m =  :math.log(numNodes)/:math.log(2) |> :math.ceil |> round #calculate size of finger table according to number of total nodes
    list1 = 1..Kernel.trunc(:math.pow(2,m)) |> Enum.shuffle()
    list1 = Enum.slice(list1,1..numNodes) |> Enum.sort
    node_set = Map.new
    node_set = NodeCreator.create_nodes(node_set,list1,numNodes-1,m) #creates all the nodes with their finger table
    IO.puts " "
    IO.puts "Calculating number of hops"
    ans = spawnRequests(0,numNodes, list1, numRequests, node_set, list1, m,0) #starts the lookup function with number of requests
    if ans != 0 do
      val = ans/(numRequests * (numNodes - failNodes)) #calculates the average number of hops per request
      IO.puts " "
      IO.puts " "
      IO.puts "Number of nodes which were failed: #{failNodes}"
      IO.puts "Average number of hops are: #{val}"
    end
  end

  def failureModel(numNodes,numRequests,failNodes) do
    remainingNodes = numNodes - failNodes #the failed nodes are randomly removed
    chord(remainingNodes,numRequests,failNodes)
  end

  def spawnRequests(remainingNodes , numNodes, list1, numRequests, node_set, list1, m, hop_count) do
    if numNodes - remainingNodes > 0 do #calls the request funtion until all the nodes are given the supplied number of requests
      ans = spawnActors(numRequests,node_set,list1,m,numNodes,0,0,Enum.at(list1,remainingNodes), 0, 0)
      spawnRequests(remainingNodes + 1, numNodes, list1, numRequests, node_set, list1, m,ans + hop_count)
    else
      hop_count
    end
  end

  def spawnActors(numRequests,node_set,list1,m,numNodes,num,temp,next, hop, hop_count) do
    if numRequests === 0 do #called for each request to the same nodes but with different random lookup
      hop_count
    else
      randVal = :rand.uniform(Kernel.trunc(:math.pow(2,m)))
      ans = traverse_nodes(node_set,list1,m,numNodes,randVal,0,next,0) #this function is  called to start the lookup, with the starting node & the lookup node
      if(ans != nil) do
        spawnActors((numRequests - 1), node_set,list1,m,numNodes,num,temp,next, hop, ans + hop_count)
      else
        spawnActors((numRequests - 1), node_set,list1,m,numNodes,num,temp,next, hop, hop_count)
      end
    end
  end

  def traverse_nodes(node_set,list1,m,numNodes,num,temp,next, hop) do
    IO.write "."
    if next == Enum.at(list1,numNodes-1) || next == num || (Enum.at(list1,numNodes-1) == Kernel.trunc(:math.pow(2,m)) && next == Enum.at(list1,numNodes-2)) do
      hop
    else
      if(temp != 0) do
        node1 =  Map.fetch!(node_set, next)
        if(node1 != nil) do
          max = Map.values(node1) |> Enum.max()
          next = traverse_table(node1,num, next) #finds the exact value or closest less than lookup provided
          if(next == -1) do
            hop
          else
            if(temp < numNodes && max !=nil) do
              if(max < num) do
                traverse_nodes(node_set,list1,m,numNodes,num,temp+1,max,hop+1)
              else
                traverse_nodes(node_set,list1,m,numNodes,num,temp+1,next,hop+1)
              end
            end
          end
        end
      else
        if(Map.fetch(node_set, Enum.at(list1,next)) == :error) do
          node1 = Map.fetch!(node_set, next)
          if(node1 != nil) do
            next = traverse_table(node1,num, next)
            if(next == -1) do
              hop
            else
              if(temp < numNodes) do
                traverse_nodes(node_set,list1,m,numNodes,num,temp+1,next,hop+1)
              end
            end
          end
        else
          {:ok, node1} = Map.fetch(node_set, Enum.at(list1,next))
          if(node1 != nil) do
            next = traverse_table(node1,num, next)
            if(next == -1) do
              hop
            else
              if(temp < numNodes) do
                traverse_nodes(node_set,list1,m,numNodes,num,temp+1,next,hop+1)
              end
            end
          end
        end
      end
    end
  end

  def traverse_table(node1,num, next) do
    list =
      Enum.flat_map Map.values(node1), fn d ->
        case (d <= num && d > next && next <= num) || (d <= num && next > num) do
          true -> [d]
          false -> []
        end
      end
    if list != [] do
      list |> Enum.max()
    else
      -1
    end
  end

  def init(index) do
    {:ok, index}
  end

  def get_next_pow(n,i) do
    k = :math.pow(2,i)
    if(k < n) do
      get_next_pow(n, i + 1)
    else
      i
    end
  end
end

  defmodule NodeCreator do
    def create_nodes(node_set,nodelist,n,m) do
      if(n>-1) do
        pid2 = self()
        {:ok, pid} = GenServer.start_link(NodeCreator, [:hello], name: String.to_atom("#{n}"))
        GenServer.cast(pid, {:push, [pid2,node_set,nodelist,n,m]}) #creates a new proess for each of the nodes created
        receive do
          {:getNodeSet,node_set} ->  create_nodes(node_set,nodelist,n-1,m)
        end
      else
        node_set
      end
    end

    def handle_cast({:push, [pid,node_set,nodelist,n,m]}, state) do
      table_entry = Map.new
      IO.puts "Node with key: #{:crypto.hash(:sha, "#{Enum.at(nodelist, n)}") |> Base.encode16} created"
      table_entry = fill_finger(table_entry,m,1,Enum.at(nodelist, n),nodelist,m) #fills the finger table of the supplied node
      node_set = Map.put(node_set, Enum.at(nodelist, n), table_entry)
      send(pid,{:getNodeSet,node_set})
      {:noreply, [[pid,node_set,nodelist,n,m] | state]}
    end

    def init(stack) do
      {:ok, stack}
    end

    def fill_finger(table_entry,n,k,index,nodelist,m) do
      if(n>0) do
        if is_integer(index) do
          entry = rem(trunc(index + :math.pow(2,k-1)),trunc(:math.pow(2,m)))
          x = if Enum.member?(nodelist, entry) do
            entry
          else
              if (entry > Enum.max(nodelist)) do
                new_entry = trunc(:math.pow(2,m)) - entry
                if(new_entry < 0) do
                  new_entry1 = new_entry * (-1)
                  if Enum.member?(nodelist, new_entry1) do
                    new_entry1
                  else
                    Enum.find(nodelist, fn x -> x > new_entry1 end)
                  end
                else
                  if Enum.member?(nodelist, new_entry) do
                    new_entry
                  else
                    Enum.find(nodelist, fn x -> x > new_entry end)
                  end
                end
              else
                Enum.find(nodelist, fn x -> x > entry end)
              end
          end
          table_entry = Map.put(table_entry, k, x)
          fill_finger(table_entry,n-1,k+1, index,nodelist,m)
        end
      else
        table_entry
      end
    end
  end

defmodule Main do
  def main(args) do
    args |> parse_args
  end

  defp parse_args([]) do
    IO.puts "No arguments given. Enter parameters again"
  end

  defp parse_args(args) do
    {_, parameters, _} = OptionParser.parse(args,  strict: [limit: :integer])
      numNodes = String.to_integer(Enum.at(parameters,0))
      numRequests = String.to_integer(Enum.at(parameters,1))
      failNodes = String.to_integer(Enum.at(parameters,2))
      Implementation.failureModel(numNodes,numRequests,failNodes)  #calls the runner functions with arguments
    end
end
