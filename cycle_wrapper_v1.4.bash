#!/bin/bash


while test $# != 0
do
case "$1" in
    -f|--filename) filename="$2" ; shift ;;
    -p|--parameters) parameters="$2" ; shift ;;
esac
shift # past argument or value
done

#echo $filename
#echo $parameters

source $parameters

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
       #python $filename    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
       python $filename    -r $reference -m "$metagenome" -n $location -f $format -a $alen
       
       ## no shear
    done
else
    location=$dir_name
    #python $filename    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
    
    ## no shear
    python $filename    -r $reference -m "$metagenome" -n $location -f $format -a $alen
    
fi
