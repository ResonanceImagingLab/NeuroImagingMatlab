function [R1, M0] = CR_fit_R1_Aapp_Helms2008( ...
    lfa, hfa, flipAngle1, flipAngle2, TR1, TR2, b1)

% Inputs:
% lfa - low flip angle image
% hfa - high flip angle image (T1w image)
%flipAngle1(2) - in degrees, for the low (high) flip angle images
% TR1(2) - repetition time of the sequence. Units will match R1
% b1 - transmit B1 field. Optional. If included, then the
%       b1 factor is applied to the MTsat data. If you aren't interested,
%       set == 1.


% Calculation:
% Helms, G., Dathe, H., Kallenberg, K., Dechent, P., 2008. ...
% High-resolution maps of magnetization transfer with ...
% inherent correction for RF inhomogeneity and T1 ...
% relaxation obtained from 3D FLASH MRI. Magn. Reson. Med. 60, 1396?1407.

% Correction Factor:
% This uses the corrected equations from https://onlinelibrary.wiley.com/doi/10.1002/mrm.22607


% Written by Chris Rowley, 2023
%%%%%%%%%%%%%%%%%%%%%%%%%

a1 = deg2rad( flipAngle1 );
a2 = deg2rad( flipAngle2 );

a1 = a1.*b1;
a2 = a2.*b1;

R1 = 0.5 .* (hfa.*a2./ TR2 - lfa.*a1./TR1) ./ (lfa./(a1) - hfa./(a2));
M0 = lfa .* hfa .* (TR1 .* a2./a1 - TR2.* a1./a2) ./ (hfa.* TR1 .*a2 - lfa.* TR2 .*a1);