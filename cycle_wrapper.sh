#!/bin/sh
$dir_name = cyclic
rm -rf "./"$dir_name
mkdir dir_name
$location = $dir_name"\/it_1"
python mg_blast_wrapper_v1.8.py     -r all_AP_WPS-2_bacterium.fna -m pp_metagenome3_assembled.fasta -n location
