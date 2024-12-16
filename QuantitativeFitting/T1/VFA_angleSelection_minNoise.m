function [a1, a2] = VFA_angleSelection_minNoise(TR, T1)

% provides the flip angles to use in a dual flip angle T1 estimation to
% minimize the noise, for a given TR and T1. 

% Note TR and T1 can be milliseconds or seconds, but they must be in the
% same units

% function based on the publication: 
% Helms, Gunther, et al. "Identification of signal bias in the variable flip 
% angle method by linear display of the algebraic Ernst equation." 
% Magnetic Resonance in Medicine 66.3 (2011): 669-677.
% https://onlinelibrary.wiley.com/doi/full/10.1002/mrm.22849

% Christopher Rowley 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

E1 = exp(-TR/T1);

% Ernst angle using their half-tangent substitute for angles below pi
% tao = 2*tan(alpha/2)

ernst = 2* sqrt( (1-E1)./(1+E1) );

% Use the values in table 1
tao1 = 0.4141*ernst;
tao2 = 2.4142*ernst;

% computer the angle
a1 = (atan(tao1./2)) * 2;
a2 = (atan(tao2./2)) * 2;

% convert the radians to degrees
a1 = rad2deg(a1);
a2 = rad2deg(a2);