function bias = N3_bSplineSmoothStep_HR(r, utrue,vtrue, xNodeSpacing, yNodeSpacing)

% Smooth using cubic b-spline, then interpolate back to image size.
% might want to change it for the spacing size of nodes


% version N3_bSplineSmoothStep_HR.m adds additional resampling at the
% beginning to extract node values. With high-res data, we could have sharp
% changes in the 'r' map. So we can try to stabilize this by taking the
% average value across neighbouring pixels % this can be done with a simple
% 2D convolution

if isempty(xNodeSpacing)
    xNodeSpacing = 25;
end

if isempty(yNodeSpacing)
    yNodeSpacing = 25;
end

% Calculate averaging size. Base it on matrix size and node spacing. 
[x,y] = size(r);

if (xNodeSpacing > x) || (yNodeSpacing > y) 
    error('Node spacing too large for input matrix')
end

avgSz = floor (x/(xNodeSpacing*1.2));
k=ones(avgSz)/avgSz^2; % normalized sum(k,'all') = 1 

averageIntensities = conv2(double(r),k,'same');

[xvec, yvec, S] = deBoor_basis2D( [], [], averageIntensities, xNodeSpacing, yNodeSpacing);
[uu, vv] = meshgrid(yvec, xvec);

% resample bias field
if isempty(utrue) || isempty(vtrue)
    [utrue, vtrue] = meshgrid(1:x, 1:y);
end

bias = interp2(uu,vv,S,utrue,vtrue);




% %% Functions for checking thing:
% figure; imagesc(r) ; axis image; colormap("turbo"); colorbar; %caxis([0 800])
% figure; imagesc(averageIntensities) ; axis image; colormap("turbo"); colorbar; %caxis([0 800])
% figure; imagesc(bias) ; axis image; colormap("turbo"); colorbar; %caxis([0 800])















