#!/bin/bash
##
## Copyright (C) 2009-2021 VersatusHPC, Inc.
##
## partition = fila
#SBATCH --partition=normal
##
## nodes = quantidade de nodes
#SBATCH --nodes=1
##
## ntasks-per-node = quantidade de nucleos por node
#SBATCH --ntasks-per-node=32
##
## time = quantidade de tempo
#SBATCH --time=7200:00:00
##

## Variavel com o diretorio de scratch do job
## Consulte <https://slurm.schedmd.com/sbatch.html#lbAH> para mais informacoes
## sobre as variaveis de ambiente do SLURM.
TURBOTMPDIR=/data/$USER/$SLURM_JOB_ID
WRKDIR=$TURBOTMPDIR

## O nome dos arquivos de input e output sao baseados no
## nome do job (linha "#SBATCH --jobname=xxx" acima).
## Observe que nao e obrigatorio esta forma de nomear os arquivos.
INP=$SLURM_JOB_NAME".in"
OUT=$SLURM_JOB_NAME".out"

## O diretorio onde o job sera executado sera apagado, por padrao, ao
## final do mesmo.
## Se desejar que nao seja apagado, substitua Y por N.
APAGA_SCRATCH=Y

## Informacoes do job impressos no arquivo de saida.
echo -e "\n## Jobs ativos de $USER: \n"
squeue -a --user=$USER
echo -e "\n## Node de execucao do job:         $(hostname -s) \n"
echo -e "\n## Numero de tarefas para este job: $SLURM_NTASKS \n"

#########################################
##-------  Inicio do trabalho     ----- #
#########################################

## Configura o ambiente de execucao do software.
module purge
module load turbomole/6.6 
export MKL_DEBUG_CPU_TYPE=5
export MKL_CBWR=COMPATIBLE
export TURBODIR=/sw/cluster/pub/apps/turbomole/6.6


## Informacoes sobre o ambiente de execucao impressos no arquivo de saida.
echo -e "\n## Diretorio de submissao do job:   $SLURM_SUBMIT_DIR \n"
echo -e "\n## Diretorio de scratch do job:     $WRKDIR \n"
echo -e "\n## Arquivo de input:                $INP \n"

## Cria o diretorio de scratch para o job.
mkdir -p $WRKDIR

cd $SLURM_SUBMIT_DIR

# set parallel environment
export PARNODES=${SLURM_NTASKS}
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# run jobex calculation
dscf > dscf.out
ricc2 > adc2.out

## Apaga o diretorio de scratch do job.
if [ x"$APAGA_SCRATCH" = x"Y" ]; then
    rm -rf $WRKDIR
else
    echo -e "\nO diretorio \e[00;31m$WRKDIR\e[00m deve ser removido manualmente"
    echo -e "para evitar problemas para outros jobs e/ou usuarios. \n"
fi

echo -e "\n## Job finalizado em $(date +'%d-%m-%Y as %T') ###################"
