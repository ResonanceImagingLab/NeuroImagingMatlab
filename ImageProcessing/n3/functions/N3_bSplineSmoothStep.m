function bias = N3_bSplineSmoothStep(r, utrue,vtrue, xNodeSpacing, yNodeSpacing)

% Smooth using cubic b-spline, then interpolate back to image size.
% might want to change it for the spacing size of nodes

if isempty(xNodeSpacing)
    xNodeSpacing = 25;
end

if isempty(yNodeSpacing)
    yNodeSpacing = 25;
end

[xvec, yvec, S] = deBoor_basis2D( [], [], r, xNodeSpacing, yNodeSpacing);
[uu, vv] = meshgrid(yvec, xvec);

bias = interp2(uu,vv,S,utrue,vtrue);





















