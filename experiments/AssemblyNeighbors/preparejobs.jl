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
  case = params[:case]
  fparams = convert_nc_np_to_prod(params)
  return Dict(
  "q" => "normal",
  "o" => datadir(jobname(fparams,"o.txt")),
  "e" => datadir(jobname(fparams,"e.txt")),
  "walltime" => "00:30:00",
  "ncpus" => prod(np),
  "mem" => "$(prod(np)*4)gb",
  "name" => jobname(fparams),
  "n" => prod(np),
  "np" => np,
  "case" => case,
  "projectdir" => driverdir(),
  "modules" => driverdir("modules.sh"),
  "title" => datadir(jobname(fparams))
  )
end

function create_dicts(num_nodes,cases)
  N = length(num_nodes)*length(cases)
  dicts = Vector{Dict{Symbol,Any}}(undef,N)

  k = 1
  for nN in num_nodes
    np = 48*nN
    px = np÷8
    py = np÷6
    for case in cases
      dicts[k] = Dict{Symbol,Any}(
        :np    => (px,py),
        :case  => case,
      )
      k += 1
    end
  end
  return dicts
end

############################################
num_nodes = [1,2,3,4]
cases = [:all,:uniform]

dicts = create_dicts(num_nodes,cases)

template = read(projectdir("jobtemplate.sh"),String)
for params in dicts
   fparams = convert_nc_np_to_prod(params)
   jobfile = projectdir("jobs/",jobname(fparams,"sh"))
   open(jobfile,"w") do io
     render(io,template,jobdict(params))
   end
end
