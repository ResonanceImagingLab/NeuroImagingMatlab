%%%%%%%%
%
% unring - tool for removal of the Gibbs ringing artefact
% Usage: outvol = unring(invol,params)
% Options: invol - input volume
%          params - 3x1 array with [minW maxW nsh]
%                     nsh discretization of subpixel spaceing (default 20)
%                     minW  left border of window used for TV computation (default 1)
%                     maxW  right border of window used for TV computation (default 3)


function nrrd_out = unring(nrrd_in, nrrd_out, params);
try
    if nargin == 2
        params = [1 3 20];
    end

    dwi = nrrdLoadWithMetadata(nrrd_in);
    dwi.data = double(dwi.data);
    dwi.data = ringRm(dwi.data, params);
    nrrdSaveWithMetadata(nrrd_out, dwi);
    exit
catch
    exit(1)
end
end
