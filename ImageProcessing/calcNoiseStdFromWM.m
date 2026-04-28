function noiseStd = calcNoiseStdFromWM( T1, img)

% requires a T1 map to generate an initial WM mask.
% img is the the image you want the noise estimate of
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% WM ROI for noise estimation:
wmMask = zeros(size(T1));
wmMask(T1> 700 & T1 <950) = 1;

%% Light erosion
se = strel('sphere', 1);   % or 1–3 depending on resolution
wmMaskErode = imerode(wmMask, se);

%% Keep only largest component
cc = bwconncomp(wmMaskErode, 26);   % 3D connectivity

numPixels = cellfun(@numel, cc.PixelIdxList);
[~, idx] = max(numPixels);

wmMaskClean = zeros(size(wmMaskErode));
wmMaskClean(cc.PixelIdxList{idx}) = 1;

% figure; imshow3Dfullseg(T1, [400, 2500], wmMaskClean)

wmVals = img(wmMaskClean == 1);

mu = mean(wmVals);
sigma = std(wmVals);

wmMaskFinal = wmMaskClean;
wmMaskFinal(img < (mu - 2*sigma) | img > (mu + 2*sigma)) = 0;

noiseStd = std(img(wmMaskFinal == 1));

%figure; imshow3Dfullseg(T1, [400, 2500], wmMaskFinal)

%% Generate Figure showing fit:
% Extract values
vals = img(wmMaskFinal == 1);
vals = vals(isfinite(vals));   % safety

% Fit Gaussian
mu = mean(vals);
sigma = noiseStd;

% Histogram (normalized to PDF)
figure;
histogram(vals, 50, 'Normalization', 'pdf');
hold on;

% Gaussian curve
x = linspace(min(vals), max(vals), 200);
y = (1/(sigma*sqrt(2*pi))) * exp(-(x - mu).^2 / (2*sigma^2));

plot(x, y, 'r', 'LineWidth', 2);

xlabel('Image Value');
ylabel('Probability Density');
title(sprintf('WM Histogram + Gaussian Fit (\\mu = %.2f, \\sigma = %.2f)', mu, sigma));
legend('Data', 'Gaussian fit');
grid on;