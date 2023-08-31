
function sparse_matmul_compile(ranks,rank_partition,mesh_partition,order)
  domain = (1,0,1,0)
  model  = CartesianDiscreteModel(ranks,rank_partition,domain,mesh_partition)

  qdegree = 2*(order+1)
  sol(x)  = x[1]+x[2]
  reffe   = ReferenceFE(lagrangian,Float64,order)
  V       = TestFESpace(model,reffe,dirichlet_tags="boundary")
  U       = TrialFESpace(V,sol)

  Ω  = Triangulation(model)
  dΩ = Measure(Ω,qdegree)
  a(u,v) = ∫(∇(v)⋅∇(u)) * dΩ
  A = assemble_matrix(a,U,V)
  x = pfill(1.0,partition(axes(A,2)))
  y = pfill(0.0,partition(axes(A,1)))
  mul!(y,A,x)

  allocs = map(ranks) do _p
    VectorValue(1,2,3,4)
  end
  allocs = sum(allocs)
end

function sparse_matmul_driver(ranks,rank_partition,mesh_partition,order,t,outputs)

  model_alloc = @allocated begin
    domain = (1,0,1,0)
    model  = CartesianDiscreteModel(ranks,rank_partition,domain,mesh_partition)
  end

  fespaces_alloc = @allocated begin
    qdegree = 2*(order+1)
    sol(x)  = x[1]+x[2]
    reffe   = ReferenceFE(lagrangian,Float64,order)
    V       = TestFESpace(model,reffe,dirichlet_tags="boundary")
    U       = TrialFESpace(V,sol)
  end

  measure_alloc = @allocated begin
    Ω  = Triangulation(model)
    dΩ = Measure(Ω,qdegree)
  end

  system_alloc = @allocated begin
    a(u,v) = ∫(∇(v)⋅∇(u)) * dΩ
    A = assemble_matrix(a,U,V)
    x = pfill(1.0,partition(axes(A,2)))
    y = pfill(0.0,partition(axes(A,1)))
  end

  ndofs    = size(A,1)
  nonzeros = nnz(A)

  free_mem = Sys.free_memory()/2^20
  tot_mem  = Sys.total_memory()/2^20

  niter = 200
  for k in 1:niter
    tic!(t;barrier=true)
    mul!(y,A,x)
    toc!(t,"time_$k")
  end

  allocs = map(ranks) do _p
    VectorValue(model_alloc,fespaces_alloc,measure_alloc,system_alloc)
  end
  allocs = sum(allocs)

  map_main(t.data) do t_data
    time = 1.e10
    for k in 1:niter
      time = min(time,t_data["time_$k"][:max])
    end

    outputs["free_memory_MB"]   = free_mem
    outputs["total_memory_MB"]  = tot_mem
    outputs["num_repetitions"]  = niter
    outputs["num_dofs"]         = ndofs
    outputs["num_non_zeros"]    = nonzeros
    outputs["curated_time"]     = time

    outputs["allocated_model_MB"]    = allocs[1]/2^20
    outputs["allocated_fespaces_MB"] = allocs[2]/2^20
    outputs["allocated_measure_MB"]  = allocs[3]/2^20
    outputs["allocated_system_MB"]   = allocs[4]/2^20
  end
end

function sparse_matmul_main(;title::AbstractString,np::Tuple,nc::Tuple,order::Int)
  with_mpi() do distribute
    ranks = distribute(LinearIndices((prod(np),)))
    sparse_matmul_compile(ranks,np,nc,order)

    t = PTimer(ranks,verbose=true)
    outputs = Dict{String,Any}()
    allocs  = @allocated sparse_matmul_driver(ranks,np,nc,order,t,outputs)
    
    map_main(t.data) do timer_data
      outputs["ARCH"] = Sys.ARCH
      outputs["CPU"]  = Sys.CPU_NAME
      outputs["num_procs"] = prod(np)
      outputs["num_cells"] = nc
      outputs["order"] = order
      outputs["allocated_total_MB"] = allocs/2^20
      merge!(outputs,timer_data)
      save("$title.bson",outputs)
    end
  end
end
