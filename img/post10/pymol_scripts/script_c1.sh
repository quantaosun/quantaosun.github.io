Note this is a script used to generate PyMOL script, you "CAN NOT" run 
this script directly in PyMOL, you need run this in a "Linux-like" 
terminal to get the output file as a "script.pml", which then can 
be run by PyMOL


for (( a = 1; a <=5; a++ )); 
do  
  for (( b = 1; b <=10; b++ ))
  do
     echo "cd c/Users/Administrator/Desktop/Your-Directory # changed to your own path.
           load $a.$b.pdb; # You need rename your proteins properly.
           hide lines;
           show cartoon; 
           set ray_trace_mode, 3; # color
           bg_color white
           set antialias, 2;
           select resi 1-8        # This should be the name of your ligand, here is a peptide.
           hide cartoon, sele
           show licorice, sele
           select resi 385-510    # part of the protein, chain 1.
           color blue, sele
           select resi 511-613    # part of the protein, chain 2.
           color red, sele
           rotate z, 45           # Adjust these numbers to have a focused view of your ligands
           rotate y, -60
           rotate z, 20
           rotate x, 60
           center
           zoom center, 20
           ray 1024,768
           png $a.$b png
           reinitialize" >> script.pml
  done
done
  
You need to change the "a and b values" and add or remove the
command line according to your proteins. Copy the following
to another blank .sh file or put hashtag to each of the lines
before the next line. The above can process 50 proteins which has 
been "renamed as $a.$b.pdb".

     

