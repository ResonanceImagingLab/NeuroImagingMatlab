%% Coding a 1D b-spline

% B-splined derived by Cox-de Boor recurrence relation. 

% d = order spline => 3 % assume cubic
% U = knot vector (U1,...Um)



%% Inputs:

% fake data
x = 1:0.25:20;
temp = rand(1,length(x));
y = sin(x) + 2*temp;
% scatter(x,y)

% b spline properties
d = 3; % degree polynomial
Np = 500; % number of control points



S = deBoor_basis(x, y, d, Np);


figure;
plot(x, y,'o');
hold on;
plot(x, y,'--');
hold on;
plot(S(1,:), S(2,:));
grid on;
grid minor;
xlabel('x');
ylabel('y');
legend({'Control points','Polygon','B-Spline-Approx.'}, 'Location', 'southeast');
ylim([min(S(2,:)) max(S(2,:))*1.25]);



