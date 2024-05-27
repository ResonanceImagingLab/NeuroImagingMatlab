%% Coding a 2D b-spline

% B-splined derived by Cox-de Boor recurrence relation. 

% d = order spline => 3 % assume cubic
% U = knot vector (U1,...Um)



%% Inputs:

% fake data
[x, y] = ndgrid(1:50,1:50);
tmp = rand(50,50);
z = sin(x*0.25) + sin(y*0.25)+ tmp;
%figure; imagesc(z);
figure; scatter3(x(:),y(:),z(:))

[xvec, yvec, S] = deBoor_basis2D( [], [], z, 10, 10);

% Visualize:
[uu, vv] = ndgrid(xvec,yvec);

figure;
scatter3(x(:),y(:),z(:))
hold on;
surf(uu,vv,S,'FaceAlpha', 0.3, 'EdgeColor','none')



