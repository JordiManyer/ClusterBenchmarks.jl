
function SparseArrays.nnz(a::PSparseMatrix)
  sum(map(nnz,partition(a)))
end
