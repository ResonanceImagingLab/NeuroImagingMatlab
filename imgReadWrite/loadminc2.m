function [imaVOL,scaninfo] = loadminc2(filename)
% Taken from: https://www.mathworks.com/matlabcentral/fileexchange/4706-mia-2-5
%function [imaVOL,scaninfo] = loadminc2(filename)
%
% Function to load minc format input file. 
% This function use the netcdf MATLAB utility
%
% Built to read MINC2 HDF files - HDF5 - another file format library (used for MINC2)
% look at minc_read in mominc-master for help. I started changing it, the
% main problem was they used hdf5info, which is no longer a supported
% matlab function.

%
% Christopher Rowley 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hf = fopen(filename,'r');
precision_data = 'float';
try
    vol = fread(hf,prod(hdr.info.dimensions),['*' precision_data]);
catch
    vol = fread(hf,prod(hdr.info.dimensions),precision_data);
end



%% OLD FOR netcdf - akak minc1
if nargin == 0
     [FileName, FilePath] = uigetfile('*.mnc','Select minc file');
     filename = [FilePath,FileName];
     if FileName == 0
          imaVOL = [];scaninfo = [];
          return;
     end
end
ncid=netcdf.open(filename,'NC_NOWRITE');
scaninfo.filename = filename;
varid = netcdf.inqVarID(ncid,'image-max');
slice_max = netcdf.getVar(ncid,varid,'float');
scaninfo.mag = slice_max;
maxx = max(slice_max(:));
if maxx == round(maxx)
   precision = 'short';
   scaninfo.float = 0;
else
   precision = 'float';
   scaninfo.float = 1;
end
varid = netcdf.inqVarID(ncid,'image');
volume = netcdf.getVar(ncid,varid,precision);
varid = netcdf.inqVarID(ncid,'image-min');
slice_min = netcdf.getVar(ncid,varid,precision);
scaninfo.min = slice_min;
netcdf.close(ncid);
imaVOL = zeros(size(volume));
for i=1: size(volume,3)
    currentslice = volume(:,:,i);
    imaVOL(:,:,i) = permute((currentslice - min(currentslice(:))) / ( max(currentslice(:))- min(currentslice(:)) )...
        *(slice_max(i)- slice_min(i)) - slice_min(i),[2 1]); 
end
