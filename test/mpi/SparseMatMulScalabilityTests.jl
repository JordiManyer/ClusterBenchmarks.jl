module SparseMatMulScalabilityTests
using MPI
using Test
using ClusterBenchmarks

function run_tests()
  np = (2,2)
  nc = (100,100)
  order = 1
  sparse_matmul_main(;title="TEST",np=np,nc=nc,order=order)
end

run_tests()

end