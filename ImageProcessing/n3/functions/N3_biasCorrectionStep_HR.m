function r_output = N3_biasCorrectionStep_HR(img, bias, piHat, fwhm)

% assumes that img is the log transform of the input image
% bias is the log transformed bias field (such that it is additive)

%% Set up parameters:
mult = 1; % bin number multiplier *mult
K = 200*mult;
% fwhm = 0.02; % n4 is 0.15. Lower is less smoothing


%% Code
d = img(:); 
b = bias(:);
N = length(d);
variance = fwhm^2/ (8*log(2));

%% histogram setup
mu1 = min(d-b); % min box 
muK = max(d-b); % max box
h = (muK - mu1)/(K-1); % box spacing
k = 1:K;
muk = mu1 + (k-1)*h; % image center


%% Check values
% piHat histogram is K, new histogram is L

peak = (1/sqrt(2*pi*variance));

dmu = zeros(1,K);
for i = 1:K
    nom = peak* exp( -( muk(i)-muk).^2/ (2*variance)) .* piHat';
    denom = sum(nom);

    dmu(i) = sum((nom/denom).*muk);
end

% %% Debug
% figure; bar(muk,dmu)
% figure; histogram(img,500)
% figure; bar(piHat)

%% Corrected Intensity:
di = zeros(N,1);

for i = 1:N
    val = 0;
    for L = 1:K
        psiD = ( d(i) - b(i) - muk(L))/h;     
        
        if abs(psiD) < 1
            val = val + dmu(L)*(1 - abs(psiD));
        end
    end
    di(i) = val;
end


% %% Debug
% figure; histogram(di,500)
% temp = zeros(size(img));
% temp(1:end) = di(:);
% figure; imagesc(temp); axis image; caxis([2.6, 4.2])
% figure; imagesc(img); axis image; caxis([2.6, 4.2])

%% Calculate residual field:

r = d- di;
r_output = zeros(size(img));
r_output(1:end) = r(:);
r_output(isnan(r_output)) = 0;

%figure; imagesc(r_output); axis image

% push smoothing to a different function






