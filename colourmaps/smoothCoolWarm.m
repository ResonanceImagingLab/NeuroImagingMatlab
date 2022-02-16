function cmap = smoothCoolWarm(m)
% Adapted from https://www.kennethmoreland.com/color-advice/
%
%  smoothCoolWarm(M) Creates a colormap with M colors
%
%   Inputs:
%       M - (optional) an integer between 1 and 256 specifying the number
%           of colors in the colormap. Default is 128.
%
%   Outputs:
%       CMAP - an Mx3 colormap matrix
%
%   Example:
%       imagesc(peaks(500))
%       colormap(smoothCoolWarm), colorbar
%
%   Example:
% figure;
%       imagesc(interp2(rand(10),2))
%       colormap(smoothCoolWarm); colorbar
%
% See also: hot, jet, hsv, gray, copper, bone, cold, vivid, colors
%


% Default Colormap Size
if ~nargin
    m = 128;
end

clrs = [59	76	192; ...
        104	137	238; ....
        154	186	255; ....
        201	216	240; ....
        237	209	194; ....
        247	168	137; ....
        226	106	83; ....
        180	4	38];

clrs = clrs/256; % normalize to 1




y = -3.5:3.5;
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

