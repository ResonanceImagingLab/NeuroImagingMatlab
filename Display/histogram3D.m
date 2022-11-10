function [values, centers] = histogram3D( inputVals, nbins)

% hist3, but for 3D data, no frills
% inputVals = [x,y,z];
% nbins, either 1 number for all dimensions, or 3 values (1 per dim)
%
% written by Christopher Rowley 2022



if size(inputVals,2) ~= 3
    error('Please enter an n x 3 matrix')
end

if ~exist('nbins','var') || isempty(nbins)
    nbins = 50;
end

if length(nbins) ~= 3
    nbins = [nbins(1), nbins(1), nbins(1)];
end


% At this point inputVals is n x 3, and nbins is 1 x 3

values = zeros(nbins);

% I think I will get most consistent results across matlab versions doing
% separate
minX = min(inputVals(:,1));
minY = min(inputVals(:,2));
minZ = min(inputVals(:,3));

maxX = max(inputVals(:,1));
maxY = max(inputVals(:,2));
maxZ = max(inputVals(:,3));

% generate vectors:
x_v = linspace(minX,maxX,nbins(1)+1);
y_v = linspace(minY,maxY,nbins(2)+1);
z_v = linspace(minZ,maxZ,nbins(3)+1);

% Calculate the centers of the bins:
centers{1,1} = ( x_v(2) - x_v(1))/2 + x_v(1:end-1);
centers{1,2} = ( y_v(2) - y_v(1))/2 + y_v(1:end-1);
centers{1,3} = ( z_v(2) - z_v(1))/2 + z_v(1:end-1);

%% no optimizations approach
% go through and mask out values, record length as values

X = inputVals(:,1);
Y = inputVals(:,2);
Z = inputVals(:,3);

oneM = ones(length(X),1);

for i = 1:nbins(1)

    for j = 1:nbins(2)

        for k = 1:nbins(3)
            
            idx = oneM(X>=x_v(i) & X<x_v(i+1) & ...
                        Y>=y_v(j) & Y<y_v(j+1) & ...
                        Z>=z_v(k) & Z<z_v(k+1));
            
            values(i,j,k) = length(idx);
                  
        end
        
    end
    
end































