module load openmpi/4.1.2
export JULIA_MPI_BINARY=system
export JULIA_MPI_PATH=/apps/openmpi/4.1.2
export UCX_ERROR_SIGNALS="SIGILL,SIGBUS,SIGFPE"

# This is for avoiding openmpi problems in gadi:
export HCOLL_ML_DISABLE_SCATTERV=1;
export HCOLL_ML_DISABLE_BCAST=1
export ZES_ENABLE_SYSMAN=1
