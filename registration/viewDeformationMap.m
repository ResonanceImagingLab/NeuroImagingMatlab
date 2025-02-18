function viewDeformationMap(deformImg, numGrid)

% this function is for viewing the deformation image.
% deformImg - the deformation map output from ANTs SyN registration
% numGrid = the number of gridlines
%
% You can test this function using 
% deformImg = cat(3, peaks(60),peaks(60));
% numGrid = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ndims(deformImg) > 3
    error('This function is currently only set up for a 2D slice')
end

% Get size
[xtemp, ytemp, ~] = size(deformImg);

% Upsample for better viewing. Find closest division to get to 1000
xScale = floor(400/xtemp);
yScale = floor(400/ytemp);

scale = min(xScale, yScale);

x = xtemp * scale;
y = ytemp * scale;

% Make grid image
gridImg = ones(x,y);

% Set grid lines to 0;
xStep = round( x/numGrid);
yStep = round( x/numGrid);
for i = 1:xStep:x
    gridImg(i,:) = 0;
end

for i = 1:yStep:y
    gridImg(:,i) = 0;
end

% figure;
% imagesc(gridImg)

% Now use deformImage to deform the grid using interp2

[xG, yG] = ndgrid(1:x, 1:y);
deformImg2 = imresize(deformImg, [x,y]); 

deformGrid = deformImg2*scale + cat(3, xG, yG);

dG = interp2( xG, yG, gridImg, deformGrid(:,:,1), deformGrid(:,:,2) );






figure; imagesc(gridImg)

figure; imagesc(deformImg(:,:,1))
figure; imagesc(deformImg(:,:,2))








