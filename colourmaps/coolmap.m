function cmap = coolmap(m)
% cool map LightCyan-Cyan-Blue-darkgreen-Lightgreen Colormap
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
%       imagesc(interp2(rand(10),2))
%       colormap(coolmap); colorbar
%
% clrs = [0.75 1 1;... %light cyan
%     0 1 1;... %cyan
%     0 0 1;... %blue
%     0 0.35 0.35;... %bluegreen
%     0 0.5 0;... %dark green
%     0 1 0;... %green
%     0.5 1 0.5]; % lime green


% Default Colormap Size
if ~nargin
    m = 64;
end

% LightCyan-Cyan-Blue-dark green-Lightgreen   % 0.47 0.79 0.47;
clrs = [0 0 0;... %black
    0 0 .9;... %blue
    0 1 0;... %dark green
    0.5 1 0.5;... %green
    0.8 1 1]; % lime green

y = -2:2;
if mod(m,2)
    delta = min(1,4/(m-1));
    half = (m-1)/2;
    yi = delta*(-half:half)';
else
    delta = min(1,4/m);
    half = m/2;
    yi = delta*nonzeros(-half:half);
end
cmap = interp2(1:3,y,clrs,1:3,yi);