function [xvec, yvec, S] = deBoor_basis2D( xvec, yvec, z, Npx, Npy)
% Calculates a B-Spline of degree m using the control points x,y,z.
% 
% x ,y are 2D grids. If empty, we make the grids with uniform spacing.
% d: B-Spline degree
% Np: number of evenly spaced points in knot vector.
%
% s: B-Spline. s(1,:) -> x component, s(2,:) -> y component

%% Parameters
[z1, z2] = size(z);

if isempty(xvec) 
    xvec = linspace(1,z1, Npx);
end
if isempty(yvec)
    yvec = linspace(1,z2, Npy);
end
S = zeros(Npx+6,Npy+6);

%% Pad vectors:
xvec = [xvec(1), xvec(1), xvec(1), xvec, xvec(end), xvec(end), xvec(end)];
yvec = [yvec(1), yvec(1), yvec(1), yvec, yvec(end), yvec(end), yvec(end)];

% pad matrices for calc, add 3 each side:
[z1, z2] = size(z);
zpad = zeros(z1+6, z2+6);
zpad(1:3, 4:z2+3) = repmat(z(1,:),[3,1]);
zpad(z1+4:end, 4:z2+3) = repmat(z(end,:),[3,1]);

zpad( 4:z1+3, 1:3) = repmat(z(:,1),[1,3]);
zpad( 4:z1+3, z2+4:end) = repmat(z(:,end),[1,3]);
zpad( 4:z1+3, 4:z2+3) = z;

%% The calculation
for i = 1:length(xvec)
    for j = 1:length(yvec)
        S(i,j) = bSpline_Lee97(xvec(i), yvec(j), zpad);
    end
end

%% remove padding:
xvec([1:3,end-2:end]) = [];
yvec([1:3,end-2:end]) = [];

S([1:3,end-2:end],:) = [];
S(:,[1:3,end-2:end]) = [];