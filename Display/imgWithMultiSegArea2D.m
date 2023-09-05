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

if length(boundaries) == 10
    % for the T2 maps, they get jumbled, so resort:
    outV = [1, 10,2, 3, 9, 8, 4, 5, 7, 6 ]; % For 3D T2 array
    %outV = [1, 10,2, 3, 9, 4, 8, 5, 7, 6 ]; % For 2D T2 array

    temp ={};
    for i = 1:10
        temp{outV(i), 1} = boundaries{i,1};
    end
    boundaries = temp;
end





segClr = turbo( length( boundaries ));


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











