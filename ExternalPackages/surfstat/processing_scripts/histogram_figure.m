% make histograms of image values and show that 3 gaussians fit the data
clear all;

% *****INPUT*****
% *****HERE*****

% Enter the path you want the output files to write to:
path = '/Volumes/BOCK_DATA/Bipolar_Study/Control/April_30_2014/jist/exp-0000/';
save_path = '/Users/christopherrowley/Desktop/intensity_figure/';
% ***Files***

combined_GM= 'exp-0000-AAAAAAAAAAAABA/threshold_to_binary_mask/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_mems_lcr_gm_cgb_L2P_calc_calc_binmask_calc_binmask.nii';
ratio_img = 'exp-0000-AAA/IntensityRangeNormalization/bravo_standard_calc_calc_norm.nii';
Masked_ratio_img = 'exp-0000-AAAAAB/Image_Calculator/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc.nii';
%Fantasm_GM = 'exp-0000-AAAAABAB/threshold_to_binary_mask/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_seg_binmask.nii';
Fantasm_GM = 'exp-0000-AAAAABA/Fantasm/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_seg.nii';
Fantasm_mGM= 'exp-0000-AAAAABAA/threshold_to_binary_mask/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_seg_binmask.nii';
Fantasm_WM= 'exp-0000-AAAAABAC/threshold_to_binary_mask/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_class3_binmask.nii';

mGM= 'exp-0000-AAAAABAA/threshold_to_binary_mask/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_seg_binmask.nii';

mGM_trim= 'exp-0000-AAAAABAAA/Image_Calculator/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_seg_binmask_calc.nii';

WM_trim= 'exp-0000-AAAAABACA/Image_Calculator/bravo_standard_calc_calc_norm1_clone_transform_mask_cp_strip_norm_calc_clone_class3_binmask_calc.nii';
%% load the images 

files = {combined_GM Masked_ratio_img Fantasm_GM Fantasm_mGM Fantasm_WM mGM mGM_trim WM_trim ratio_img};
for j=1:9 %load each file, 2,7, 8 are signed rest are int8
    file{j} = strcat(path,files{j});
    img{j}=load_nii(file{j});
    img{j}=double(img{1, j}.img); %for math to work, they need to be same type
end

%ratio_image_values=img{2}(img{2}~=0);
% images are hidden in: img_values{1, 1}
% figure
% histogram(ratio_image_values, 500);
% title('Histogram of masked ratio')
% %axis([0,1,0,7000])
%%
%Fantasm histogram (files,3,4,5)
ratio_image = img{9}.*img{3}; %Thisis done to avoid the threshold values
GM_values = img{9}.*(img{3} == 1);
mGM_values = img{9}.*(img{3} == 2);
WM_values = img{9}.*(img{3} == 3);

% GM_values = img{9}.*(img{3} - img{4});
% mGM_values = img{9}.*(img{4} - img{5});
% WM_values = img{9}.*img{5};

ratio_string = ratio_image(ratio_image~=0);
GM_string = GM_values(GM_values~=0);
mGM_string = mGM_values(mGM_values~=0);
WM_string = WM_values(WM_values~=0);

figure(2)
h2 = histogram(GM_string,'EdgeColor','r','FaceColor','r');
title('Histogram of GM intensities with Fuzzy 0.1')
axis([0,0.75,0,8000])
hold on
h3 = histogram(mGM_string,'EdgeColor','g','FaceColor','g');
h4 = histogram(WM_string,'EdgeColor','c','FaceColor','c');
%,'BinWidth',100
%%
%write strings to csv's
excelname1= strcat(save_path,'GM_hard.xlsx');
excelname2= strcat(save_path,'mGM_hard.xlsx');
excelname3= strcat(save_path,'WM_hard.xlsx');
excelname4= strcat(save_path,'full_spectrum_hard.xlsx');
xlswrite(excelname1,GM_string);
xlswrite(excelname2,mGM_string);
xlswrite(excelname3,WM_string);
xlswrite(excelname4,ratio_string);

%%
% %overlap gaussians
% %1 - GM
% y_1 = 0:0.001:0.8;
% mu_1 = 0.31;
% sigma_1 = 0.04;
% f_1 = exp(-(y_1-mu_1).^2./(2*sigma_1^2)).*6500;
% plot(y_1,f_1,':','Color','k','LineWidth',3)
% 
% %2 - mGM
% hold on
% y_2 = 0:0.001:0.8;
% mu_2 = 0.422;
% sigma_2 = 0.072;
% f_2 = exp(-(y_2-mu_2).^2./(2*sigma_2^2)).*2600;
% plot(y_2,f_2,'--','Color','k','LineWidth',1.5)
% 
% %3 - WM
% y_3 = 0:0.001:0.8;
% mu_3 = 0.59;
% sigma_3 = 0.0305;
% f_3 = exp(-(y_3-mu_3).^2./(2*sigma_3^2)).*5700;
% plot(y_3,f_3,'-.','Color','k','LineWidth',1.5)
% 
% %4 - sum of the gaussians
% total_gaus = f_1 + f_2 + f_3;
% plot(y_3,total_gaus,'Color','k','LineWidth',2)