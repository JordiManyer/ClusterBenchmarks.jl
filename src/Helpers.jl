

function mytic!(t,comm)
  MPI.Barrier(comm)
  PartitionedArrays.tic!(t)
end