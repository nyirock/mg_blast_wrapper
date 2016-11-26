#!/bin/bash
dir_name="mg1_shear100_2000"
chunk_size=100
increment=50
iterations=40
rm -rf $dir_name
mkdir $dir_name
#location=$dir_name"/it_1"
format="csv,fasta"
alen="100"
metagenome=IMG\ Data/76969.assembled.fna,IMG\ Data/76969.unassembled_illumina.fna
reference="all_AP_WPS-2_bacterium.fna"
#echo $location
#python mg_blast_wrapper_v1.8_cyclic.py     -r all_AP_WPS-2_bacterium.fna -m pp_metagenome3_assembled.fasta -n $location -shear $chunk_size

#parse parameters

while test $# != 0
do
case "$1" in
    -p) filename=;;
    -c) count_flag=1;;
    -h) help_flag=1;;
    --) shift; break;;
    *) usage ;;
esac
shift # past argument or value
done

if [ "$iterations" -gt "1" ]
then
    for (( c=0; c<=iterations; c++ ))
    do
       location=$dir_name"/run_"$c
       #echo $location
       chunk_size=$(($chunk_size+$increment*$c))
       #echo $chunk_size
       python mg_blast_wrapper_v1.11.py    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
    done
else
    location=$dir_name
    python mg_blast_wrapper_v1.11.py    -r all_AP_WPS-2_bacterium.fna -m pp_metagenome3_assembled.fasta -n $location --shear $chunk_size -f $format -a $alen
fi
