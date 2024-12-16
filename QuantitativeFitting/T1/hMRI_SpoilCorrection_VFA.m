%% hMRI R1 mapping with spoiling correction

% Requires SPM12
addpath(genpath('E:\GitHub\spm12'))
% Requires hMRI toolbox
addpath(genpath('E:\GitHub\hMRI-toolbox'))

% Other handy scripts:
addpath(genpath('E:\GitHub\NeuroImagingMatlab'))
addpath(genpath('E:\GitHub\mominc-master'))

%% Load two images for R1 calc
fn = 'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\t20210930_ihMT_3prot_test\minc\register\lfa_reg.mnc';
[hdr, lfa] = minc_read(fn);

fn = 'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\t20210930_ihMT_3prot_test\minc\register\hfa_reg.mnc';
[hdr2, hfa] = minc_read(fn);

fn = 'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\t20210930_ihMT_3prot_test\minc\register\resampled_b1field.mnc';
[hdr3, b1] = minc_read(fn);

mask = zeros(size(lfa));
mask(lfa > 100) = 1;

%% Applicable functions: 
% hmri_corr_imperf_spoil(job)
% hmri_calc_R1
% hmri_calc_A

%% Goal is to apply these without the damn GUI and spm interface

% I think B1 needs to be in percent
b1map = b1;
figure; imshow3Dfull(b1, [0.6 1.5],jet)

figure; imshow3Dfull(lfa)


%% R1 and App calc

low_flip_angle  = 4;       % flip angle in degrees -> USER DEFINED
high_flip_angle = 20;      % flip angle in degrees -> USER DEFINED
TR_lfa          = 14/1000;      % low flip angle repetition time of the GRE kernel in milliseconds -> USER DEFINED
TR_hfa          = 14/1000;      % high flip angle repetition time of the GRE kernel in milliseconds -> USER DEFINED

smallFlipApprox = false;   % For which model to use

a1 = deg2rad(low_flip_angle); 
a2 = deg2rad(high_flip_angle); 

R1 = hmri_calc_R1(struct( 'data', lfa, 'fa', a1, 'TR', TR_lfa, 'B1', b1),...
           struct( 'data', hfa, 'fa', a2, 'TR', TR_hfa, 'B1', b1), smallFlipApprox);

App = hmri_calc_A(struct( 'data', lfa, 'fa', a1, 'TR', TR_lfa, 'B1', b1),...
           struct( 'data', hfa, 'fa', a2, 'TR', TR_hfa, 'B1', b1), smallFlipApprox);


figure; imshow3Dfull(R1, [0 9],jet)
figure; imshow3Dfull(App.*mask, [0 8000],gray)
% T1
figure; imshow3Dfull(1./R1*1000 .*mask, [300 2500],jet)

%% Imperfect spoiling correction for R1 or T1

% Calculate coefficients:

% you could open the GUI and set parameters
% spm fmri -> batch -> tools -> hMRI -> imperfectSpoilCalc

% This still requires spm, and hMRI toolbox!

% We will try to do it here:
param.prot_name          = 'test_vfa';    % Used in output
param.outdir             = 'E:\Research';

fnJSON = fullfile(param.outdir,[strrep(param.prot_name,' ',''),'.json']);

if ~isfile(fnJSON)

     % File does not exist calculate:
     % Seq Params
    param.FA_deg             = [4,20];
    param.TR_ms              = [14,14];
    param.Phi0_deg           = 50;              % RF spoil increment[deg]
    param.B1range            = 0.6:0.05:1.4;    % convert such that 100% = 1
    param.Gdur_ms            = 1.475;          % [ms]
    param.Gamp_mT_per_m      = 24;              % [[mT/m]
    param.T1range_ms         = 600:100:2500;  %[ms]
    param.T2range_ms         = 50;            % [ms]
    param.D_um2_per_ms       = 0.8;           % [um^2/ms]
    param.small_angle_approx = smallFlipApprox; % KEEP CONSISTENT
    
    % With parameters set, calculate coefficients
    hmri_corr_imperf_spoil_noGUI( param )
end


%% The results are applied with: T1=A(B1eff)+B(B1eff)*T1app

% get the json data:
% val = jsondecode(fileread( fnJSON));

% I have wrote to a mat file
coeff = load(fullfile(param.outdir,[strrep(param.prot_name,' ',''),'_ABcoeff.mat']) );

% Note in Preibisch and Deichmann 2009, A and B are quadratic functions
% dependent on b1map.

% Get coefficients from json:
Acoef = coeff.polyCoeffA;
Bcoef = coeff.polyCoeffB;

% Make correction factors:
A = Acoef(1)*b1map.^2 - Acoef(2)*b1map + Acoef(3);
B = Bcoef(1)*b1map.^2 - Bcoef(2)*b1map + Bcoef(3);

% Apply to the T1 map - in milliseconds as simulations are done in ms
T1app = (1./R1) * 1000;
T1 = A + B.*T1app;

figure; imshow3Dfull(T1app .*mask, [300 2500],jet)

figure; imshow3Dfull(T1 .*mask, [0 5000])








