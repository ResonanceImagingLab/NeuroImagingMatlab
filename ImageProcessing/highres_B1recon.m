
%highres B1 reconstruction

%starts with the collection of 3 B1 maps, in each orthogonal plane, with
% 2.4x1.2x1.2 resolution.
% hopefully they all have the same matrix size!

addpath(genpath('/usr/local/niak')); %load the matlab minc tools
addpath(genpath('/data_/tardiflab/chris/marm_processing/cortex_processing/matlab_segmentation')); %load the view3D code

%file names (just use average and denoised data)
b1_c_fn = '/data_/tardiflab/chris/marm_processing/marm_imaging/20190329/minc/giada_20190329_110823_13d1_mri.mnc'; 
b1_s_fn = '/data_/tardiflab/chris/marm_processing/marm_imaging/20190329/minc/giada_20190329_110823_15d1_mri.mnc'; 
b1_t_fn = '/data_/tardiflab/chris/marm_processing/marm_imaging/20190329/minc/giada_20190329_110823_17d1_mri.mnc'; 
anat_c_fn = '/data_/tardiflab/chris/marm_processing/marm_imaging/20190329/minc/giada_20190329_110823_12d1_mri.mnc'; 

% load files
[hdr, b1_c] = niak_read_minc2(b1_c_fn); 
[hdr2, b1_s] = niak_read_minc2(b1_s_fn);
[~, b1_t] = niak_read_minc2(b1_t_fn);


figure;
imshow3Dfull(b1_c)

figure;
imshow3Dfull(b1_s)

figure;
imshow3Dfull(b1_t)


% resample the images to isotropic resolution

[x,y,z] = size(b1_c);
z_ups = z*2; 

tmp = resize(b1_c,[x y z_ups]);
up_b1_s = resize(b1_s,[x y z_ups]);
up_b1_t = resize(b1_t,[x y z_ups]);

% matlab seems to load them according to slice direction, so will have to
% reorient the images. % will need to register them? 

up_b1_s = imrotate3(up_b1_s,90,[1 0 0]); 
up_b1_t = imrotate3(up_b1_t,-90,[0 1 0]); %this seems to add a dimension...

up_b1_c = zeros(x,y,z_ups+1);
up_b1_c(:,:,1:end-1) = tmp;

% then crop to the same size % kind of need images in register...
% maybe think about using elastix to rigid register then you can skip a
% bunch of the above steps. 
midx = x/2;
midy = y/2;
midz = z_ups/2;

cp_c = up_b1_c(midx-midz+2:midx+midz+2, midy-midz-2:midy+midz-2, :);
cp_s = up_b1_s(:, midx-midz-2:midx+midz-2, midy-midz-1:midy+midz-1); % this could be wrong for arbitrary cases
cp_t = up_b1_t(midx-midz+2:midx+midz+2,:,midy-midz-10:midy+midz-10 );


% figure;
% imshow3Dfull(cp_c)

%% the resizing creates some grid artifacts, lets filter in the fourier space then combine

filt_c = filter_MRI_3D(cp_c,@hamming, 1);
filt_s = filter_MRI_3D(cp_s,@hamming, 1);
filt_t = filter_MRI_3D(cp_t,@hamming, 1);

%check alignment
% figure;
% imshow3Dfull(cp_c)

figure;
imshow3Dfull(filt_c)

% figure;
% imshow3Dfull(cp_s)

figure;
imshow3Dfull(filt_s)

% figure;
% imshow3Dfull(cp_t)

figure;
imshow3Dfull(filt_t)

%combine the images

img_mean = (filt_c +filt_s +filt_t)./3;
img_median =  median(cat(4, filt_c, filt_s, filt_t),4);


figure;
imshow3Dfull(img_mean)

figure;
imshow3Dfull(img_median) % median looks more stable. 


b1 = img_median ./830;

% load the anatomical to mask

[~, anat_c] = niak_read_minc2(anat_c_fn); 
tmp = resize(anat_c,[x y z_ups]);
up_anat_c = zeros(x,y,z_ups+1);
up_anat_c(:,:,1:end-1) = tmp;
cp_anat_c = up_anat_c(midx-midz+2:midx+midz+2, midy-midz-2:midy+midz-2, :);

mask = zeros(size(cp_anat_c));
mask(cp_anat_c > 400) = 1;
mask(:,:,1:6) = 0;

% figure;
% imshow3Dfullseg(cp_anat_c,[0 4000], mask)


%% save

%tmp = hdr;
hdr = tmp;

hdr.file_name = "/data_/tardiflab/chris/marm_processing/marm_imaging/20190329/b1_processing/b1_test.mnc";
hdr.info.dimensions = size(b1); % these 3 lines change header info for new voxel size
hdr.info.voxel_size = [1.2,1.2,1.2];
hdr.info.mat(2,3) = hdr.info.mat(2,3)/2; 

hdr.info.mat(1,4) = 22.5;% probably left right was 30.5
hdr.info.mat(3,4) = 30; % this one is up and down

hdr.info.mat(2,4) = -40; % forward/back (was -44)


niak_write_minc3D(hdr,b1.*mask); 


% should save the anatomical out as well for registration

hdr.file_name = "/data_/tardiflab/chris/marm_processing/marm_imaging/20190329/b1_processing/b1_anatomical.mnc";
niak_write_minc3D(hdr,cp_anat_c.*mask); 














