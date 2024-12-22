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