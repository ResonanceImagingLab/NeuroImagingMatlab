function [M0extrapolated, T2s] = CR_T2star_fit_loglinear(img, mask, TE)

% input_img = magnitude data stacked in the 4th dimension for each echo
% mask = brain mask to speed up calculation to only masked voxels
% TE = TE vector. a 1xnumber_echos vector that stores the TE value for each
% echo. 
% thres = pixel value to threshold whether you want to include the data or not. Important for exlcuding points in later echos. (150 is a good value)

% Goal is to do a log linear fit


% T2* can be found by fitting the equation S = k*exp(-TE/T2*); 
% http://mriquestions.com/iront2-mapping.html
  
%% Fitting works better if TEs are in milliseconds
if max(TE) < 0.5
    TE = TE *1000;
end

dims=size(img);
Nvoxels=prod(dims(1:end-1));
TE = TE(:); % ensure its a column vector;

D = zeros( length(TE), 2);
D(:,1) = -TE;
D(:,2) = 1;

% Build response variable vector
nTEs = length(TE);
assert(nTEs>1,'must have more than one TE')

localDims = size( img);
assert(localDims(end) == nTEs,'echoes must be in the final dimension')
assert(prod(localDims(1:end-1)) == Nvoxels,'all input data must have the same number of voxels');

y = reshape( img, Nvoxels, nTEs).';

y(y == 0) = 0.000001; % solve the log transform of 0 issue. 
% log(0) is not defined, so warn the user about zeroes in their data 
% for methods involving a log transform.
% The warning can be disabled with "warning('off','hmri:zerosInInput')"
if any(y(:)==0)
    warning('hmri:zerosInInput',[...
        'Zero values detected in some voxels in the input data. This ',...
        'will cause estimation to fail in these voxels due to the log ',...
        'transform. If these voxels are background voxels, consider ',...
        'removing them from the input data matrices. ',...
        'Zero values which occur only at high TE in voxels of interest ',...
        'could be replaced with a small positive number, e.g. eps(1) ',...
        '(if the data magnitudes are ~1) or 1 if the data are ',...
        'integer-valued. Note: Care must be taken when replacing ',...
        'values, as this could bias the R2* estimation.']);
end

beta=(D'*D)\(D'*log(y));
beta(2:end,:)=exp(beta(2:end,:));


%% Output
% extra unity in reshape argument avoids problems if size(dims)==2.
R2s=reshape(beta(1,:),[dims(1:end-1),1]);
T2s = abs(1./R2s);
T2s = limitHandler(T2s, 0, 1000); % remove nan and inf

% extrapolate to TE = 0;
M0extrapolated = abs(beta(2,:));
M0extrapolated = reshape( M0extrapolated,[dims(1:end-1),1]);

if ~isempty(mask)
    T2s = T2s.* mask;
    M0extrapolated = M0extrapolated .* mask;
end


%% you can plot to check the fit

% msat_calc = fitT2st(TE_fit);
% figure;
% plot(TE_fit,msat_calc,'LineWidth',2)
% hold on
% scatter(TE_fit, img_voxel,40,'filled')
%     ax = gca;
%     ax.FontSize = 20; 
%     xlabel('TE (ms) ', 'FontSize', 20, 'FontWeight', 'bold')
%     ylabel('Signal}', 'FontSize', 20, 'FontWeight', 'bold')
%      %   colorbar('off')
%     legend('hide')
%     text(6.2, 0.0015, strcat('T_{2}^* = ',num2str(T2_star,'%.3g')), 'FontSize', 16); 
%     ylim([20 300])









