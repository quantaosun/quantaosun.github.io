#!/bin/bash
#This script is written by Quantao for purpose of his PhD research in UNSW, to
#run as a batch mode script to avoid the previous inconvenience of interactive job mode for a computer cluster
#katana.

#Note, this script is based on the http://www.mdtutorials.com/gmx/complex/07_equil2.html
#written by Justin Lemkul. All necessary *mdp files need to be modified before this
#script can be submitted and run.

#This script should be run at the stage that the "enegy minimization" has been done
#and the restrains been defined, satrting from the NVT equlibration step to the production
#step.

#when run this script, just use command "qsub 'this_script.pbs' "

#PBS -N gromacs
#PBS -l nodes=1:ppn=40
#PBS -l mem=20gb
#PBS -l walltime=10:00:00
#PBS -l file=10gb
#PBS -j oe
#PBS -M z5218975@ad.unsw.edu.au
#PBS -m aeb

cd $PBS_O_WORKDIR
module purge
module load gromacs/2.19.3

#NVT equlibration 
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr
gmx mdrun -deffnm nvt

#NPT equllibration

gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -n index.ndx -o npt.tpr

gmx mdrun -deffnm npt

#MD production
gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -n index.ndx -o md_0_10.tpr

gmx mdrun -deffnm md_0_10

###after the production fihised, the analysis need to be done mannually.