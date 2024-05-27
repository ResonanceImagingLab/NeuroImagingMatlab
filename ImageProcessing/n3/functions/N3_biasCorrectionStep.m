function r_output = N3_biasCorrectionStep(img, bias, piHat)

% assumes that img is the log transform of the input image
% bias is the log transformed bias field (such that it is additive)

%% Set up parameters:
K = 200;
fwhm = 0.15; 

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


%% Sort out intensity values
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

% push smoothing to a different function




