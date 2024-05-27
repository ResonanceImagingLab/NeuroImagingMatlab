function piHat = N3_deconvolutionStep(img, bias)

% assumes that img is the log transform of the input image
% bias is the log transformed bias field (such that it is additive)

%% Set up parameters:
K = 200;
gam = 0.1; % typically fixed
fwhm = 0.035; % n4 is 0.15. Lower is less smoothing

%% Code
d = img(:); 
b = bias(:);
N = length(d);

%% histogram setup
mu1 = min(d-b); % min box 
muK = max(d-b); % max box
h = (muK - mu1)/(K-1); % box spacing
k = 1:K;
muk = mu1 + (k-1)*h; % image center

% histogram entries:
vk = zeros(size(k));

for j = 1:K
    val = 0;
    for i = 1:N
        psiV = ( d(i) - b(i) - muk(j))/h;     
        if abs(psiV) < 1
            val = val + (1 - abs(psiV));
        end
    end
    vk(j) = val/N;
end

% format vhat

vhat = [zeros(1,156), vk, zeros(1,156)];

%% Generate matrices:

% generate F
F = zeros(512, 512);
for i = 1:512
    for j = 1:512
        F(i,j) = exp(-2*pi*1j*(i-1)*(j-1)/512);
    end
end


% define g
variance = fwhm^2/ (8*log10(2));
g = zeros(1, 512);
for l = 1:256
    g(l) = h * (1/sqrt(2*pi*variance)) * exp( -(l-1)*h.^2/ (2*variance));
    g(512-l+1) = g(l);
end

% solve for f
f = F*g';

% Generate D
D = zeros(512, 512);
for i = 1:512
    D(i,i) = conj(f(i)) / (abs(f(i))^2 + gam);
end

%% Deconvolution:

piHat = F \ D * F * vhat';
piHat(piHat < 0 ) = 0;
piHat = abs(piHat);

piHat = piHat(157:356); % remove zero-padding


