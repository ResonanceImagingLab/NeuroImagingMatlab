% Test R2* fitting

addpath(genpath('/export02/data/chris/programs/hMRI-toolbox-0.4.0' ))


% Sample data:
TE = 2:6:68;

M0 = 850;
T2star = 50; % [ms]
Sig = M0* exp((-TE/T2star));
Noise = rand([1, length(TE)])*(M0/70); % SNR of 70ish
SigN = Sig + Noise;

% View data 
figure;
scatter(TE, SigN);
hold on
plot(TE,Sig)
xlabel("TE (ms)")
ylabel("Signal")


%% Fit one, to exponential:
tic
opts = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',[0,0],'Upper',[5000,200], 'Start', [1500, 50]);
opts.Robust = 'Bisquare';
% now fit
myfittype = fittype('k * exp(-TE/T2st)','dependent', {'SigN'}, 'independent',{'TE'},'coefficients', {'k','T2st'});
fitT2st = fit( TE', SigN', myfittype, opts ); % Add in upper and lower bounds to help with fit
T2stcoef = coeffvalues(fitT2st);
toc

% add plot:
plot(TE, T2stcoef(1) * exp(-TE/T2stcoef(2)))


%% Fit 2, log linear:
% Linear fit
tic
opts = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',[0,0],'Upper',[5000,200], 'Start', [1500, 50]);
opts.Robust = 'Bisquare';
% now fit
myfittype = fittype('k -TE/T2st','dependent', {'SigN'}, 'independent',{'TE'},'coefficients', {'k','T2st'});
fitT2st2 = fit( TE', log(SigN)', myfittype, opts ); % Add in upper and lower bounds to help with fit
T2stcoef2 = coeffvalues(fitT2st2);
M0 = exp(T2stcoef2(1)); % undo the log

toc
plot(TE, M0 * exp(-TE/T2stcoef2(2)))


%% Fit 3 Matrix Form
% Hijacked from hMRI toolbox, but simplified for only 1.


dims=size(img);
Nvoxels=prod(dims(1:end-1));
Nweighted=1;

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

% log(0) is not defined, so warn the user about zeroes in their data 
% for methods involving a log transform.
% The warning can be disabled with "warning('off','hmri:zerosInInput')"
if any(y(:)==0)&&~contains(lower(method),'nlls')
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
T2s = 1./R2s;

% extrapolate to TE = 0;
M0extrapolated = beta(2,:);
M0extrapolated = reshape( M0extrapolated,[dims(1:end-1),1]);

plot(TE, M0extrapolated * exp(-TE/T2s))



