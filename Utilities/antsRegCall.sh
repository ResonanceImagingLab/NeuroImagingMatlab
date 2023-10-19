#!/bin/bash

# call with: bash '/data_/tardiflab/chris/development/scripts/antsRegCall.sh'

fixed=$1
moving=$2
outputDir=$3
regnaming=$4

antsRegistration -d 3 \
                 --float 1 \
                 --verbose 1 \
                 --use-histogram-matching 1 \
                 -w [ 0.01,0.99 ] \
                 -z 1 \
                 -t Rigid[ 0.1 ] \
                 --metric MI[$fixed.mnc.gz,$moving.mnc.gz,1,32,Regular,0.25 ] \
                 --convergence [ 100x50x250x100,1e-6,10 ] \
                 --shrink-factors 6x4x2x1 \
                 --smoothing-sigmas 4x2x1x0 \
                 --minc 1 \
                 -o [$outputDir/$regnaming]
                 
antsApplyTransforms -d 3 -i $moving.mnc.gz -r $fixed.mnc.gz -n BSpline -o $outputDir/$regnaming.mnc -t $outputDir/$regnaming"0_GenericAffine.xfm" --float

