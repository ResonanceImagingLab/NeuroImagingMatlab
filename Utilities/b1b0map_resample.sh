#!/bin/sh

# Written by Christopher Rowley
# Use minctools to resample B1 and B0 images to a reference using minc tools
################ MY CODE ##############
# specify inputs
output_base=$4;
no_MT=$3;
B0_field=$2;
B1=$1;

## normalize the b1map 
a_b1=80; #`mincinfo -attvalue acquisition:flip_angle $B1`;chomp($a_b1); # usually is 80 in case it gets removed from header
normb1=$B1"_normalized.mnc";

echo "\n--FA in degrees for B1map: $a_b1\n\n";

minccalc -float -nocheck_dimensions -expr "clamp(A[0] / ($a_b1 * 10),0,3)" $B1 $normb1


## resample the b1map to the same dimensions at the mt image
b1field_rs=$output_base"_b1field.mnc";
mincresample -clobber -float -like $no_MT -fill $normb1 $b1field_rs

b0field_rs=$output_base"_b0field.mnc";
mincresample -clobber -float -like $no_MT -fill $B0_field $b0field_rs
#
#
#
#
#
#
#
#
##




