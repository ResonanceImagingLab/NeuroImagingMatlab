function [MWF, A_my, A_ax, A_ex, T2st_my, T2st_ax, T2st_ex, freq_my, freq_ax, freq_ex, knot] = CR_T2star_MWF_fit_Nam2015(input_mag, input_phase, mask, TE)

% input_img = magnitude data stacked in the 4th dimension for each echo
% mask = brain mask to speed up calculation to only masked voxels
% TE = TE vector. a 1xnumber_echos vector that stores the TE value for each
% echo. 


% input_img = mgre_ur_filt;
% mask = mask;
% TE = TEs;

%% Following the paper my Nam et al., 2015 (NeuroImage), you can have 3 models. 
% for the proposed complex model
% S(t) = (A_my * exp(-t/T2st_my - i*2*pi*freq_my*t) + A_ax * exp(-t/T2st_ax
% - i*2*pi*freq_ax*t) + A_ex * exp(-t/T2st_ex - i*2*pi*freq_ex*t)) *
% exp(- i*knot)

% Where MWF = A_my / (A_my + A_ax + A_ex)
% as per Table 1 in the paper, they used the following fitting conditions
% note the frequencies include the background frequency offset. Note
% labelled here just to keep it short. 
% for a 10 parameter fit (corresponding to [A_my, A_ax, A_ex, T2st_my, T2st_ax, T2st_ex, freq_my, freq_ax, freq_ex, knot]:
% 'Start', [ 0.1*S1, 0.6*S1, 0.3*S1, 10, 64, 48, 5, 0, Ph1, Ph1, Ph1, theta], 'Lower',[0, 0, 0, 3, 25, 25, -75, -25, Ph1 -75, Ph1-25, Ph1-25, -pi],'Upper',[2*S1, 2*S1, 2*S1, 25, 150, 150, 75, 25, Ph1 +75, Ph1+25, Ph1+25, pi]
% Where S1 = Signal at first echo; Ph1 = phase at first echo. theta = angle(mag +exp(i*phase)

[x,y,z,t] = size(input_mag);




%% Do an approximation to correct if phase is in rad/s or Hz







% T2* can be found by fitting the equation S = k*exp(-TE/T2*); 
% http://mriquestions.com/iront2-mapping.html
  
%% Fitting works better if TEs are in milliseconds
if max(TE) < 0.2
    TE = TE *1000;
end

% initalize fit matrices 
A_my = zeros(x,y,z);
A_ax = zeros(x,y,z);
A_ex = zeros(x,y,z);
T2st_my = zeros(x,y,z);
T2st_ax = zeros(x,y,z);
T2st_ex = zeros(x,y,z);
freq_my = zeros(x,y,z);
freq_ax = zeros(x,y,z);
freq_ex = zeros(x,y,z);
knot = zeros(x,y,z);



for i = 1:x
    for j = 1:y
        for k = 1:z
            if mask(i,j,k) < 1 % use for masked data
                A_my (i,j,k) = 0;
                A_ax (i,j,k) = 0;
                A_ex (i,j,k) = 0;
                T2st_my(i,j,k) = 0;
                T2st_ax (i,j,k) = 0;
                T2st_ex (i,j,k) = 0;
                freq_my (i,j,k) = 0;
                freq_ax (i,j,k) = 0;
                freq_ex (i,j,k) = 0;
                knot (i,j,k) = 0;
            else 
                img_voxel_mag = squeeze(input_mag(i,j,k,:)); % squeeze necessary to reformat to 1D array
                img_voxel_phase = squeeze(input_phase(i,j,k,:));
                
                %remove values from fitting procedure where signal drops
                %low due to dephasing 
                TE_fit = TE';
                TE_fit (img_voxel_mag < 100) = [];
                
                if length(TE_fit) < 6  % if insufficient points for fitting
                	A_my (i,j,k) = 0;
                    A_ax (i,j,k) = 0;
                    A_ex (i,j,k) = 0;
                    T2st_my(i,j,k) = 0;
                    T2st_ax (i,j,k) = 0;
                    T2st_ex (i,j,k) = 0;
                    freq_my (i,j,k) = 0;
                    freq_ax (i,j,k) = 0;
                    freq_ex (i,j,k) = 0;
                    knot (i,j,k) = 0;
                    
                else
                    img_voxel_phase(img_voxel_mag <100) = [];
                    img_voxel_mag (img_voxel_mag <100) = [];
                    S1 = img_voxel_mag(1); 
                    Ph1 = img_voxel_phase(1);
                    theta = angle(S1 +exp(i*Ph1));
                    
                    myfittype = fittype('(A_my * exp(-t/T2st_my - i*2*pi*freq_my*t) + A_ax * exp(-t/T2st_ax - i*2*pi*freq_ax*t) + A_ex * exp(-t/T2st_ex - i*2*pi*freq_ex*t)) * exp(- i*knot)  ',...
                        'dependent', {'img_voxel'}, 'independent',{'t'},...
                        'coefficients', {'A_my', 'A_ax', 'A_ex', 'T2st_my', 'T2st_ax', 'T2st_ex','freq_my','freq_ax','freq_ex','knot'});
                  
                    

                    fitT2st = fit( TE_fit, img_voxel_mag, myfittype,...
                        'Start', [ 0.1*S1, 0.6*S1, 0.3*S1, 10, 64, 48, 5, 0, Ph1, Ph1, Ph1, theta],...
                        'Lower',[0, 0, 0, 3, 25, 25, -75, -25, Ph1-75, Ph1-25, Ph1-25, -pi],...
                        'Upper',[2*S1, 2*S1, 2*S1, 25, 150, 150, 75, 25, Ph1 +75, Ph1+25, Ph1+25, pi] ); %
                                  
                    T2stcoef = coeffvalues(fitT2st);
                    
                    
                    A_my (i,j,k) = T2stcoef(1);
                    A_ax (i,j,k) = T2stcoef(2);
                    A_ex (i,j,k) = T2stcoef(3);
                    T2st_my(i,j,k) = T2stcoef(4);
                    T2st_ax (i,j,k) = T2stcoef(5);
                    T2st_ex (i,j,k) = T2stcoef(6);
                    
                end
            end

        end
    end
end

MWF = A_my ./ (A_my + A_ax + A_ex + 0.000001); % add a small number to prevent divide by 0. 

%max(max(max(T2_star)));
%% testing

% i = 60;j = 60; k = 40;
% img_voxel = squeeze(mgre_ur_filt(i,j,k,:));
% TE =[0.00231,0.00653, 0.01094, 0.01516,0.01938, 0.0236,0.02782, 0.03204,0.03626, 0.04048, 0.0447, 0.04892,0.05314,0.05736,0.06158,0.0658];
% TE = TE * 1000; % convert to seconds
% figure; plot (TE, img_voxel)



%%%%%%% Potentially useful code: from David Rudko
   

% mag and phase matrix size dimension: np x nv x ns x ne

np=imsize(1); nv=imsize(2); ns=imsize(3); ne=imsize(4);

 

%% mask

mag_masked = mag.*mask;

img_complex=mag_masked.*exp(1i*ph);

 

%%

disp('Computing Local Field Gradients');

LFGro = zeros([np nv ns]);

LFGpe1 = zeros([np nv ns]);

LFGpe2 = zeros([np nv ns]);

denom = 2*pi*42.575e6 *(TE(2)-TE(1))* 2*1e-3;

 

%   Compute RO field gradient

W = zeros(np,nv,ns);X = zeros(np,nv,ns);

Y = zeros(np,nv,ns);Z = zeros(np,nv,ns);

W(1:np-1,:,:) = img_complex(2:np,:,:,2)./abs(img_complex(2:np,:,:,2));

X(1:np-1,:,:) = conj(img_complex(2:np,:,:,1))./abs(img_complex(2:np,:,:,1));

Y(2:np,:,:) = conj(img_complex(1:np-1,:,:,2))./abs(img_complex(1:np-1,:,:,2));

Z(2:np,:,:) = img_complex(1:np-1,:,:,1)./abs(img_complex(1:np-1,:,:,1));

LFGro = angle(W.*X.*Y.*Z)/(denom*vox(1));

 

%   Compute PE1 field gradient

W = zeros(np,nv,ns);X = zeros(np,nv,ns);

Y = zeros(np,nv,ns);Z = zeros(np,nv,ns);

W(:,1:nv-1,:)=img_complex(:,2:nv,:,2)./abs(img_complex(:,2:nv,:,2));

X(:,1:nv-1,:)=conj(img_complex(:,2:nv,:,1))./abs(img_complex(:,2:nv,:,1));

Y(:,2:nv,:)=conj(img_complex(:,1:nv-1,:,2))./abs(img_complex(:,1:nv-1,:,2));

Z(:,2:nv,:)=img_complex(:,1:nv-1,:,1)./abs(img_complex(:,1:nv-1,:,1));

LFGpe1=angle(W.*X.*Y.*Z)/(denom*vox(2));

 

%   Compute PE2 field gradient

W = zeros(np,nv,ns);X = zeros(np,nv,ns);

Y = zeros(np,nv,ns);Z = zeros(np,nv,ns);

W(:,:,1:ns-1)=img_complex(:,:,2:ns,2)./abs(img_complex(:,:,2:ns,2));

X(:,:,1:ns-1)=conj(img_complex(:,:,2:ns,1))./abs(img_complex(:,:,2:ns,1));

Y(:,:,2:ns)=conj(img_complex(:,:,1:ns-1,2))./abs(img_complex(:,:,1:ns-1,2));

Z(:,:,2:ns)=img_complex(:,:,1:ns-1,1)./abs(img_complex(:,:,1:ns-1,1));

LFGpe2=angle(W.*X.*Y.*Z)/(denom*vox(3));

 

LFG_square=(LFGro.^2+LFGpe1.^2+LFGpe2.^2);

 

 

%%

%   Create filter kernel. Can adjust convolution width (mm)

width = 2.5 .* [1/vox(1) 1/vox(2) 1/vox(3)];

wWIN = round(width*1.25);

wWIN = wWIN + (wWIN < 2);

wWIN = wWIN + ~mod(wWIN,2);

WIN = repmat(gausswin(wWIN(1),wWIN(1)/width(1)),[1 wWIN(2) wWIN(3)]);

WIN = WIN .* repmat(gausswin(wWIN(2),wWIN(2)/width(2))',[wWIN(1) 1 wWIN(3)]);

WIN = WIN .* repmat(reshape(gausswin(wWIN(3),wWIN(3)/width(3)),[1 1 wWIN(3)]),[wWIN(1) wWIN(2) 1]);

WIN = WIN./sum(WIN(:));

 

 

%   Compute susceptibility corrected image

%   Initialize corrected image

disp('Computing Susceptibility Corrected Images');

imgC = zeros(size(img_complex),'double');

weights = zeros(np,nv,ns,ne,'double');

for i = 1:ne

    wi = sinc(42.575e6 * LFGro * vox(1)  *1e-3 * TE(i)) .* ...

         sinc(42.575e6 * LFGpe1* vox(2)  *1e-3 * TE(i)) .* ...

         sinc(42.575e6 * LFGpe2* vox(3)  *1e-3 * TE(i));

%         wi = convn(wi,WIN,'same');

    wi = convn(wi.*mag_masked(:,:,:,i),WIN,'same')./convn(mag_masked(:,:,:,i),WIN,'same');

    weights(:,:,:,i) = wi;

    weights(weights < 0.25) = Inf;

    imgC(:,:,:,i) = mag_masked(:,:,:,i) ./ weights(:,:,:,i);

end

weights(weights == Inf) = 0;