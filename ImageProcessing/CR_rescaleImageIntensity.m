function imgRS = CR_rescaleImageIntensity( inputImage, newMin, newMax)

% This function rescales an input image to go between the newMin and newMax

% Get rid of any inf and NaN values. This might not give you the
% anticipated values, so report the issue for person to address themselves
% as well

% Sample code:
% inputImage = rand(20,20);
% inputImage(10,10) = inf;
% inputImage(10,11) = NaN;
% 
% temp = CR_rescaleImageIntensity( inputImage, 0, 10);
% figure; imagesc(inputImage); colorbar
% figure; imagesc(temp); colorbar
% 
% Written by Christopher Rowley 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(isinf(inputImage(:)))
    inputImage(isinf(inputImage)) = 0;
    disp('Inf detected: scaling might not be as anticipated. Inf set to 0.');
end

if any(isnan(inputImage(:)))
    inputImage(isnan(inputImage)) = 0;
    disp('NaN detected: scaling might not be as anticipated. NaN set to 0.');
end

maxImg = max(inputImage(:));
minImg = min(inputImage(:));

imgRS = (inputImage - minImg) * (newMax - newMin) / (maxImg - minImg) + newMin;
