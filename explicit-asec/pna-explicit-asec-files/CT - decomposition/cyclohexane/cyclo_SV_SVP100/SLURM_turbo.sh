#!/bin/bash
#SBATCH --job-name=tmole-test
#SBATCH --partition quanah
#SBATCH --nodes=1
#SBATCH --ntasks=36
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=1G

export OMP_NUM_THREADS=8
export PARNODES=8
export PARA_ARCH=SMP
ulimit -s unlimited
export MKL_ENABLE_INSTRUCTIONS=SSE4_2

export TURBODIR=/home/hlischka/programs/TURBOMOLE-7.5/TURBOMOLE/
#export TURBODIR=/home/rnieman/PROGRAMS/TURBOMOLE-7.4.1/TURBOMOLE
export PATH=$PATH:$TURBODIR/scripts
export PATH=$TURBODIR/bin/`sysname`:$PATH

retval=0

mkdir -p /lustre/scratch/$USER/$SLURM_JOB_ID
WRKDIR=/lustre/scratch/$USER/$SLURM_JOB_ID
cd $WRKDIR
cp $SLURM_SUBMIT_DIR/* . -f

# control echoes
echo "TURBODIR :$TURBODIR"
echo "PATH     :$PATH"
echo "==============================="
echo "start up"
echo "HOME=$HOME"
echo "WRKDIR=$WRKDIR"
echo "HOSTNAME=$HOSTNAME"
echo "JOBID=$SLURM_JOB_ID"
echo "SUBMIT_DIR=$SLURM_SUBMIT_DIR"
echo "NSLOTS=$SLURM_NTASKS, NPEFF=$NPEFF"
echo "P_PER_N_eff=$P_PER_N_eff"
echo "P_PER_N=$P_PER_N"
echo "==============================="

#-----------------------------------------------------------------------
# NOW EXECUTION of the Turbomole JOB.
# This has to be changed according to particular Turbomole specification.
##########################################
echo "STARTING AT " `date`

# jobex -ri -c 700
# aoforce > freq.out
## ********** GEOMETRY OPTIMIZATION CC2 ********************************
#    jobex -level cc2 -c 700
## *********************************************************************
## ********** SINGLE POINT CC2 *****************************************
# remove out file in the scratch directory to avoid overwriting
# in the home directory when copied back below
#     rm -f dscf.out adc2.out ccsd.out
#jobex -c 700



#ridft > ridft.out
#dscf  > dscf.out 
#    escf > escf.out

ricc2 > adc2-restart.out
#    jobex  -level cc2 -c 700
#    ccsdf12 > ccsd.out


## *********************************************************************
echo "FINISHED AT " `date`
##########################################
echo "FINAL COPY: WRKDIR=$WRKDIR"
cd $WRKDIR
rm slurm* -f
#Copy mos, alpha, or beta back before remove command
if [ -f $WRKDIR/mos ]; then
 mv -f $WRKDIR/mos $SLURM_SUBMIT_DIR
fi
if [ -f $WRKDIR/alpha ]; then
 mv -f $WRKDIR/alpha $SLURM_SUBMIT_DIR
fi
if [ -f $WRKDIR/beta ]; then
 mv -f $WRKDIR/beta $SLURM_SUBMIT_DIR
fi
pwd
rmfiles="`find . -size +50M`"
echo "rmfiles=$rmfiles"
   if [ "$rmfiles" == "" ]
   then
      echo 'No big files to remove.'
   else
      echo 'Removing big files:'
      echo $rmfiles
#      rm -f $rmfiles
   fi
mv -f $WRKDIR/* $SLURM_SUBMIT_DIR
rm $WRKDIR -rf
