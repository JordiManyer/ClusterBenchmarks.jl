#!/bin/bash

for f in ./experiments/SparseMatMulScalability/jobs/*.sh; do
    qsub $f
done


