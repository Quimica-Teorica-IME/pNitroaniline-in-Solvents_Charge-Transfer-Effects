#!/bin/bash

cat $1 | awk 'BEGIN{
sigma=0.5   #eV units for single configuration
sigma=0.2   #eV units for 10 configurations
datamax=0.0 #max to normalize function
}

!/#/ {
  l++;
  if (l==1) {emin=$1; emax=$1}
  energy[l]=$1;
  if (emin > $1) emin=$1;
  if (emax < $1) emax=$1;
  nenergy=l;
  f++;
  if (f==1) {fmin=$2; fmax=$2}
  force[f]=$2;
  if (fmin > $2) fmin=$2;
  if (fmax < $2) fmax=$2;
  nforce=f;
#   print "init " nenergy, nforce
#   print "fmax fmin " fmax, fmin
#   print "emax emin " emax, emin

}

END {
  for (i=int(2500); i<=int(6500);i++){
#      print "Energy igual " i
    for (f=1;f<=nenergy;f++){
#          print "Valor da intensidade do spectro " data[i/1000];
      data[i/1000]= data[i/1000] + gauss(i/1000,energy[f],force[f],sigma);
#        print "retorno",  gauss(i/1000,energy[f],force[f],sigma);
      if (datamax < data[i/1000]) datamax=data[i/1000]
    }
#    printf "%-6.3f  %20.9f\n", i/1000,data[i/1000]
  }  
    for (i=int(2500); i<=int(6500);i++){
    printf "%-6.3f  %20.9f  %20.9f\n", i/1000,data[i/1000]/datamax,data[i/1000]
  }

}

function gauss(x,energy,force,sigma){
     arg = -((x-energy)/(sigma))^2
     if ( arg < -100){
     return 0.0}
     else {
     return 1240*13.062974*force*exp(arg)/sigma}
     }' > $1.spectrum.dat
