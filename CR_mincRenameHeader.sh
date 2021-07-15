#!/bin/sh


## The goal of this script is to use the minc header information 
## to rename the file

# Created by Christopher Rowley 2021


## Generate text file of header names
for filename in *.mnc.gz; do 
OUTPUT=$(mincheader $filename | grep -i acquisition:series_description)
echo "${OUTPUT}"
done > rename.txt

# remove blankspace
cat rename.txt | tr -d "[:blank:]" > rename2.txt


## Remove extra characters
sed -i -e 's/acquisition:series_description="//g' rename2.txt
sed -i -e 's/";//g' rename2.txt

## Create text document with filenames
for filename in *.mnc.gz; do 
echo "${filename}"
done > names.txt


## Combine these two into a command
# The while loop checks to see if a file exists with that name, if so, then it adds a number
paste names.txt rename2.txt | while IFS=$'\t' read -r names renames2; do 
    num=0
    while [ -e "$renames2.mnc.gz" ]; do
        num=$(( num + 1 ))
        renames2="$renames2$num"
    done
    echo $renames2   
    sleep 0.5
    cp -i -- "$names" "$renames2.mnc.gz"
done

rm names.txt
rm rename.txt
rm rename2.txt




