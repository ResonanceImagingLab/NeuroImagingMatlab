%% Attempt 2D N3 Correction

% Load image:
load("MRIslice.mat")
slice = double(slice);
figure; imagesc(slice) ; axis image; colormap("jet");caxis([0 800])

img = log10(slice);
figure; imagesc(img) ; axis image; colormap("gray")
img(isinf(img)) = 0; % correct values that were at zero:

%% Algorithm
threshold = 1e-6;
metric =  10000;
bias = zeros(size(img)); biasOld = ones(size(img));
iter = 1;
maxIter = 5;
[utrue, vtrue] = meshgrid(1:size(slice,2), 1:size(slice,1)); % matlab has this backwards


% run until converged or max iterations hit
while (metric > threshold) 

    if (iter > maxIter)
        break;
    end

    % histogram sharpen and deconvolve
    piHat = N3_deconvolutionStep(img, bias); 

    % apply this to generate bias field
    r = N3_biasCorrectionStep(img, bias, piHat);
    
    % smooth with bsplines
    bias = N3_bSplineSmoothStep(r, utrue,vtrue,50,50);

    metric = sum( abs(bias - biasOld),"all","omitnan");

    biasOld = bias;
    iter = iter+1;

end

img2 =img -  bias;

figure; imagesc(r);axis image; colormap("jet");
figure; imagesc(img- r);axis image; colormap("jet");
figure; imagesc(img);axis image; colormap("jet");
figure; imagesc(slice) ; axis image; colormap("jet");caxis([0 800])
figure; imagesc(10.^(img2)) ; axis image; colormap("jet"); caxis([0 800])
















