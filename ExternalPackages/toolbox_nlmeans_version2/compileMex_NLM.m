% Compile instructions:

% I have compiled these for R2023b and it worked. 
% If running into issues, check out the discussion here: 
% https://www.mathworks.com/matlabcentral/fileexchange/27395-fast-non-local-means-1d-2d-color-and-3d

mex -v -compatibleArrayDims vectors_nlmeans_single.c
mex -v -compatibleArrayDims image2vectors_single.c
mex -v -compatibleArrayDims vectors_nlmeans_double.c
mex -v -compatibleArrayDims image2vectors_double.c 