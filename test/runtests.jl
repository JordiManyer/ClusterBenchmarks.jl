using Test
using MPI

# Check for System Image
sysimage=nothing
if length(ARGS)==1
   @assert isfile(ARGS[1]) "$(ARGS[1]) must be a valid Julia sysimage file"
   sysimage=ARGS[1]
end

function run_tests(testdir,np,sysimage)
  istest(f) = endswith(f, ".jl") && !(f=="runtests.jl")
  testfiles = sort(filter(istest, readdir(testdir)))
  @time @testset "$f" for f in testfiles
    MPI.mpiexec() do cmd
      if isa(sysimage,Nothing)
        cmd = `$cmd -n $(np) $(Base.julia_cmd()) --project=. $(joinpath(testdir, f))`
      else
        cmd = `$cmd -n $(np) $(Base.julia_cmd()) -J$(sysimage) --project=. $(joinpath(testdir, f))`
      end
      @show cmd
      run(cmd)
      @test true
    end
  end
end

run_tests(joinpath(@__DIR__, "mpi"),4,sysimage)