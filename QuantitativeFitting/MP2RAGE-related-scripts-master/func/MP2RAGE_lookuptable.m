
function [Intensity, T1vector, IntensityBeforeComb]=MP2RAGE_lookuptable(nimages,MPRAGE_tr,invtimesAB,flipangleABdegree,nZslices,FLASH_tr,sequence,varargin)
% first extra parameter is the inversion efficiency
% second extra parameter is the alldata
%   if ==1 all data is shown
%   if ==0 only the monotonic part is shown

% Marques et al 2010, modified by Christopher Rowley 2023.

alldata=0;
if nargin >=9
    if ~isempty(varargin{2})
        alldata = varargin{2};
    end
end

invtimesa = invtimesAB(1);
invtimesb = invtimesAB(2);

B1vector = 1;
flipanglea = flipangleABdegree(1);
flipangleb = flipangleABdegree(2);

T1vector = 0.05:0.05:5;

if length(nZslices) == 2
    nZ_bef = nZslices(1);
    nZ_aft = nZslices(2);
    nZslices2 = (nZslices);   
    nZslices = sum(nZslices);
elseif length(nZslices) == 1
    nZ_bef = nZslices/2;
    nZ_aft = nZslices/2;
    nZslices2 = (nZslices);
end


j = 0;
Signal = zeros(length(T1vector), length(B1vector), 2 );

for T1 = T1vector
    j = j+1;
    for MPRAGEtr = MPRAGE_tr
        m = 0;
        for B1 = B1vector
            m = m+1;

            if and((diff(invtimesAB))>=nZslices*FLASH_tr, ...
                    invtimesa >= nZ_bef*FLASH_tr) && ...
                    invtimesb<=(MPRAGEtr-nZ_aft*FLASH_tr)

                if nargin == 7
                    Signal(j,m,1:2) = MPRAGEfunc(nimages,MPRAGEtr,invtimesAB,nZslices2,FLASH_tr,B1*[flipanglea flipangleb],sequence,T1);
                else
                    if ~isempty(varargin{1})
                        Signal(j,m,1:2) = MPRAGEfunc(nimages,MPRAGEtr,invtimesAB,nZslices2,FLASH_tr,B1*[flipanglea flipangleb],sequence,T1,varargin{1});
                    else
                        Signal(j,m,1:2) = MPRAGEfunc(nimages,MPRAGEtr,invtimesAB,nZslices2,FLASH_tr,B1*[flipanglea flipangleb],sequence,T1);
                        
                    end
                end
            else
                Signal(j,m,1:2) = 0;
            end
        end
    end
end

Intensity = squeeze(real(Signal(:,:,1).*conj(Signal(:,:,2)))./(abs(Signal(:,:,1)).^2+abs(Signal(:,:,2)).^2));
T1vector = squeeze(T1vector);

if alldata == 0
    [~, minindex] = max(Intensity);
    [~, maxindex] = min(Intensity);
    Intensity = Intensity(minindex:maxindex);
    T1vector = T1vector(minindex:maxindex);
    IntensityBeforeComb = squeeze(Signal(minindex:maxindex,1,:));
    Intensity([1 end]) = [0.5 -0.5]; % pads the look up table to avoid points that fall out ot the lookuptable
else
    Intensity = squeeze(real(Signal(:,:,1).*conj(Signal(:,:,2)))./(abs(Signal(:,:,1)).^2+abs(Signal(:,:,2)).^2));
    T1vector = squeeze(T1vector);
    IntensityBeforeComb = squeeze(Signal(:,1,:));
end
