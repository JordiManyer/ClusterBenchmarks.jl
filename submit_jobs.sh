#!/bin/bash

for f in ./experiments/AssemblyNeighbors/jobs/*.sh; do
    qsub $f
done


