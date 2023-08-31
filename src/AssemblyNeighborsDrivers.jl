
function assembly_neighbors_setup(::Val{:all},ranks,np)
  nbor_list = Base.OneTo(length(ranks))
  parts_snd = map(ranks) do r
    filter(n->n!=r,nbor_list)
  end
  return parts_snd
end

function assembly_neighbors_setup(::Val{:uniform},ranks,np)
  n = map(npi -> 10*npi,np)
  ghost   = map(npi->true,np)
  indices = uniform_partition(ranks,np,n,ghost)

  parts_snd = map(indices) do indices
    rank = part_id(indices)
    local_index_to_owner = local_to_owner(indices)
    set = Set{Int32}()
    for owner in local_index_to_owner
      if owner != rank
        push!(set,owner)
      end
    end
    sort(collect(set))
  end
  return parts_snd
end

function assembly_neighbors_driver(outputs,parts_snd,name,find_rcv_ids)
  ranks = linear_indices(parts_snd)
  t = PTimer(ranks,verbose=true)

  # Warmup
  graph = ExchangeGraph(parts_snd;find_rcv_ids=find_rcv_ids)

  # Benchmark
  niter  = 20 # Number of recorded times
  ninner = 10 # Number of iterations in a single recording
  for k in 1:niter
    tic!(t;barrier=true)
    for _k in 1:ninner
      graph = ExchangeGraph(parts_snd;find_rcv_ids=find_rcv_ids)
    end
    toc!(t,string(name,"_$k"))
  end

  # Collect results
  tmin  = 1.e10
  tmean = 0.0
  tmax  = -1.e10
  times = Dict{String,Any}()
  map_main(t.data) do t_data
    for k in 1:niter
      tk = t_data[string(name,"_$k")][:max]/ninner
      tmin  = min(tmin,tk)
      tmean += tk
      tmax  = max(tmax,tk)
      times[string(name,"_$k")] = tk
    end
    tmean /= niter
  end

  map_main(ranks) do ranks
    outputs[string(name,"_tmin")]  = tmin
    outputs[string(name,"_tmean")] = tmean
    outputs[string(name,"_tmax")]  = tmax
    outputs[string(name,"_times")] = times
  end
end

function assembly_neighbors_driver(outputs,parts_snd,name)
  assembly_neighbors_driver(outputs,parts_snd,string(name,"_gatherscatter"),PartitionedArrays.find_rcv_ids_gather_scatter)
  assembly_neighbors_driver(outputs,parts_snd,string(name,"_ibarrier"),PartitionedArrays.find_rcv_ids_ibarrier)
end

function assembly_neighbors_main(;title::AbstractString,np::Tuple,case::Symbol)
  @assert case in (:all,:uniform)
  with_mpi() do distribute
    ranks = distribute(LinearIndices((prod(np),)))
    parts_snd = assembly_neighbors_setup(Val(case),ranks,np)

    outputs = Dict{String,Any}()
    assembly_neighbors_driver(outputs,parts_snd,title)
    
    map_main(ranks) do r
      outputs["ARCH"] = Sys.ARCH
      outputs["CPU"]  = Sys.CPU_NAME
      outputs["num_procs"] = prod(np)
      save("$title.bson",outputs)
    end
  end
end

