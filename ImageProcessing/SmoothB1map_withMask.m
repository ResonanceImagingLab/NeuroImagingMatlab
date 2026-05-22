function B1poly = SmoothB1map_withMask(B1, mask, sigma, erodeVox, polyOrder)

% Smooth B1 map using only voxels inside a brain mask.
%
% B1       : 2D or 3D B1 map
% mask     : brain mask, same size as B1
% sigma    : Gaussian sigma in voxels
% erodeVox : optional erosion radius to avoid skull boundary contamination
% polyOrder: the order of the smoothing polynomial

if nargin < 4
    erodeVox = 0;
    polyOrder = 3;
end

B1 = double(B1);
mask = mask > 0;

% Remove invalid B1 values from mask
valid = mask & isfinite(B1) & ~isnan(B1);

% Optional: pull mask inward if skull-adjacent voxels are unreliable
if erodeVox > 0
    if ndims(B1) == 2
        valid = imerode(valid, strel("disk", erodeVox));
        outputMask = imdilate(mask, strel("disk", ceil(erodeVox/2)) );
    else
        valid = imerode(valid, strel("sphere", erodeVox));
        outputMask = imdilate(mask, strel("sphere", ceil(erodeVox/2)) );
    end
end

% Replace invalid values with 0 only after storing validity in mask
B1(~isfinite(B1)) = 0;
B1(~valid) = 0;

% Smooth numerator and denominator
num = imgaussfilt3(B1 .* valid, sigma);
den = imgaussfilt3(double(valid), sigma);

% figure; imshow3Dfull( B1, [0.6 1.5], turbo)
% figure; imshow3Dfull( num, [0.6 1.5], turbo)

% Normalize so only valid neighbours contribute
B1s = num ./ max(den, eps);

% Keep output only in original brain mask
B1s(~mask) = NaN;

valid = valid & isfinite(B1s);
B1poly = fitB1Polynomial3D(B1s, valid, outputMask, polyOrder);

end

%% Helper functions
function B1fit = fitB1Polynomial3D(B1smooth, fitMask, outputMask, polyOrder)

B1smooth = double(B1smooth);
fitMask = fitMask > 0;
outputMask = outputMask > 0;

[x,y,z] = ndgrid(1:size(B1smooth,1), ...
                 1:size(B1smooth,2), ...
                 1:size(B1smooth,3));

% Normalize coordinates to reduce numerical conditioning issues
xn = 2*(x - mean(x(outputMask))) / range(x(outputMask));
yn = 2*(y - mean(y(outputMask))) / range(y(outputMask));
zn = 2*(z - mean(z(outputMask))) / range(z(outputMask));

valid = fitMask & isfinite(B1smooth);

X = buildPolyDesign(xn(valid), yn(valid), zn(valid), polyOrder);
yval = B1smooth(valid);

% Robust fitting is helpful if some bad voxels remain
beta = robustfit(X(:,2:end), yval);  % robustfit adds intercept

Xout = buildPolyDesign(xn(outputMask), yn(outputMask), zn(outputMask), polyOrder);
pred = [ones(size(Xout,1),1), Xout(:,2:end)] * beta;

B1fit = nan(size(B1smooth));
B1fit(outputMask) = pred;

end

function X = buildPolyDesign(x, y, z, order)

X = ones(numel(x),1);

for totalOrder = 1:order
    for i = 0:totalOrder
        for j = 0:(totalOrder-i)
            k = totalOrder - i - j;
            X(:,end+1) = (x.^i) .* (y.^j) .* (z.^k);
        end
    end
end

end