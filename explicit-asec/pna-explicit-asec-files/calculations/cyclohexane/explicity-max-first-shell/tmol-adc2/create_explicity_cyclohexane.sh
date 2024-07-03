#!/bin/bash


module load turbomole
export MKL_DEBUG_CPU_TYPE=5
export MKL_CBWR=COMPATIBLE
export TURBODIR=/sw/cluster/pub/apps/turbomole/6.6


if [ $# -eq 0 ]
  then
    echo "Indique o nome do arquivo sem a extencao xyz para converter em input do turbomole. Valido apenas para solvente cyclohexane."
    exit
fi
if [[ "$1" == *"xyz"* ]]; then
  echo "o arquivo inicial nao pode ter a extencao xyz. Indique o nome do arquivo sem a extencao xyz."
  exit
fi

#org files
mkdir $1
cp $1.xyz $1
cd $1

#asec from dice to turbomole
x2t $1.xyz > $1.tmol
grep -v c $1.tmol | grep -v h | grep -v n | grep -v o > solvent.tmol



#pointcharges
echo '$point_charges nocheck' > pointcharges
cat solvent.tmol | awk  '{if( NR%18 > 0 && NR%18 < 7 ) ch="-0.1200" ;else  ch="0.0600"  ; printf "%9.5f  %9.5f %9.5f  %9.6f\n", $1,$2,$3,ch}' >> pointcharges
echo "\$end" >> pointcharges


# coordinates of solvent
nline=$(grep -m1 Xx $1.xyz -n |awk -F ":" '{printf $1-2}')
head $1.tmol -n$nline > coord
echo "\$end " >> coord



#execute define
define >define.out 2>&1 <<EOF



a coord
*
no
b 1-16 def2-TZVPD
b 17-$nline def2-SV(P)
bl
dat







*
eht



scf
iter
300


cc
freeze
*
cbas
bl
*
memory
500
ricc2
adc(2)
*
exci
irrep=a nexc=10
spectrum states=all operators=diplen,dipvel,angmom
*
*
*
EOF



sed -i '/file=basis/a $point_charges nocheck file=pointcharges' control
