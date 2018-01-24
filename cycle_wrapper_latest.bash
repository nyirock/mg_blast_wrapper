#!/bin/bash
python=`which python2`
#function chunk_increment_fn {
#    increment=$chunk_increment
#    for (( c=0; c<=iterations; c++ ))
#    do

#       #echo $location
#       
#       #echo $chunk_size
#       #echo $chunk_size
#       #python $filename    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
#       eval $script $options $chunk_size
#       chunk_size=$(($chunk_size+$increment))
#    done
#}


while test $# != 0
do
case "$1" in
    -f|--filename) filename="$2" ; shift ;;
    -p|--parameters) parameters="$2" ; shift ;;
esac
shift # past argument or value
done

#checking command line arguments integrity

if [ -z "$filename" ]
then
    echo "No python script specified. Please enter python script name as -f parameter."
    exit
fi

if [ -z "$parameters" ]
then
    echo "No parameters file specified . Please enter parameters file name as -p parameter."
    exit
fi

#echo $filename
#echo $parameters

metagenome=""
reference=""
iterations=""
alen=""
iden=""
e_val=""
shear=""
format=""
e_val_lst=""
debugging=""


source $parameters


#checking if metagenome and reference parameters are set

if [ -z "$metagenome" ]
then
    echo "Metagenome file name(s) not specified in parameters file."
    exit
fi

if [[ ( ( "$iterations" != "true" && -z "$ref_lst" ) ||  -n "$reference" ) && ( ( "$iterations" == "true" && -n "$ref_lst") ||  -z "$reference" ) ]] 
then
#    echo $iterations
#    echo $ref_lst
#    echo $reference
    echo "Reference file name(s) not specified in parameters file."
    exit

fi

#checking if cycling over reference option is enabled
if [[ -n "$ref_lst" && "$iterations" == "true"  ]]
then
    #echo "triggered ref_lst option"
    req_opt=' -m '$metagenome
elif [ -n "$reference" ]
then
#    echo "REFERENCE"
    req_opt=' -m '$metagenome' -r '$reference
fi


#echo $metagenome

if [ "$debugging" = "true" ] 
then
    req_opt=$req_opt' --debugging'
fi

if [ "$continue_from_previous" = "true" ] 
then
    req_opt=$req_opt' --continue_from_previous'
fi

if [[ "$continue_from_previous" = "true" && "$skip_blasting" = "true" ]] 
then
    req_opt=$req_opt' --skip_blasting'
fi


#echo $filename


if [ -z "$dir_name" ]
then
    echo "Project name not specified in parameters file. Using default"
    dir_name="output"
    #exit    
fi

#eval 'find '"$dir_name"' -type f -name ".*" -delete'

if [ -z "$continue_from_previous" ]
then
    rm -rf $dir_name

    mkdir $dir_name

fi



if [ -z "$alen" ]
    then
        alen_opt=""
    else
        alen_opt=" -a "$alen
fi

if [ -z "$iden" ]
    then
        iden_opt=""
    else
        iden_opt=" -i "$iden
fi

if [ -z "$e_val" ]
    then
        e_val_opt=""
    else
        e_val_opt=" -e "$e_val
fi

if [ -z "$shear" ]
    then
        shear_opt=""
    else
        shear_opt=" --shear "$shear
fi

if [ -z "$format" ]
    then
        format_opt=""
    else
        format_opt=" -f "$format
fi

if [ -z "$iterations" ]
    then
        eval $python' '$filename' -n '$dir_name' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
elif [[ "$iterations" -gt 1  &&  "$shear_increment" -gt 0 ]] 
    then
        for (( c=0; c<=$iterations; c++ ))
        do
           location=$dir_name"/run_"$c
           #echo $location
           shear_opt=" --shear "$shear
           shear=$(($shear+$shear_increment))
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
        done
        
elif [[ -n "$shear_lst" && "$iterations" == true ]]
    then
        c=0
        for shear in $shear_lst
        do
           location=$dir_name"/run_"$c
           #echo $location
           shear_opt=" --shear "$shear
           
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
           c=$(($c+1))
#           if [ "$c" -gt "$iterations" ]
#                then
#                exit
#           fi
        done

#covering the case of using %        
elif [[ "$iterations" -gt 1  &&  "$(echo $alen_increment | grep -o -E '^[0-9]+')" -gt 0 ]]
    then
#NUMBER=$(echo "I am 999 years old." | grep -o -E '[0-9]+')
        if [ "$(echo $alen | grep -o -E '^[0-9]+')" == $alen ] #absolute value is passed
            then
                $alen_increment=$(echo $alen_increment | grep -o -E '^[0-9]+')
                for (( c=0; c<=$iterations; c++ ))
                do
                   location=$dir_name"/run_"$c
                   #echo $location
                   alen_opt=" -a "$alen
                   alen=$(($alen+$alen_increment))
                   #echo $chunk_size
                   eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
                done


            elif [ "$(echo $alen_increment | grep -o -E '[%]$+')" == "%" ] #percentage is used instead
            then
                abs_alen=$(echo $alen | grep -o -E '^[0-9]+')
                abs_alen_inc=$(echo $alen_increment | grep -o -E '^[0-9]+')
                for (( c=0; c<=$iterations; c++ ))
                do
                   location=$dir_name"/run_"$c
                   #echo $location
                   alen_opt=" -a "$abs_alen"%"
                   abs_alen=$(($abs_alen+$abs_alen_inc))
                   #echo $chunk_size
                   eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
                done
        fi

elif [[ -n "$alen_lst" && "$iterations" == true ]]
    then
        c=0
        for alen in $alen_lst
        do
           location=$dir_name"/run_"$c
           #echo $location
           alen_opt=" -a "$alen
           
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
           c=$(($c+1))
#           if [ "$c" -gt "$iterations" ]
#                then
#                exit
#           fi
        done
        

elif [[ "$iterations" -gt "1" && "$iden_increment" -gt "0" ]]
    then
        for (( c=0; c<=$iterations; c++ ))
        do
           location=$dir_name"/run_"$c
           #echo $location
           iden_opt=" -i "$iden
           iden=$(($iden+$iden_increment))
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
        done
        
elif [[ -n "$iden_lst" && "$iterations" == true ]]
    then
        c=0
        for iden in $iden_lst
        do
           location=$dir_name"/run_"$c
           #echo $location
           iden_opt=" -i "$iden
           
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
           c=$(($c+1))
#           if [ "$c" -gt "$iterations" ]
#                then
#                exit
#           fi
        done

        
elif [[   -n "$e_val_lst" && "$iterations" == true  ]]
    then
        c=0
        for e_val in $e_val_lst
        do
           location=$dir_name"/run_"$c
           #echo $location
           e_val_opt=" -e "$e_val
           
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
           c=$(($c+1))
#           if [ "$c" -gt "$iterations" ]
#                then
#                exit
#           fi
        done
elif [[ -n "$ref_lst" && "$iterations" == true  ]]     
    then
        c=0
        for ref in $ref_lst
        do
           location=$dir_name"/run_"$c
           #echo $location
           ref_opt=" -r "$ref
           #echo "elif clause triggered"
           #echo $chunk_size
           eval $python' '$filename' -n '$location' '$ref_opt' '$req_opt' '$alen_opt' '$iden_opt' '$e_val_opt' '$shear_opt' '$format_opt
           c=$(($c+1))
#           if [ "$c" -gt "$iterations" ]
#                then
#                exit
#           fi
        done

fi




#script='python '$filename
##options='-r '$reference' -m '"$metagenome"' --shear '$chunk_size' -f '$format' -a '$alen
#options='-r '$reference' -m '"$metagenome"

##handling --shear clause
#if [ "$shear" = true ]
#then
#    
#    if [ -z "$chunk_size" ]
#    then
#        echo "Chunk size is not specified for --shear argument"
#        exit
#    else
#        if [ ( "$iterations" -gt "1" ) -a ( "$chunk_increment" -gt "0"  ) ]
#        then
#            location=$dir_name"/run_"$c
#            options=' -n '$location' '$options 
#            chunk_increment_fn
#        fi
#        if [ ( "$iterations" -lt "2" ) -o ( -z "$iterations" ) ]
#        then
#            options=$options' --shear '$chunk_size
#        fi
#    fi
#fi



##eval $script $options


#if [ "$iterations" -lt "2" -o ]
#then
#    location=$dir_name"/run_"$c
#    options=' -n '$location' '$options
#    if [ ]
#    then
#        chunk_increment_fn
#    fi
#else
#    location=$dir_name
#    options=' -n '$location' '$options
#    #python $filename    -r $reference -m "$metagenome" -n $location --shear $chunk_size -f $format -a $alen
#    eval $script $options $chunk_size
#fi
