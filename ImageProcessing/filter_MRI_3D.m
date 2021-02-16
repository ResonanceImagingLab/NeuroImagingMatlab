function filt_img2 = filter_MRI_3D(img,filter,scale_factor)
%% Currently iterates in 2D over the length of what was the readout direction. 
% scale factor applies exponent to the window to control how much windowing
% is applied

if nargin == 1
    filter = @hamming;
    scale_factor = 1;
end

%Generate the window
[x,y,z] = size(img);

w_y = window(filter,y);
w_z = window(filter,z)';
w2 = kron(w_y,w_z);
w2 = w2 .^scale_factor;

filt_img = zeros(x,y,z); %allocate filter image

for i= 1:x % loop through each slice
    img2 = squeeze(img(i,:,:));
    if_v = ifftn(img2); % do ifft
    ifs_v = fftshift(if_v); % ifft shift
    fs_v = fftshift(ifs_v .* w2); %apply window and shift back
    fs_v = fftn(fs_v); % inverse ifft
    filt_img(i,:,:) = fs_v;
end

filt_img2 = abs(filt_img); % export abs value

