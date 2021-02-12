function h = hot_threshold(m)
%   Example:
%       imagesc(interp2(rand(10),2))
%       colormap(hot_threshold); colorbar

if ~nargin
    m = 64;
end

% white- yellow-Red-grey- grey -black
clrs = [1 1 1; 1 1 0 ; 1 0 0;...
    0.6 0.6 0.6; 0.6,0.6,0.6; 0.2 0.2 0.2 ; 0 0 0 ];

% clrs = [1 1 1; 1 1 0 ; 1 0.4 0;...
%     1 0 0; 0.6,0.6,0.6; 0.2 0.2 0.2 ; 0 0 0 ];

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
h = interp2(1:3,y,clrs,1:3,yi);


