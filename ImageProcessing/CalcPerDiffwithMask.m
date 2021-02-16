function vect = CalcPerDiffwithMask(data1, data2, mask,refString,LowLimit,HighLimit)
% reference string either "data1" or "average" for divisor

d1v = data1(mask >0);
d2v = data2(mask >0);

if strcmp(refString, 'data1')
    vect = 100*(d1v-d2v)./(d1v);
else
    vect = 100*(d1v-d2v)./((d1v+d2v)./2);
end

if exist('LowLimit','var') == 1
    vect(vect <LowLimit) = [];
end
if exist('HighLimit','var') == 1
    vect(vect > HighLimit) = [];
end