function fxy = bSpline_Lee97(x, y, phi)
 
% in their paper, they use -1 as a start index, need to go from 1:m+3
% cooperate with matlab we separate, and call from indices

s = x - floor(x);
t = y - floor(y);

% if we write their equation 2 in matrix form:
Bmat = [-1 0 0 1;...
        3 -6 0 4;...
        -3 3 3 1;...
        1 0 0 0];

svec = [s^3; s^2; s^1; s^0];
tvec = [t^3; t^2; t^1; t^0];

Bk = (1/6) * Bmat * svec;
Bl = (1/6) * Bmat * tvec;

% Modify indexing from paper, it should be floor(x) -1, but we add 2 to
% that value so the lowest value we should see is 1 (a valid matlab index).
% this requires that the z matrix be padded with 2 at bottom and 3 up top.
% going with 3 and 3 for simplicity.

i = floor(x) +2;
j = floor(y) +2;

fxy = 0;
for k = 0:3
    for l = 0:3
        % include the minus 1 here.
        fxy = fxy + ( Bk(k+1) * Bl(l+1) * phi(i+k,j+l)); 
    end
end