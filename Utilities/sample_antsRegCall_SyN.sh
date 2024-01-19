#!/bin/bash

# call with: bash 'antsRegCall.sh' img1 img2 outDir outName
# Some starting sample parameters for rigid, affine and SyN

# Input file names should include extensions i.e. 'image1.nii.gz'

template=$1
brain=$2
outputDir=$3
regnaming=$4



antsRegistration --dimensionality 3 --float 0 \  
        --output [$outputDir/$regnaming] \  
        --interpolation Linear \    
        --use-histogram-matching 1 \  
        --transform Rigid[0.1] \  
        --metric MI[$brain,$template,1,32,Regular,0.25] \  
        --convergence [1000x500x250x100,1e-6,10] \  
        --shrink-factors 8x4x2x1 \  
        --smoothing-sigmas 3x2x1x0vox \  
        --transform Affine[0.1] \  
        --metric MI[$brain,$template,1,32,Regular,0.25] \  
        --convergence [1000x500x250x100,1e-6,10] \  
        --shrink-factors 8x4x2x1 \  
        --smoothing-sigmas 3x2x1x0vox \    
        --transform SyN[0.1,3,0] \  
        --metric CC[$brain,$template,1,4] \  
        --convergence [100x70x50x20,1e-6,10] \  
        --shrink-factors 8x4x2x1 \  
        --smoothing-sigmas 3x2x1x0vox \  

antsApplyTransforms -d 3 -i $brain -r $template -n BSpline -o $outputDir/$regnaming -t $outputDir/$regnaming"0_GenericAffine.xfm" --float
TRANSFORM=$outputDir/$regnaming"1Warp.nii.gz"
TRANSFORMaffine=$outputDir/$regnaming"0_GenericAffine.mat" # could be a .mat file or .xfm

antsApplyTransforms -d 3 -i $brain -o /$outputDir/$regnaming.nii.gz -n BSpline --verbose 1 -r $template -t $TRANSFORM -t $TRANSFORMaffine


