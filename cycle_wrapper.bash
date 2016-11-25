#!/bin/bash
dir_name="cyclic"
chunk_size=100
increment=50
iterations=5
rm -rf $dir_name
mkdir $dir_name
location=$dir_name"/it_1"
#echo $location
#python mg_blast_wrapper_v1.8_cyclic.py     -r all_AP_WPS-2_bacterium.fna -m pp_metagenome3_assembled.fasta -n $location -shear $chunk_size

for (( c=0; c<=iterations; c++ ))
do  
   location=$dir_name"/it_"$c
   #echo $location
   chunk_size=$(($chunk_size+$increment*$c))
   #echo $chunk_size
   python mg_blast_wrapper_v1.8_cyclic.py     -r all_AP_WPS-2_bacterium.fna -m pp_metagenome3_assembled.fasta -n $location --shear $chunk_size
done
