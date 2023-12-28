#!/bin/sh


## TO DO -> does prescan normalize show up?
# add in the series number


## The goal of this script is to use the minc header information 
## to rename the file

# This second version takes two inputs. 
# The first is the directory of the original minc files,
# the second input in the output directory of the renamed files

# Created by Christopher Rowley 2021
# non-gzip
#############################################################################

## Quick check of the inputs and check ending slash consistency (don't want it)
inputs=$(echo "$1" | sed 's:/*$::')
outputs=$(echo "$2" | sed 's:/*$::')

echo "The input directory is $inputs"
echo "The output directory is $outputs"

## Generate text file of header names
for filename in $inputs/*.mnc; do 
OUTPUT=$(mincheader $filename | grep -i acquisition:series_description)
echo "${OUTPUT}"
done > $outputs/rename.txt

# remove blankspace
cat $outputs/rename.txt | tr -d "[:blank:]" > $outputs/rename2.txt


## Remove extra characters
sed -i -e 's/acquisition:series_description="//g' $outputs/rename2.txt
sed -i -e 's/";//g' $outputs/rename2.txt

## Create text document with filenames
for filename in $inputs/*.mnc; do 
echo "${filename}"
done > $outputs/names.txt

## At this point, note the name.txt has full file path
# rename2.txt has ONLY the acquisition title

## Combine these two into a command
# The while loop checks to see if a file exists with that name, if so, then it adds a number
paste $outputs/names.txt $outputs/rename2.txt | while IFS=$'\t' read -r names renames2; do 
    num=0
    while [ -e "$outputs/$renames2.mnc" ]; do
        if [ $num -gt 0 ]
        then
            # remove number added in last iteration, which happens when num > 0
            renames2="${renames2::-1}"
        fi
        num=$(( $num + 1 ))
        renames2="$renames2$num"
    done
    echo $renames2   
    sleep 0.5
    cp -i -- "$names" "$outputs/$renames2.mnc"
done

rm $outputs/names.txt
rm $outputs/rename.txt
rm $outputs/rename2.txt




