#!/bin/bash
# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )
function read_counts {
    count=`zgrep -c "^@M02031:" *.gz|tr ":" "\t"`
    folder=`pwd|awk -F  '/' {'print $(NF-3)'}`
    filename="_raw_counts_analytics.tsv"
    #echo "$count"
    echo "$count">$folder$filename
}
function read_sizes {
    count=`stat --printf="%n\t%s\n" *.gz`
    folder=`pwd|awk -F  '/' {'print $(NF-3)'}`
    filename="_raw_sizes_analytics.tsv"
    #echo "$count"
    echo "$count">$folder$filename
}
function usage {
filename=`basename $BASH_SOURCE`
    echo -e "Usage: "$filename" [OPTION]...\n"
    echo -e "Place the script into the folder containing raw .gz files and run the script to extract reads information"
	echo 'Program extracts raw reads metadata and stores it in the tab-delimited tsv file ending in _analytics.tsv'
    echo -e "By default raw reads sizes are extracted\n"
    echo -e "Arguments are:\n"
    echo -e "\t -c \t outputs read counts into _raw_sizes_analytics.tsv\n"
    echo -e "\t -s \t outputs file sizes into _raw_counts_analytics.tsv\n"
    echo -e "\t -h \t help\n"
	exit
}
size_flag=0
count_flag=0
help_flag=0
while test $# != 0
do
case "$1" in
    -s) size_flag=1;;
    -c) count_flag=1;;
    -h) help_flag=1;;
    --) shift; break;;
    *) usage ;;
esac
shift # past argument or value
done
if [ $help_flag -eq 1 ]
then
usage 
exit
fi
if [ $count_flag -eq 0 ] && [ $size_flag -eq 0 ]
then
    read_sizes
elif [ $count_flag -eq 1 ] && [ $size_flag -eq 0 ]
then
    read_counts
elif [ $count_flag -eq 0 ] && [ $size_flag -eq 1 ]
then
    read_sizes
else
    usage
fi
