function [T1map, bmap, amap, resmap, idxmap] = fit_T1_IR_data(img, TI, mask, method)

% I keep getting issues the qMRlab code, so lets adapt it.
% Currently assumes 2D


% Fit to Barral Model: a+b*exp(-TI/T1)
% Assume magnitude only data. Complex data is probably better handled by
% qMRlab

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Round 2, taking from qMRlab

if ~exist('method', 'var')
    method = 'Magnitude';
    disp('No method provided, assuming magnitude data');
end

[x,y,z,nT] = size(img);

% this assumes 3D... Can hack and add a dummy dimension using:
if nT == 1
    img = shiftdim(img,-1);  
    img = permute(img,[2,3,1,4]);
    [x,y,z,nT] = size(img);
end

if nT ~= length(TI)
    error('Mismatch between TIs provided and number of images')
end

% Arrange voxels into a column
nV = x*y*z;     % number of voxels

data = reshape(img,nV,nT);
maskv = reshape(mask,nV,nT);

% Find where mask exists
Voxels = find(all(maskv,2)); 
numVox = length(Voxels);


extra.tVec = TI;
extra.T1Vec = 1:5000; % Range can be reduced if a priori information is available
nlsS = getNLSStruct(extra,0);


T1 = zeros(numVox,1);
b = zeros(numVox,1);
a = zeros(numVox,1);
res = zeros(numVox,1);

if strcmp(method,'Magnitude')
    idx = zeros(numVox,1);
    data = abs(data);
end


tic
for i = 1:numVox
    switch method
        case{'Complex'}
            [T1(i),b(i),a(i),res(i)] = rdNls( data(i,:), nlsS);
        case{'Magnitude'}
            [T1(i),b(i),a(i),res(i),idx(i)] = rdNlsPr( data(i,:), nlsS);
    end
    if mod(i,1000) == 0
        str = [num2str(i/numVox * 100), '% done'];
        disp(str)
    end
end
toc


% Convert it back:
T1map = zeros(x,y,z);
bmap = zeros(x,y,z);
amap = zeros(x,y,z);
resmap = zeros(x,y,z);


T1map(Voxels) = T1;
bmap(Voxels) = b;
amap(Voxels) = a;
resmap(Voxels) = res;

if strcmp(method,'Magnitude')
    idxmap = zeros(x,y,z);
    idxmap(Voxels) = idx;
else
    idxmap = [];
end







end
























