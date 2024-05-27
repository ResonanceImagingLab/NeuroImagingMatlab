function S = deBoor_basis(x, y, d, Np)
% Calculates a B-Spline of degree m using the control points C.
% 
% x ,y 2-dimensional control points (x_0, ... , x_n; y_0, ... , y_n)
% d: B-Spline degree
% Np: number of evenly spaced points in knot vector.
%
% s: B-Spline. s(1,:) -> x component, s(2,:) -> y component

%% Parameters

% Number of control point - 1
n = length(x) - 1;

% Knot vector, need to pad the end values
kV = get_KnotVector(d,n);

% B-Spline interval
u = linspace(0, n-d+1, Np);

%% Calculate B-Spline
S = zeros(2,Np);

for z = 1:length(u)
    ui = u(z);

    for i = 0 : n
        % Base B-Spline
        B = get_BaseSpline(i, d, ui, kV);
        % x component
        S(1,z) = S(1,z) + x(i+1) * B;
        % y component
        S(2,z) = S(2,z) + y(i+1) * B;
    end
end
