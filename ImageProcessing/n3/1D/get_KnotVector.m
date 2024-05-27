function k = get_KnotVector(d,n)
% Calculate knot sequence.
% d: Degree of B-Spline
% n: Number of control points - 1
% Pads the sequence for repetitive ends
% k = [k0, ... , k_n+d+1] : Knot sequence / vector

k = zeros(1, (n+d+2));
k(d+1:n+d-1) = 0:n-d+1;
k(n+d:end) = n-d+1;
