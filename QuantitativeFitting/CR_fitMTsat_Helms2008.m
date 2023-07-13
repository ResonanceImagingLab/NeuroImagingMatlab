function MTsat = CR_fitMTsat_Helms2008( ...
    R1, M0, MTw, flipAngle, TR, b1)

% Inputs:
% R1 map (1/T1) - units must match TR units
% M0 - or A_app, apparent signal map
% MTw - MT weighted image
% flipAngle is the flip angle in degrees
% TR - repetition time of the sequence. Units must match R1
% b1 - transmit B1 field. Optional. If included, then the
%       b1 factor is applied to the MTsat data.


% Calculation:
% Helms, G., Dathe, H., Kallenberg, K., Dechent, P., 2008. ...
% High-resolution maps of magnetization transfer with ...
% inherent correction for RF inhomogeneity and T1 ...
% relaxation obtained from 3D FLASH MRI. Magn. Reson. Med. 60, 1396?1407.

% Correction Factor:
% Weiskopf, N., Suckling, J., Williams, G., CorreiaM.M., ...
% Inkster, B., Tait, R., Ooi, C., Bullmore, E.T., Lutti, A., 2013. ...
% Quantitative multi-parameter mapping of R1, PD(*), ...
% MT, and R2(*) at 3T: a multi-center validation. Front. Neurosci. 7, 95.


% Written by Chris Rowley, 2023
%%%%%%%%%%%%%%%%%%%%%%%%%

alpha = deg2rad( flipAngle );

Msat = (M0.*alpha./ MTw -1) .*R1*TR - alpha.^2/2;

MTsat = Msat .* (1- 0.4)./ (1-0.4*b1);


