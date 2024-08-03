% Test script:
%
% file_name = "H:\Research\NelsonProj\hc10\minc\sparse_MP2RAGE_sag_1mm_closer_UNI_Images.mnc.gz";
file_name = '/media/chris/data8tb1/Research/NelsonProj/hc10/minc/sparse_MP2RAGE_sag_1mm_closer_UNI_Images.mnc.gz';

[hdr, vol] = minc_read(file_name);

figure; imshow3Dfull(vol,[0 4096])

minc_write('temp.mnc.gz', hdr, vol)

% lots of warnings on Conversion from double to datatype H5T_STD_I32LE may clamp some values.

% Another issue is the 'clobber' option doesn't exist. So this doesn't run
% if the file exists and is minc2.
minc_write('temp.mnc', hdr, vol)


[hdr2, vol2] = minc_read('temp.mnc');
figure; imshow3Dfull(vol2,[0 4096])




[hdr1, vol1] = niak_read_vol(file_name);
figure; imshow3Dfull(vol1,[0 4096])