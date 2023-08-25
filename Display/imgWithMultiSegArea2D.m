function imgWithMultiSegArea2D(img, seg, dispRange, ...
    imgClrMap)

% goal is to loop through the different segmentations, and draw them onto
% the image. 


% Written by Christopher Rowley 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin < 3)
    dispRange(2) = max( img(:) );
    dispRange(1) = min( img(:) );
end

if (nargin < 4)
    imgClrMap = 'gray';
end

boundaries = bwboundaries( seg );
segClr = lines( length( boundaries ));


figure;
imshow( img./1.1, dispRange );
colormap(imgClrMap);
axis image;
set(gcf,'Position',[100 100 1200 800])

hold on % add the segmentation outline

for k = 1:size(boundaries,1)
    bound = boundaries{k};
    plot( bound(:,2), bound(:,1), 'Color', segClr(k,:), 'LineWidth', 2);
end
hold off











