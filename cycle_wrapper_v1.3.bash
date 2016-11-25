#!/bin/bash


while test $# != 0
do
case "$1" in
    -p|--parameters) filename="$2" ; shift ;;
esac
shift # past argument or value
done



source $filename

#echo $filename

rm -rf $dir_name
mkdir $dir_name


if [ "$iterations" -gt "1" ]
then
    for (( c=0; c<=iterations; c++ ))
    do
       location=$dir_name"/run_"$c
       #echo $location
       chunk_size=$(($chunk_size+$increment*$c))
       #echo $chunk_size
       python mg_blast_wrapper_v1.12.py    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
    done
else
    location=$dir_name
    python mg_blast_wrapper_v1.12.py    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
fi
