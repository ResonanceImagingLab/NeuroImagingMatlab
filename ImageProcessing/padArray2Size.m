function imgPad = padArray2Size(img, xyz, padValue)

% pad an image to specified size with pad value.
% padding will be done to keep the image centered.

% % Sample:
% img = imread('street1.jpg');
% img = squeeze(img(:,:,1));
% imshow(img)
% xyz = [480,874];
% padValue = 0;

if (nargin < 3)
    padValue = 0;
end

img_sz = size(img);

% confirm there are enough dimensions
if ( size(img_sz) ~= size(xyz))
    error('Please enter a target size vector with one element per dimension');
end

% make sure target dimensions are not smaller (no cropping yet...)
if (img_sz(1) > xyz(1) || img_sz(2) > xyz(2) )
    error("Increase pad size, function does not support cropping")
end

%% Determine start indicies for placement
stx = floor(xyz(1)/2) - floor(img_sz(1)/2);
sty = floor(xyz(2)/2) - floor(img_sz(2)/2);

if (stx == 0)
    stx = 1;
end
if (sty == 0)
    sty = 1;
end

%% will split into two for 2D and 3D

if (length(img_sz) ==2 )

    imgPad = ones(xyz(1),xyz(2))*padValue;
    imgPad(stx:stx+img_sz(1)-1, sty:sty+img_sz(2)-1) = img;

elseif (length(img_sz) == 3)

    if (img_sz(3) > xyz(3) )
    error("Increase pad size, function does not support cropping")
    end

    stz = floor(xyz(3)/2) - floor(img_sz(3)/2);

    if (stz == 0)
        stz = 1;
    end

    imgPad = ones(xyz(1),xyz(2),xyz(3))*padValue;
    imgPad(stx:stx+img_sz(1)-1, sty:sty+img_sz(2)-1, stz:stz+img_sz(3)-1) = img;

else
    error('this function currently only handles 2D and 3D inputs')
end

% figure;
% imshow(imgPad)
% caxis([0 256])
