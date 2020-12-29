"Detaied Gromacs protein-ligand compelx water soluution simulation tutorial."
 By Quantao, posted on 29, December 2020.

#before you use these commands, you should reference script-number 1
#and set the necessary environment such as fetch pdb."
#This is a command-line assembly for Gromacs solution simulation of a protein-ligand complex. 
This tutorial is based on "Justin A. Lemkul (https://wwww.thelemkullab.com)"
but with modification, in the original tutorial, Avogadro was used to deal with
the small molecule, but here we use openbable.

The most I want to emphasis is there is a fundamental problem the original tutorial
failed to touch on. Justin‘s tutorial chooses a nice pdb structure so the life is 
much easier, but there are many targets of interests that are not so good, in terms of having
broken protein backbone or modified amino acid that not covered by the general force failed.
"What we do here is to use a homology model instead as a cheat to get rid of the problem with
swiss-MODELER". For the modified amino acid, if it is far from the ligand-binding pocket, a 
cheat way is "just mutant back to the unmodified or natural version". If you happen to have to deal 
with a modified amino acid near or even inside the binding pocket, that is out of the scope of 
this tutorial.
#Read carefully
#and follow this step-by-step protocol, with some of your common sense of logic, you should be 
#able to apply these in your simulation towards protein-small molecule complex. 

#There are many
#automatic workflows or web service available to allow you do the simulation in a "black box" manner
#but with more convenience comes with more risk that once there is an error you have nowhere to 
#start to deal with since it is a "black box". This protocol may seem a bit tedious but it is 
#quite reliable since it has been split into pieces, once there is an error, you know where the 
#erro locate and could solve it easily. There is no easy life either way! 
Again, please be aware THIS IS SCIPT NUMBER 2，READ "SCRIPT NUMBER 1" FIRST. 

  Commands                                                                          Environment

1.fetch 6i5i(4ylj)  #please alias "fetch" as described in "script number 1" --------# 1.terminal
2.vim 6i5i (4ylj)  #please check and write down the 3-letter name of the ligand     # 2.terminal
3.pymol 6i5i.pdb(4ylj)                                                              # 3.terminal
4.remove chain B, C, D  ----------------------------------------------------------- # 4.pymol
5.remove solvent                                                                    # 5.pymol
6.set seq_view,1                                                                    # 6.pymol
7.select so4,peg4,  #click with shift to select all other co-factors.               # 7.pymol
8.remove sele                                                                       # 8.pymol
# This is the point when you decide if you should head to Swiss-Modeler, if your protein is 
#consistent with no interruption in the sequence, that is good and you can move on to step9.
#but if there is any broken backbone, please download the *.fasta from RCSB and paste it to
# swiss-modeler to generate a model.pdb based on the protein itself. Then load that model.pdb
#into pymol to align to the original protein-ligand complex, followed by deleting the original
#protein, save the ligand with the model protein together as the clean version of pdb to use
#in step 9. If there is a far away modified amino acid, please change it back to the natural
#version, and save it as the clean version to use in the next step.
9.save as "6I5I_clear.pdb(4YLJ_clearn.pdb)"                                         # 9.pymol
10.grep H3E 6I5I_clean.pdb > h3e.pdb("grep 4E1 4YLJ_clearn > 4e1.pdb")------------- #10.terminal
grep -v H3E 6I5I_clean.pdb > 6I5I_clean2.pdb                                        #11.terminal

Mackerell lab webisite to -------------------------------------------------------   #website-1=
#"MacKerell lab website"
download charmm36-mar2019.ff.tgz                                                    #12.website-1
tar -zxvf charmm36-mar2019 -------------------------------------------------------  #13.terminal
gmx pdb2gmx -f 6I5I_clean2.pdb -o 6I5I_processed.gro -----------------------------  #14.gromacs
"1"  "1" # Gromacs will ask you select an option twice, select 1 for both.          #15.gromacs

obabel -ipdb h3e.pdb -omol2 h3e # the output is on screen, copy it. ----------------#16.terminal
touch h3e.mol2                                                                      #17 terminal
vim h3e.mol2, #use "i" to enter edit mode, paste obabel result.   ------------------#18.terminal

download sort_mol2_bonds.pl ------------------------------------------------------- #19.website-2=
#"www.mdtutorials.com/gmx/complex/02_topology.html
perl sort_mol2_bonds.pl h3e.mol2 h3e_fix.mol2 # manage the bond orders -------------#20.terminal
# if you use a remote server and you don't have sudo permission to deal with potential
#errors at this step, you could do it locally and copy the result up to the server.
CGenFF offical site 
upload h3e_fix.mol2, download "h3e_fix.str"---------------------------------------- #21.website-3=
#"https://cgenff.umaryland.edu"

Mackerell lab website to --------------------------------------------------------- #   website-1
download cgenff_charmtogmx.py3_nx2.py --------------------------------------------  #22.website-1
#be aware in your computer, it is not necessarily python3, it is not necessarily 
#networkx2, it might be pyhton2 and networkx1. The website also provides two other
# *py to download.  if you have a networkx3, you need to remove it first and 
#install networkx2.3. 
python3 cgenff_charmtogmx_py3_nx3.py H3E h3e_fix.mol2 "h3e_fix.str" charmm36-mar2019.ff #23.terminal

#similar to step 20, if you use a remote server, but you are not allowed to install or
#change the networkx version, please do it locally and copy the result to the server.

gmx editconf -f h3e_ini.pdb -o h3e.gro ------------------------------------------------ -24.gromacs

touch complex.gro --------------------------------------------------------------------- -25.terminal
cat 6I5I_processed.gro > complex.gro -------------------------------------------------- -26.terminal
vim h3e.gro and copy all "H3E lines" -------------------------------------------------- -27.terminal
vim complex.gro, insert "H3E lines" before last line box vector ----------------------- -28.terminal
vim complex.gro, change the atom numbers to an increased number. ----------------------- -29.terminal

Insert "; Include ligand topology 
        #include "h3e.itp" "  to topol.top 

        before ";Include water topology"  -------------------------------------------- -30.terminal

Insert "; Include ligand parameters 
        #include "h3e.prm" "  to topol.top 

        before "[moleculetype]"          --------------------------------------------- -31.terminal


Insert "H3E         1"   to topol.top 

        before "[molecules]"          ------------------------------------------------ -32.terminal

gmx editconf -f complex.gro -o newbox.gro -bt dodecahedron -d 1.0 -------------------- -33.gromacs

gmx solvate -cp newbox.gro -cs spc216.gro -p topol.top -o solv.gro ------------------- -34.gromacs

download ions.mdp  ------------------------------------------------------------------- -35. website-2

gmx grompp -f ions.mdp -c solv.gro -p topol.top -o ions.tpr -------------------------- -36.gromacs

gmx genion -s ions.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral ---- -37.gromacs

#gromacs will ask you to choose, choose 15 （SOL）
download em.mdp  ------------------------------------------------------------------- -38. website-2

gmx grompp -f em.mdp -c solv_ions.gro -p topol.top -o em.tpr ----------------------- -39. gromacs

gmx mdrun -v -deffnm em ----------------------------------------------------------- -40. gromacs

gmx make_ndx -f h3e.gro -o index_h3e.ndx ------------------------------------------------    -41. gromacs

# gromacs will give a list to let you choose. type as next:
 > 0 & ! a H* # choose all atoms but hydrogen.
 > q # save and quit.
gmx genrestr -f h3e.gro -n index_h3e.ndx -o posre_h3e.itp -fc 1000 1000 1000 -------          -42. gromacs

Insert "; Ligand position restraints
         #ifdef POSRES
         #include "posre_jz4.itp"
          #endif "  to topol.top 

        before "; Include water topology"

        after what has been inserted at "step30"          --------------------------          -43.terminal

#here we only apply constrains to ligand, surely you could apply on both ligand and
# protein but it is not discussed here, usually for a small to medium-size structure,
#apply to constrain on ligand is enough.

gmx make_ndx -f em.gro -o index.ndx -------------------------------------------------------- -44. gromacs

> 1 | 13
> q    merge the "Protein" and "H3E" # This is purely for the need of later nvt.mdp

download nvt.mdp -------------------------------------------------------------------         -45.website-2

vim nvt.mdp, find "tc-grps = Protein_JZ4 Water_and_ions " --------------------------         -46.terminal
replace Protein_JZ4 with our "Protein_H3E" -----------------------------------------         -47.terminal

gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr------         -48.gromacs

gmx mdrun -deffnm nvt              -------------------------------------------------         -49.gromacs
#wait until the finish usually takes around 5 minutes 

download npt.mdp -------------------------------------------------------------------         -50.website-2

vim npt.mdp, find "tc-grps = Protein_JZ4 Water_and_ions " --------------------------         -51.terminal
replace Protein_JZ4 with our "Protein_H3E" -----------------------------------------         -52.terminal

gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -n index.ndx -o npt.tpr -53. gromacs

gmx mdrun -deffnm npt --------------------------------------------------------------------  --54.gromacs

#wait until the finish usually takes around 5 minutes 

download md.mdp -------------------------------------------------------------------         -55.website-2

vim md.mdp, find "tc-grps = Protein_JZ4 Water_and_ions " --------------------------         -56.terminal
replace Protein_JZ4 with our "Protein_H3E" -----------------------------------------        -57.terminal
#for the last production, if you are using a remote gromacs, you could do as above in
# a terminal, but since it will be a very long time, and your ssh window maybe 
#disconnected when exceeding sometime, so I recommend you do as a batch job or use "X2GO"
# which is much reliable even you close the window, when you come back and re-login 
#to X2GO your job will be still running. If you just use your laptop or a local working 
#station then should be fine. Just leave it and set up a proper heater-cooler if necessary.
gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -n index.ndx -o md_0_10.tpr--------- -58. gromacs

gmx mdrun -deffnm md_0_10 ------------------------------------------------------------------ --59. gromacs.

Wait until it finishes, based on your CPU numbers, it may take hours or even days to finish the 
job. "if you want a quicker simulation, please modify the md.mdp file to lower the nstps value
from 10 ns to 5 or 1"

###################################################### THE END ######################################






