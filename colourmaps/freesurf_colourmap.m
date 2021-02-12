function cmap = freesurf_colourmap(m)
%   Inputs:
%       M - (optional) an integer between 1 and 256 specifying the number
%           of colors in the colormap. Default is 64.
%
%   Outputs:
%       CMAP - an Mx3 colormap matrix
%
%   Example:
%       imagesc(peaks(500))
%       colormap(freesurf_colourmap), colorbar
%
%   Example:
%       imagesc(interp2(rand(10),2))
%       colormap(freesurf_colourmap); colorbar
%
% clrs = 
%dark purple = 0 0 0 
%purple = 0.3 0 0.5
%greyish blue 0.2 0.2 0.4
%light blue 0.4 0.6 0.8

%dark green 0 0.6 0.2
%lime green 0.2 1 0

%yellow 1 1 0
%orange 1 0.5 0
%red  1 0 0 


% Default Colormap Size
if ~nargin
    m = 64;
end

% 
clrs = [0.05 0 0.15; 0.3 0 0.5; 0.2 0.2 0.7; 0.2 0.5 0.8;...
    0 0.6 0.2;0.2 1 0;1 1 0;1 0.5 0;1 0 0 ]; % 

y = -4:4;
if mod(m,2)
    delta = min(1,8/(m-1));
    half = (m-1)/2;
    yi = delta*(-half:half)';
else
    delta = min(1,8/m);
    half = m/2;
    yi = delta*nonzeros(-half:half);
end
cmap = interp2(1:3,y,clrs,1:3,yi);