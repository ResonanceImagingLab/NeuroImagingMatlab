function B = get_BaseSpline(i, d, ui, k)
% Calculate Base B-Spline B_i,d
% d: B-Spline degree
% k: Knot vector
% pz: Current p point
%
% Output:
% B: Base B-Spline at t.

% Index shift
j = i + 1;

if d == 0
    % Corrected end of recursion
    if (ui >= k(j) && ui < k(j+1))
        B = 1;
    % Exception: the last basis function is equal to 1 also at the last knot.
    elseif ( k(j+1) == k(end) && ui == k(end))
        B = 1;
    else
        B = 0;
    end
else
    % Cox-de Boor reccurence relation:
    % Check dividing by zero caused by padding ends:
    if k(j+d) ~= k(j)
        A = (ui -k(j))/(k(j+d) - k(j));
    else
        A = 0;
    end

    if k(j+d+1) ~= k(j+1)
        B = (k(j+d+1) - ui) / (k(j+d+1) - k(j+1));
    else
        B = 0;
    end
    % Calculate base B-Spline
    B1 = get_BaseSpline(i,   d-1, ui, k);
    B2 = get_BaseSpline(i+1, d-1, ui, k);
    B = A * B1 + B * B2;
end


end
