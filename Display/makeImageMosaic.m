function makeImageMosaic(img, nrows, ncols,inc, climits)

% Input image should be squeezed to have 3 dimensions. The mosaic is
% generated over the 3rd dimension.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    inc = 1;
end


% Make mosaic
x = size(img,1);
y = size(img,2);
z = size(img,3);

if (nrows*ncols) ~= z
    disp('number of rows and cols does not match img count');
end

% Calc x size:
xM = x*ncols;
yM = y*nrows;
mos = zeros( xM, yM);


rowStartIdx = 1;
rowEndIdx = y;
counter = 1;


for i = 1:nrows 

    colStartIdx = 1;
    colEndIdx = x;

    for j = 1:ncols

        mos(colStartIdx:colEndIdx,rowStartIdx:rowEndIdx) = ...
            squeeze(img(:,:,counter));

        colStartIdx = colEndIdx+ 1;
        colEndIdx = colEndIdx+ x;
        counter = counter + inc;

        if counter > z
            break;
        end
    
    end

    rowStartIdx = rowEndIdx+ 1;
    rowEndIdx = rowEndIdx+ y;
end

figure; imagesc(mos)
colormap("gray")
axis image;
axis off;
if nargin >= 5
    clim(climits)
end
