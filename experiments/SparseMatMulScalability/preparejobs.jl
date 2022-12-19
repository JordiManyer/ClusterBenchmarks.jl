using Mustache
using DrWatson

jobname(args...) = replace(savename(args...;connector="_"),"="=>"_")
driverdir(args...) = normpath(projectdir("..",args...))


function convert_nc_np_to_prod(d)
  o=Dict()
  for k in keys(d)
    if k==:nc || k==:np
     o[k]=prod(d[k])
    else
     o[k]=d[k]
    end
  end
  return o
end

function jobdict(params)
  np = params[:np]
  nc = params[:nc]
  fparams = convert_nc_np_to_prod(params)
  return Dict(
  "q" => "normal",
  "o" => datadir(jobname(fparams,"o.txt")),
  "e" => datadir(jobname(fparams,"e.txt")),
  "walltime" => "00:30:00",
  "ncpus" => prod(np),
  "mem" => "$(prod(np)*4)gb",
  "name" => jobname(fparams),
  "nc" => nc,
  "n" => prod(np),
  "np" => np,
  "projectdir" => driverdir(),
  "modules" => driverdir("modules.sh"),
  "title" => datadir(jobname(fparams))
  )
end

function create_dicts(num_nodes,nc_per_proc)
  N = length(num_nodes)
  dicts = Vector{Dict{Symbol,Any}}(undef,N)
  for (k,nN) in enumerate(num_nodes)
    px = 6*nN
    py = 8*nN
    nx = px * nc_per_proc
    ny = py * nc_per_proc
    
    dicts[k] = Dict{Symbol,Any}(
      :np = (px,py)
      :nc = (nx,ny)
    )
  end
  return dicts
end

############################################
num_nodes = [1,2,4,8]
nc_per_proc = 10

dicts = create_dicts(num_nodes,nc_per_proc)

template = read(projectdir("jobtemplate.sh"),String)
for params in dicts
   fparams = convert_nc_np_to_prod(params)
   jobfile = datadir(jobname(fparams,"sh"))
   open(jobfile,"w") do io
     render(io,template,jobdict(params))
   end
end
