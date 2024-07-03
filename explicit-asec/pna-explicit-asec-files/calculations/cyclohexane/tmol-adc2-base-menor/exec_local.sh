#!/bin/bash

module purge
module load turbomole/6.6 

export MKL_DEBUG_CPU_TYPE=5
export MKL_CBWR=COMPATIBLE
export TURBODIR=/sw/cluster/pub/apps/turbomole/6.6

export PARNODES=1
export OMP_NUM_THREADS=4

#dscf > dscf.out
actual -r
ricc2 > adc2.out

