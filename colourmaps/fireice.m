function cmap = fireice(m)
% FIREICE LightCyan-Cyan-Blue-Black-Red-Yellow-LightYellow Colormap
%
%  FIREICE(M) Creates a colormap with M colors
%
%   Inputs:
%       M - (optional) an integer between 1 and 256 specifying the number
%           of colors in the colormap. Default is 64.
%
%   Outputs:
%       CMAP - an Mx3 colormap matrix
%
%   Example:
%       imagesc(peaks(500))
%       colormap(fireice), colorbar
%
%   Example:
% figure;
%       imagesc(interp2(rand(10),2))
%       colormap(fireice); colorbar
%
% See also: hot, jet, hsv, gray, copper, bone, cold, vivid, colors
%
% Author: Joseph Kirk
% Email: jdkirk630@gmail.com
% Release: 1.0
% Date: 07/29/09


% Default Colormap Size
if ~nargin
    m = 64;
end

clrs = [0 0 1; 0.1 0.5 1; 0.1 0.9 0.95;...
    0.8 0.8 0.8; 0.95 0.9 0.1; 1 0.5 0.1; 1 0 0];

% 
%clrs = [0 0 1; 0.2 0.8 1; 0.3 0.7 0.9;...
%    0.8 0.8 0.8; 0.9 0.7 0.3; 1 0.8 0.2; 1 0 0];

%clrs = [0.75 1 1; 0 0.7 0.7; 0 0.6 0.8;...
%    0.7 0.7 0.7; 0.7 0.2 0.2; 0.7 0.7 0; 1 1 0.75];

y = -3:3;
if mod(m,2)
    delta = min(1,6/(m-1));
    half = (m-1)/2;
    yi = delta*(-half:half)';
else
    delta = min(1,6/m);
    half = m/2;
    yi = delta*nonzeros(-half:half);
end
cmap = interp2(1:3,y,clrs,1:3,yi);

