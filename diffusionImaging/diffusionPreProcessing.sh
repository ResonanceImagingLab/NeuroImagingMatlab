#!/bin/bash


# DWI preprocessing steps
# Original script by Mazen Elkhayat - 03/11/2022
# Edits by Christopher Rowley 2024/25


# This largely relies on the tools from FSL and MRtrix(?).

# You need acqparams.txt which gives the information on readout and echotime.
# It might contain the following:
#0 1 0 0.0652
#0 -1 0 0.0652

#########################################################################################
# For linux installation:
# https://www.mrtrix.org/download/linux-anaconda/
# conda install -c mrtrix3 mrtrix3
# conda update -c mrtrix3 mrtrix3

# Note that MRtrix's call to 'eddy' requires gpu. You can either:
# make sure you have a graphics card and install CUDA9 https://gist.github.com/DaneGardner/accd6fd330348543167719002a661bd5
# or modify and call FSL's eddy_openmp program separately. https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/eddy(2f)UsersGuide.html


############## MRtrix3: #####################

imgName='fn'
imgName='Multishell_DTI_UK_Biobank_1'

## Convert nifti to mif and include diffusion information
# https://mrtrix.readthedocs.io/en/latest/concepts/dw_scheme.html#importing-the-dw-gradient-table
mrconvert $imgName.nii.gz -fslgrad $imgName.bvec $imgName.bval combined.mif


## Denoise:
dwidenoise combined.mif combined_den.mif 

## Check 
mrview combined.mif combined_den.mif

## Gibbs ringing:
mrdegibbs combined_den.mif combined_den_unr.mif 
  # Axes = 0,1 is axial (transverse) slices
  # Axes =  0,2 is coronal slices
  # Axes = 1,2 is sagittal slices
  # Most often diffusion data is acquired using transverse slices

## You can inspect the results using:
mrcalc combined_den.mif combined_den_unr.mif -subtract residualUnringed.mif
mrview combined_den_unr.mif residualUnringed.mif


## Extract B0
dwiextract combined_den_unr.mif - -bzero | mrmath -mean mean_b0_AP.mif -axis 3

## Get reverse encoded values:
mrconvert b0_PA_folder/ - | mrmath -mean mean_b0_PA.mif -axis 3

## Combine to 1 file:
mrcat mean_b0_AP.mif mean_b0_PA.mif -axis 3 b0_pair.mif

############ Do Eddy and Motion Correction:
# https://mrtrix.readthedocs.io/en/latest/reference/commands/dwifslpreproc.html

## If only a single phase encoding is used: - Can find TotalReadoutTime in json (usually)
dwifslpreproc combined_den_unr.mif DWI_out.mif -rpe_none -pe_dir ap -readout_time 0.040356

## If multiple phase encodes are used:
dwifslpreproc combined_den_unr.mif DWI_out.mif -rpe_pair -se_epi b0_pair.mif -pe_dir ap -readout_time 0.072 -align_seepi


######################################

## Correct for bias fields with N4
dwibiascorrect ants DWI_out.mif DWI_out_unbiased.mif -bias bias.mif

## Create a mask:
dwi2mask DWI_out_unbiased.mif mask_dwi.mif

mrview mask_dwi.mif -colourmap 2


## Fit a tensor to the data:
dwi2tensor -mask mask_dwi.mif DWI_out_unbiased.mif outputTensor.mif

## extract from tensor
tensor2metric \
  -adc tensorMap/adc.mif \
  -fa tensorMap/fa.mif \
  -ad tensorMap/ad.mif \
  -rd tensorMap/rd.mif \
  -value tensorMap/eigenValue.mif \
  -vector tensorMap/eigenVector.mif \
  -mask mask_dwi.mif \
  outputTensor.mif

# -adc   compute the mean apparent diffusion coefficient (ADC) of the diffusion tensor. (sometimes also referred to as the mean diffusivity (MD))
# -fa    compute the fractional anisotropy (FA) of the diffusion tensor.
# -ad   compute the axial diffusivity (AD) of the diffusion tensor. (equivalent to the principal eigenvalue)
# -rd image compute the radial diffusivity (RD) of the diffusion tensor. (equivalent to the mean of the two non-principal eigenvalues)
# -cl image compute the linearity metric of the diffusion tensor. (one of the three Westin shape metrics)
# -cp image compute the planarity metric of the diffusion tensor. (one of the three Westin shape metrics)
# -cs image compute the sphericity metric of the diffusion tensor. (one of the three Westin shape metrics)
# -value image compute the selected eigenvalue(s) of the diffusion tensor.
# -vector image compute the selected eigenvector(s) of the diffusion tensor.
# -num sequence specify the desired eigenvalue/eigenvector(s). Note that several eigenvalues can be specified as a number sequence. For example, ‘1,3’ specifies the principal (1) and minor (3) eigenvalues/eigenvectors (default = 1).
# -modulate choice specify how to modulate the magnitude of the eigenvectors. Valid choices are: none, FA, eigval (default = FA).
# -mask image only perform computation within the specified binary brain mask image.

###########################################################################

# This section produces unregistered, but topup- and eddy current-corrected DTI

# Locate two images with no diffusion gradient (b0) and another with opposite phase-encoding
# In the data I used, usually the first three images were b0, and in the blipped diffusion volume, it was the first one
# Extract images from volumes
fslroi exam_15463__DTI_30dirs_4T2_b700_20230602143744_11.nii DTI_700 0 3
fslroi exam_15463_REV_POL__DTI_30dirs_4T2_b700_20230602143744_1111.nii DTI_blipped_700 0 1

# If there is more than 1 b0 image
# Average images
fslmaths DTI_700 -Tmean DTI_700

# Merge the (average) b0 and the blipped b0
fslmerge -t merged_b0 DTI_700 DTI_blipped_700

# Run through topup to correct for susceptibility distortions
# acqparams.txt should be in the directory
# I believe b02b0.cnf comes automatically in the fsl directory with the installation of fsl, but if not, please let me know
topup --imain=merged_b0 \
      --datain=acqparams.txt \
      --config=b02b0.cnf \
      --out=topup_merged_b0 \
      --iout=topup_merged_b0_iout \
      --fout=topup_merged_b0_fout

# Average the topup output b0 images
fslmaths topup_merged_b0_iout -Tmean merged_b0_avg

# This creates a binary brain mask with the same file name as the output with _mask at the end
bet merged_b0_avg merged_b0_brain -m -f 0.2

# Correct for eddy currents, using this mask
eddy --imain=exam_15463__DTI_30dirs_4T2_b700_20230602143744_11.nii \
     --mask=merged_b0_brain_mask \
     --index=index.txt \
     --acqp=acqparams.txt \
     --bvecs=exam_15463__DTI_30dirs_4T2_b700_20230602143744_11.bvec \
     --bvals=exam_15463__DTI_30dirs_4T2_b700_20230602143744_11.bval \
     --fwhm=0 \
     --topup=topup_merged_b0 \
     --flm=quadratic \
     --out=eddy_700 \

# This section tries to run dtifit after the corrections then register to MNI 152, but runs into an issue
dtifit --data=eddy_700 --mask=merged_b0_brain_mask  \
  --bvecs=exam_15463__DTI_30dirs_4T2_b700_20230602143744_11.bvec --bvals=exam_15463__DTI_30dirs_4T2_b700_20230602143744_11.bval --out=dti_fitted_700

# Extract eddy corrected b0 image(s)
fslroi eddy_final eddy_final_b0 0 3
# Average eddy corrected b=0 images if more than 1
fslmaths eddy_final_b0 -Tmean eddy_final_avg_b0

# Register eddy corrected avg b0 images to scanner space T1W 
epi_reg --epi=eddy_final_avg_b0 --t1=T1W --t1brain=T1W_masked --out=eddy_final_avg_b0_2_T1W_scanner_space
# Register output to T1W MNI 152 image
flirt -in eddy_final_avg_b0_2_T1W_scanner_space.nii.gz -applyxfm -init T1W.mat -out eddy_final_avg_b0_T1_MNI_152.nii -ref T1W_MNI_152.nii -paddingsize 0.0 -interp sinc -v
# Register 4D DWI volume to T1W MNI_152 (does not work, no matrix from scanner space to MNI_152)
flirt -in DTI -applyxfm -init eddy_final_avg_b0_2_T1W_scanner_space.mat -out DWI_2_T1W_MNI_152 -ref T1W_MNI_152

# Alternative we were using: Registering eddy corrected b0 average image to T1W MNI 152, then using the matrix to register the whole diffusion volume to T1W MNI 152
epi_reg --epi=eddy_final_avg_b0 --t1=T1W_MNI_152 --t1brain=T1W_MNI_152_masked --out=eddy_final_avg_b0_2_T1W_MNI_152_epi_reg
flirt -in DTI -applyxfm -init eddy_final_avg_b0_2_T1W_MNI_152_epi_reg.mat -out DWI_2_T1W_MNI_152_epi_reg -ref T1W_MNI_152

# This might be a bit cyclical but this is what I was using, if you have any recommendations, please let me know!
# Extract b0 images from DWI_2_T1W_MNI_152_epi_reg 
fslroi DWI_2_T1W_MNI_152_epi_reg b0_DWI_2_T1W_MNI_152_epi_reg 0 3
# Average registered eddy corrected b0 images
fslmaths b0_DWI_2_T1W_MNI_152_epi_reg -Tmean tmean_b0_DWI_2_T1W_MNI_152_epi_reg
# Create binary mask
bet tmean_b0_DWI_2_T1W_MNI_152_epi_reg tmean_brain_b0_DWI_2_T1W_MNI_152_epi_reg -m -f 0.2
# Run DTIFIT using this mask
dtifit --data=dti_data_700_reg --mask=tmean_brain_b0_DWI_2_T1W_MNI_152_epi_reg_mask  \
  --bvecs=dti_data_700.bvec --bvals=dti_data_700.bval --out=dti_fitted_700_reg