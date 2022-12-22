using Mustache
using DrWatson

jobname(args...) = replace(savename(args...;connector="_"),"="=>"_")
driverdir(args...) = normpath(projectdir("../..",args...))


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
  order = params[:order]
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
  "order" => order,
  "projectdir" => driverdir(),
  "modules" => driverdir("modules.sh"),
  "title" => datadir(jobname(fparams))
  )
end

function create_dicts(num_nodes,nc_per_proc,orders)
  N = length(num_nodes)*length(nc_per_proc)*length(orders)
  dicts = Vector{Dict{Symbol,Any}}(undef,N)

  k = 1
  for nN in num_nodes
    np = 48*nN
    px = np÷8
    py = np÷6

    for nC in nc_per_proc
      nx = px * 2^nC
      ny = py * 2^(nC+1)

      for order in orders
        dicts[k] = Dict{Symbol,Any}(
          :np    => (px,py),
          :nc    => (nx,ny),
          :order => order,
        )
        k += 1
      end
    end
  end
  return dicts
end

############################################
num_nodes = [1,2,3,4]
nc_per_proc = [3,4,5,6,7,8,9,10]
orders = [1]

dicts = create_dicts(num_nodes,nc_per_proc,orders)

template = read(projectdir("jobtemplate.sh"),String)
for params in dicts
   fparams = convert_nc_np_to_prod(params)
   jobfile = projectdir("jobs/",jobname(fparams,"sh"))
   open(jobfile,"w") do io
     render(io,template,jobdict(params))
   end
end
