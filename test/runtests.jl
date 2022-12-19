using Test
using ArgParse
using MPI
using ClusterBenchmarks

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--image-file", "-i"
        help = "Path to the image file that one can use in order to accelerate MPI tests"
        arg_type = String
        default="GridapDistributed.so"
    end
    return parse_args(s)
end

"""
  run_tests(testdir)
"""
function run_tests(testdir)
  parsed_args = parse_commandline()
  image_file_path   = parsed_args["image-file"]
  image_file_exists = isfile(image_file_path)

  istest(f) = endswith(f, ".jl") && !(f=="runtests.jl")
  testfiles = sort(filter(istest, readdir(testdir)))
  @time @testset "$f" for f in testfiles
    MPI.mpiexec() do cmd
      np = 4
      extra_args = ""
      if ! image_file_exists
        cmd = `$cmd -n $(np) --allow-run-as-root --oversubscribe $(Base.julia_cmd()) --project=. $(joinpath(testdir, f)) $(split(extra_args))`
      else
        cmd = `$cmd -n $(np) --allow-run-as-root --oversubscribe $(Base.julia_cmd()) -J$(image_file_path) --project=. $(joinpath(testdir, f)) $(split(extra_args))`
      end
      @show cmd
      run(cmd)
      @test true
    end
  end
end

run_tests(joinpath(@__DIR__, "mpi"))