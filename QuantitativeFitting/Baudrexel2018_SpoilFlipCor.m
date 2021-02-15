function alpha_prime = Baudrexel2018_SpoilFlipCor(nominal_flip_angle, b1_map, TR, spoiling)
% This function corrects for incomplete RF spoiling of the transverse
% magnetization as reported in :
% Baudrexel, et al. "T1 mapping with the variable flip angle technique: a simple correction 
% for insufficient spoiling of transverse magnetization." Magnetic resonance in medicine 
% 79.6 (2018): 3082-3092.
% Always check your sequence for spoiling. If you don't have access to this information, try:
% GE scanner = 117, Siemens = 50, Philips = 150 

% Input Parameters:
% nominal_flip_angle -> flip angle prescribed in the sequence (in degrees)
% b1_map -> the relative realized flip angle (B1+ map)
% TR -> repetition time for the sequence (in milliseconds)
% spoiling -> degree increment of spoiling (either 50, 117, or 150). See
% paper for deriving custom values to sub into the P matrix below. 

% Output Parameter:
% alpha_prime 

% Overview:
% the respective nominal excitation angle is first multiplied with the normalized
% B1 map to obtain the actual excitation angle a for each pixel. 
% Subsequently, the correction factor C is calculated on the basis of the 
% flip angle map and the chosen TR,


if spoiling == 50
    % Fit parameters for 150 degree spoiling.
    P = [9.639e-1, 4.989e-3,  -1.254e-4, -3.180e-6, 1.527e-7, -1.462e-9;...
        5.880e-3, -1.056e-3,  4.801e-5,  -8.549e-7, 5.382e-9,         0;...
        4.143e-4, -4.920e-6,   -1.560e-7, 2.282e-9,         0         0;...
        -1.5059e-5, 2.334e-7,  -1.189e-9,        0,         0         0;...
        9.449e-8,  -1.025e-9,          0,        0,         0         0;...
        -4.255e-10, 	   0, 	       0,        0,         0         0];

elseif spoiling == 117
    % Fit parameters for 150 degree spoiling.
    P = [9.381e01, 4.266e-3, 2.535e-4, -2.289e-5, 5.402e-7, -4.146e-9;...
        1.653e-2, -2.172e-3, 7.491e-5, -1.051e-6, 5.313e-9,         0;...
        3.145e-4, 3.704e-5, -1.123e-6,  8.369e-9,         0         0;...
        -3.848e-5, 2.773e-7, 1.662e-9,         0,         0         0;...
        6.230e-7, -4.019e-9,          0,       0,         0         0;...
        -2.988e-9, 	      0, 	      0,       0,         0         0];

elseif spoiling == 150
    % Fit parameters for 150 degree spoiling.
    P = [6.678e-1, 9.131e-2, -7.728e-3, 2.863e-4, -4.869e-6 3.112e-8;...
        -3.710e-2, 2.845e-3, -7.786e-5, 8.546e-7, -2.837e-9,         0;...
        1.448e-3, -7.537e-5,  1.403e-6,-8.865e-9,         0         0;...
        -2.181e-5, 6.141e-7,  -5.141e-9,        0,         0         0;...
        1.990e-7, -1.978e-9,          0,        0,         0         0;...
        -8.617e-10, 	  0, 	      0,        0,         0         0];
else
    disp('error: Only configured for spoiling values of 50, 117 and 150 deg')
    return
end

%% Setup the fit polynomial
% Note flip is in degrees, TR in milliseconds
string = num2str(0);
for k = 0:5
	for l = 0:5
		if k+l <6
			string = strcat(string,'+',num2str( P(k+1,l+1)), '.*alpha.^',num2str(k),...
					  '.*TR.^',num2str(l));	
		end
	end
end

%% Generate the modified flip angle map
alpha = nominal_flip_angle *b1_map;
C = eval(string);
alpha_prime = alpha * C;


% 
%% Replicate their Figure 3 to confirm
% TR_v = 0:5:50;
% alpha_v = 2:2:60;
% 
% [alpha, TR]  = meshgrid(alpha_v, TR_v);
% 
% C = eval(string);
% 
% figure;
% surf(alpha,TR, C)
% ylabel('TR (ms)')
% xlabel('Flip Angle (degrees)')
% zlabel('C')


