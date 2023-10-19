#!/bin/bash

## run with bash '/data_/tardiflab/chris/development/scripts/github/b1correct_mtsat_Sherbrooke/T1mapping/b1map_resampleNIFTI.sh' 'sub-016_ses-5_echo-3_acq-T1w_ihmt.nii.gz' 'sub-016_ses-5_run-03_B1map.nii.gz'

# This requires minc tools and FSL
# Resample one nifti file to match another. 


refImg=${1##*/}
img=${2##*/}

tmp1=${refImg%.nii.gz}
tmp2=${img%.nii.gz}

echo "T1w input is = $refImg"
echo "B1map input is = $img"
echo "\n"


### Get a brain mask
bet $refImg mask.nii.gz -m

nii2mnc -quiet $refImg $tmp1.mnc
nii2mnc -quiet $img $tmp2.mnc
nii2mnc -quiet mask_mask.nii.gz mask.mnc

mincresample -clobber -float -like $tmp1.mnc -fill $tmp2.mnc B1map_rs.mnc 

minccalc -float -expr "clamp(A[0]/100 * A[1],0,3)" B1map_rs.mnc mask.mnc B1map_rsMasked.mnc

mnc2nii -quiet B1map_rsMasked.mnc B1map_rs.nii

rm *.mnc

echo "Done"
echo "\n"


