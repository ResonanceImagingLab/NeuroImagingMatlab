function Xout = nlmCropMasked3D(X, mask, noiseStd, beta, rs, rc)

% This is a wrapper function for FastNonLocalMeans3D to shrink the search
% to only within non-zero pixels to run faster.

% Suggested values for 3D MRI:
% beta = 1.1; % filter strength, larger = more filtering
% rs = [5,5,5]; % 3x1 vector for search
% rc = [1,1,1]; % 3x1 vector for comparison

% Written by Christopher Rowley 2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mask = mask > 0; % force logical

% Find bounding box of nonzero mask
[idxX, idxY, idxZ] = ind2sub(size(mask), find(mask));

xRange = min(idxX):max(idxX);
yRange = min(idxY):max(idxY);
zRange = min(idxZ):max(idxZ);

% Crop
Xcrop = X(xRange, yRange, zRange);
Mcrop = mask(xRange, yRange, zRange);

% % Fill outside-mask crop values to avoid edge artifacts
% fillVal = median(Xcrop(Mcrop), 'omitnan');
% Xcrop(~Mcrop) = fillVal;

% Denoise cropped volume
XcropDenoised = FastNonLocalMeans3D( Xcrop, noiseStd, beta, rs, rc); % 4 mins(Xcrop, nlmArgs{:});

% Put back into original matrix size
Xout = zeros(size(X));
tmp = zeros(size(Xcrop));
tmp(Mcrop) = XcropDenoised(Mcrop);

Xout(xRange, yRange, zRange) = tmp;

end