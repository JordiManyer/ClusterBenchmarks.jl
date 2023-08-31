module AssemblyNeighborsTests
using MPI
using Test
using ClusterBenchmarks

function run_tests()
  np = (2,2)
  for case in [:uniform,:all]
    assembly_neighbors_main(;title="TEST",np=np,case=case)
  end
end

run_tests()

end