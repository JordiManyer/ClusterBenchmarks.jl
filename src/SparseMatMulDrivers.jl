

function sparse_matmul_driver(parts,t,outputs,partition,order)
  comm   = parts.comm
  domain = (1,0,1,0)
  model  = CartesianDiscreteModel(parts,domain,partition)

  qdegree = 2*(order+1)
  sol(x)  = x[1]+x[2]
  reffe   = ReferenceFE(lagrangian,Float64,order)
  V       = TestFESpace(model,reffe,dirichlet_tags="boundary")
  U       = TrialFESpace(V,sol)

  Ω  = Triangulation(model)
  dΩ = Measure(Ω,qdegree)
  a(u,v) = ∫(∇(v)⋅∇(u)) * dΩ
  A = assemble_matrix(a,U,V)
  x = PVector(1.0,A.cols)
  y = PVector(0.0,A.rows)
  mul!(y,A,x)

  free_mem = Sys.free_memory()/2^20
  tot_mem  = Sys.total_memory()/2^20

  niter = 200
  mytic!(t,comm)
  for i in 1:niter
    mul!(y,A,x)
  end
  PartitionedArrays.toc!(t,"time_total")
  
  if i_am_main(parts)
    outputs["free_memory"] = free_mem
    outputs["total_memory"] = tot_mem
    outputs["num_repetitions"] = niter
  end
end


function sparse_matmul_main(;title::AbstractString,np::Tuple,nc::Tuple)
  prun(mpi,np) do parts
    t = PTimer(parts,verbose=true)
    outputs = Dict{String,Any}()
    sparse_matmul_driver(parts,t,outputs,nc,1)
    
    map_main(t.data) do timer_data
      outputs["ARCH"] = Sys.ARCH
      outputs["CPU"] = Sys.CPU_NAME
      outputs["num_procs"] = prod(np)
      merge!(outputs,timer_data)
      save("$title.bson",outputs)
    end
  end
end
