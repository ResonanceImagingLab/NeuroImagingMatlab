%% Attempt 2D N4 Correction
% For N4, we apply the bias field on each iteration, and estimate the
% remaining bias.

%% TO DO -> Add in the multi-resolution approach.
% it should be just changing node size for smoothSpline step. 

% Load image:
load("MRIslice.mat")
slice = double(slice);

% log10 of 0 is -inf, so set to small value:
slice(slice == 0) = 1e-6;

figure; imagesc(slice) ; axis image; colormap("jet"); caxis([0 800])



img = log10(slice);
figure; imagesc(img) ; axis image; colormap("gray"); colorbar
img(isinf(img)) = 0; % correct values that were at zero:

% since we use histogram, can probably improve performance by shrinking
% range
img(img < 0) = 0;

% unique for this application, first row is zeros, messing it up. Remove
img(1,:) = [];

%% Algorithm
threshold = 1e-6;
bias = zeros(size(img)); imgOld = ones(size(img));
maxIter = 10;
img2 = img;
[utrue, vtrue] = meshgrid(1:size(img,2), 1:size(img,1)); % matlab has this backwards
resPyramid = [15, 25, 45]; % Alternate even and odd so nodes land on different spots

% Figure 3 in N4-ITK paper demonstrates that lower res is needed to fit to
% non-zero baseline. Will need to think if that is a problem I have, as it
% seems to make things worse...


% loop through for each resolution level
for res = 1:length(resPyramid)
    
    nodeSpacing = resPyramid(res);
    iter = 1;
    metric =  10000;

    % run until converged or max iterations hit
    while (metric > threshold) 
    
        if (iter > maxIter)
            break;
        end
    
        % histogram sharpen and deconvolve
        piHat = N3_deconvolutionStep(img2, bias); 
    
        % apply this to generate bias field
        r = N3_biasCorrectionStep(img2, bias, piHat);
        
        % smooth with bsplines
        bias = N3_bSplineSmoothStep(r, utrue,vtrue,nodeSpacing,nodeSpacing);
    
        % N4, we apply bias each iteration
        img2 =img2 -  bias;
    
        % Calculate convergence metric
        metric = sum( abs(img2 - imgOld),"all","omitnan");
    
        imgOld = img2;
        bias = bias * 0; % reset for next iteration
        iter = iter+1;
    
    end
end

figure; imagesc(r) ; axis image; colormap("turbo"); colorbar; %caxis([0 800])

figure; imagesc(bias) ; axis image; colormap("turbo"); colorbar; %caxis([0 800])


totalBias = img2 - img;

figure; imagesc(totalBias) ; axis image; colormap("turbo"); colorbar; %caxis([0 800])

figure; imagesc(slice) ; axis image; colormap("jet");colorbar; caxis([0 800])
figure; imagesc(10.^(img2)) ; axis image; colormap("jet"); colorbar; caxis([0 800])
















