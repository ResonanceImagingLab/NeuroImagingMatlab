function cmplxImg = CR_magPhase2cmplx(mag, phase, phaseUnits)

% combine magnitude and phase images to get a complex image
% needed for fitting some models

% A good write up on this can be found here if learning: https://mriquestions.com/real-v-imaginary.html

if strcmp(phaseUnits, 'rad')
    
    disp(' input units for phase is radians' ) % phase = phase; good as iss 
    
elseif strcmp(phaseUnits, 'degrees')
    
    disp(' input units for phase is deg' )
    phase = deg2rad(phase);
    
else
    error('Phase units must be specified as deg or rad')
end

realImg = mag .* cos(phase);
imaginaryImg = mag .* sin(phase);

cmplxImg = complex( realImg, imaginaryImg);







