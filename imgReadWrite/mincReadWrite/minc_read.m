function [hdr,vol] = minc_read(file_name)
% Read a MINC file http://en.wikibooks.org/wiki/MINC
%
% [HDR,VOL] = MINC_READ(FILE_NAME,OPT)
%
% FILE_NAME (string) the name of a minc file.
% HDR 
%   FILE_NAME (empty string '') name of the file currently associated with the 
%      header.
%   TYPE (string) the file format (either 'minc1', 'minc2').
%   INFO (structure) simplified form of the header:
%      FILE_PARENT (string) name of the file that was read.
%      DIMENSIONS (vector 3*1) the number of elements in each dimensions of the 
%         data array. Warning : the first dimension is not necessarily 
%         the "x" axis. See the DIMENSION_ORDER field below.
%      PRECISION (string, 'float') the precision of data
%      VOXEL_SIZE (vector 1*3, default [1 1 1]) the size of voxels along each 
%         spatial dimension in the same order as in VOL.
%      TR (double, default 1) the time between two volumes (in second). 
%         This field is present only for 3D+t data.
%      T0 (double, default 0) the time corresponding to the first volume (in second).
%      MAT (2D array 4*4) an affine transform from voxel to world space.
%      DIMENSION_ORDER (cell of strings) describes the dimensions of vol. 
%         Typically 'xspace' (left to right), 'yspace' (posterior to anterior)
%         'zspace' (ventral to dorsal) and 'time', but could be anything really.
%      HISTORY (string) the history of the file.
%    DETAILS (structure) detailed form of the header, with the following fields:
%      DATA (structure) with the following fields:
%         IMAGE_MAX (double) the max of the volume.
%         IMAGE_MIN (double) the min of the volume.
%         TYPE (integer or string) the data type of the original minc volume.
%            VOL is always loaded as a float though.
%      GLOBALS (structure) with as many entries as global variables, and the 
%         following fields:
%         NAME (string) the name of the global variable 
%         VALUE (arbitrary) the value of the global variable.
%      VARIABLES (structure) with as many entries as variables, and the 
%         following fields:
%         NAME (string) the name of the global variable 
%         TYPE (integer or string) the type of the variable
%         ATTRIBUTES (cell) each entry is the (string) name of an attribute.
%         VALUES (cell) each entry is the (arbitrary) value of an attribute.
% VOL (array of double) the dataset.
%
% EXAMPLE:
% [hdr,vol] = minc_read('my_file.mnc');
%
% See license and notes in the code. 
% Maintainer : pierre.bellec@criugm.qc.ca
% Updated by: Amie Demmans (2024), demmansa@mcmaster.ca

% NOTE 1:
%   The strategy is different in Matlab and Octave.
%   In Matlab, the strategy is different for MINC1 (NetCDF) and MINC2 (HDF5).
%
%   In Matlab :
%      For MINC1, the function uses the NetCDF Matlab libraries. For MINC2, it
%      uses the HDF5 Matlab libraries.
%
%      For MINC2 files, the multiresolution feature is not supported. Only full
%      resolution images are read.
%
% NOTE 2:
%   VOL is the raw numerical array stored in the MINC file, in the so-called
%   voxel space. In particular, no operation is made to re-order dimensions.
%
% NOTE 3:
%   To read the content of variables in the minc file, see MINC_VARIABLE.
%
% NOTE 4:
%   The multi resolution feature of minc2 is not supported. Only the full resolution 
%   image is read. 
%
% NOTE 5:
%   The data is always read in float precision, whatever the original precision 
%   may be. 
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de
% gériatrie de Montréal, Département d'informatique et de recherche
% opérationnelle, Université de Montréal, 2013-2014.
%
% See licensing information in the code.
% Keywords : medical imaging, I/O, reader, minc, netcdf, hdf5
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

    % Test if the file name is a string
    if ~ischar(file_name) && ~isstring(file_name)
        error('FILE_NAME should be a string, for example ''my_file.mnc'' or ''my_file.mnc.gz''')
    end
    
    % Test if the file name has the right extension
    [file_path,file_core,file_ext] = fileparts(file_name);
    if ~ismember(file_ext,{'.mnc','.gz'})
        error('The extension of the file should be either .mnc or .mnc.gz')
    end
    
    % Deal with .mnc.gz files
    if strcmp(file_ext,'.gz')
        % This is a zipped file, unzip it in the temp folder and read it from there
        path_tmp = tempname;
        file_tmp = gunzip(file_name,path_tmp);
        [hdr,vol] = minc_read(file_tmp{1});
        rmdir(path_tmp,'s')
        return
    end
    
    if exist('OCTAVE_VERSION','builtin')
        %% This is Octave
        error('minc_read does not currently support Octave. Sorry dude I have to quit.')
    else
        %% This is Matlab
        %% Test if the file is in MINC1 or MINC2 format
        fid = fopen(file_name, 'r');
        if (fid < 0)
            error('Cannot open file %.',file_name);
        end
        % Read the first 4 bytes to detect the format
        f = fread(fid, [1 4], '*char');
        if isequal(f(2:4), 'HDF')
            hdr.type = 'minc2';
        elseif isequal(f(1:3), 'CDF')
            hdr.type = 'minc1';
        else
            error('Could not detect MINC version.');
        end
        % Close file
        fclose(fid);
    
        if strcmp(hdr.type,'minc1')
            ncid     = netcdf.open(file_name,'NOWRITE');
            [nbdims,nvars,ngatts] = netcdf.inq(ncid);
            hdr.type = 'minc1';
            if nargout>1
                [hdr,vol] = sub_read_matlab_minc1(hdr,ncid,nbdims,nvars,ngatts);
            else
                hdr = sub_read_matlab_minc1(hdr,ncid,nbdims,nvars,ngatts);
            end
        else
            % str_data = hdf5info(file_name);
            str_data = h5info(file_name);
            if nargout>1
                [hdr,vol] = sub_read_matlab_minc2(str_data,hdr,file_name);
            else
                hdr = sub_read_matlab_minc2(str_data,hdr,file_name);
            end
        end
    end
    
    % generate a simplified version of the header
    hdr.info = minc_hdr2info(hdr); % The bulk of the work is done in a separate function
    hdr.info.file_parent = which(file_name); 
    hdr.info.dimension_order = hdr.dimension_order; 
    hdr.info.dimensions = hdr.dimensions;
    hdr = rmfield(hdr,{'dimensions','dimension_order'});
    
    if nargout < 1
        return
    end
    
    % Apply the "unsigned" trick in minc 1
    if strcmp(hdr.type,'minc1')
        flag_unsigned = strcmp(minc_variable(hdr,'image','signtype'),'unsigned');
        vrange = minc_variable(hdr,'image','valid_range');
        if flag_unsigned
            vol(vol<0) = vol(vol<0) + vrange(2) + 1;
        end
    end
    
    % Normalize the data (eps = 2.2204e-16)
    
    if strcmp(hdr.type,'minc1')
        dataType = data_type_minc1(hdr.details.data.type);
    elseif strcmp(hdr.type, 'minc2')
        dataType = data_type_minc2(hdr.details.image(1).type);
    end
    
    if strcmp(dataType, 'single') || strcmp(dataType, 'double')
        return;
    end
    
    
    if size(hdr.details.data.image_min,2)>1
        error('Normalization with more than one dimension is not supported')
    end
    
    % Normalize vol with data type min and max
    if ~isempty(hdr.details.data.image_min)&&~isempty(hdr.details.data.image_max)
        % If image min and max are scalar 
        if (length(hdr.details.data.image_min)==1)&&(length(hdr.details.data.image_max)==1)&&...
                ((abs(min(vol(:))-hdr.details.data.image_min)>eps)||(abs(max(vol(:))-hdr.details.data.image_max)>eps))
    
            min_val = double(intmin(dataType)); 
            max_val = double (intmax(dataType));
            
            vol = ((vol - min(vol(:))) / (max(vol(:)) - min(vol(:)))) * (max_val - min_val) + min_val;

        % If image_min and max are vectors
        elseif (length(hdr.details.data.image_min)>1)&&(length(hdr.details.data.image_min)==length(hdr.details.data.image_max))&&...
                (length(hdr.details.data.image_min)==size(vol,ndims(vol))) 
    
            min_val = double(intmin(dataType)); 
            max_val = double (intmax(dataType)); 
    
            % Diff cases for if time is included as dimension
            switch ndims(vol)
                case 3
                    min_vol = squeeze(min(min(vol))); 
                    max_vol = squeeze(max(max(vol))); 
                    if any(abs(min_vol(:) - hdr.details.data.image_min(:)) > eps) || any(abs(max_vol(:) - hdr.details.data.image_max(:)) > eps)
    
                        weights = max_vol - min_vol; 
                        weights(weights == 0) = 1; 
    
                        min_vol = reshape(min_vol, [1, 1, length(min_vol)]);
                        weights = reshape(weights, [1, 1, length(weights)]);
    
                        min_vol = repmat(min_vol, [size(vol, 1), size(vol, 2), 1]);
                        weights = repmat(weights, [size(vol, 1), size(vol, 2), 1]);
    
                        vol = (vol - min_vol) ./ weights;
    
                        vol = vol * (max_val - min_val) + min_val;
                    end
    
                case 4
                    min_vol = squeeze(min(min(min(vol))));
                    max_vol = squeeze(max(max(max(vol))));
                    if any(abs(min_vol(:) - hdr.details.data.image_min(:)) > eps) || any(abs(max_vol(:) - hdr.details.data.image_max(:)) > eps)
    
                        weights = max_vol - min_vol;
                        weights(weights == 0) = 1; 
    
                        min_vol = reshape(min_vol, [1, 1, 1, length(min_vol)]);  
                        weights = reshape(weights, [1, 1, 1, length(weights)]);  
    
                        min_vol = repmat(min_vol, [size(vol, 1), size(vol, 2), size(vol,3), 1]);
                        weights = repmat(weights, [size(vol, 1), size(vol, 2), size(vol,3), 1]);
    
                        vol = (vol - min_vol) ./ weights;
    
                        vol = vol * (max_val - min_val) + min_val;
                    end
    
                otherwise
                    error('slice-based intensity normalization is not supported when the dimensionality of the array is not 3 or 4')
            end
        end
    end


%%%%%%%%%%%%%%%%%%%%%%
%% Matlab and MINC1 %%
%%%%%%%%%%%%%%%%%%%%%%

    function [hdr,vol] = sub_read_matlab_minc1(hdr,ncid,nbdims,nvars,ngatts)
        hdr.file_name = '';

        %% Read global attributes

        for num_g = 1:ngatts
            hdr.details.globals(num_g).name   = netcdf.inqAttName(ncid,netcdf.getConstant('NC_GLOBAL'),num_g-1);
            hdr.details.globals(num_g).values = netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),hdr.details.globals(num_g).name);
        end

        %% Read dimensions

        hdr.dimension_order = cell(1,nbdims);
        hdr.dimensions = zeros(1,nbdims);
        for num_d = 1:nbdims
            [hdr.dimension_order{num_d},hdr.dimensions(num_d)] = netcdf.inqDim(ncid,num_d-1);
        end
        hdr.dimension_order = hdr.dimension_order(end:-1:1); % in matlab, ordering of dimensions is reversed compared to NETCDF

        %% Read variables

        for num_v = 1:nvars
            [hdr.details.variables(num_v).name,hdr.details.variables(num_v).type,dimids,natts] = netcdf.inqVar(ncid,num_v-1);
            hdr.details.variables(num_v).attributes = cell([natts 1]);
            hdr.details.variables(num_v).values     = cell([natts 1]);
            for num_a = 1:natts
                hdr.details.variables(num_v).attributes{num_a} = netcdf.inqAttName(ncid,num_v-1,num_a-1);
                hdr.details.variables(num_v).values{num_a}     = netcdf.getAtt(ncid,num_v-1,hdr.details.variables(num_v).attributes{num_a});
            end
        end

        %% Read image-min / image-max / image type

        var_names = {hdr.details.variables(:).name};
        hdr.details.data.image_min = netcdf.getVar(ncid,find(ismember(var_names,'image-min'))-1);
        hdr.details.data.image_max = netcdf.getVar(ncid,find(ismember(var_names,'image-max'))-1);
        [tmp,hdr.details.data.type] = netcdf.inqVar(ncid,find(ismember(var_names,'image'))-1);

        %% Read volume

        if nargout > 1
            vol = double(netcdf.getVar(ncid,find(ismember(var_names,'image'))-1));
        end

        netcdf.close(ncid);
    end

%%%%%%%%%%%%%%%%%%%%%%
%% Matlab and MINC2 %%
%%%%%%%%%%%%%%%%%%%%%%

    function [hdr,vol] = sub_read_matlab_minc2(str_data,hdr,file_name)

        %% Globals

        hdr.details.globals.history = '';
        hdr.details.globals.ident = '';
        hdr.details.globals.minc_version = '';
        list_globals = {str_data.Groups.Attributes.Name};

        for num_global = 1:length(list_globals)
            if strfind(list_globals{num_global},'history')
                hdr.details.globals.history = str_data.Groups.Attributes(num_global).Value;
            elseif strfind(list_globals{num_global},'ident')
                hdr.details.globals.ident = str_data.Groups.Attributes(num_global).Value;
            elseif strfind(list_globals{num_global},'minc_version')
                hdr.details.globals.minc_version = str_data.Groups.Attributes(num_global).Value;
            end
        end

        %% Extract dimension order in a usable format

        tmp = h5readatt(file_name,'/minc-2.0/image/0/image','dimorder');
        ind = strfind(tmp,',');
        nb_dims = length(ind)+1;
        curr_pos = 1;
        ind = [ind length(tmp)];

        for num_dim = 1:nb_dims
            hdr.dimension_order{num_dim} = tmp(curr_pos:ind(num_dim)-1);
            curr_pos = ind(num_dim)+1;
        end

        if isequal(ind, [7, 14, 20])
            ind = strfind(tmp,',');
            nb_dims = length(ind)+1;
            curr_pos = 1;
            ind = [ind length(tmp)+1];
            for num_dim = 1:nb_dims
                hdr.dimension_order{num_dim} = tmp(curr_pos:ind(num_dim)-1);
                curr_pos = ind(num_dim)+1;
            end
        end

        hdr.dimension_order = hdr.dimension_order(end:-1:1); % Matlab/Octave invert dimension orders compared to HDF5
        hdr.file_name = '';
        labels        = {str_data.Groups.Groups(:).Name};

        %% Read dimensions length
        
        tmp = h5info(file_name,'/minc-2.0/image/0/image/');
        for num_dim = 1:nb_dims
            hdr.dimensions(num_dim) = tmp.Dataspace.Size(num_dim);
        end

        %% Read dimensions

        mask_dim  = ismember(labels,'/minc-2.0/dimensions');
        list_dimensions = {str_data.Groups.Groups(mask_dim).Datasets(:).Name};
        for num_d = 1:length(list_dimensions)

            hdr.details.variables(num_d).name        = list_dimensions{num_d};
            hdr.details.variables(num_d).attributes  = {str_data.Groups.Groups(mask_dim).Datasets(num_d).Attributes(:).Name};
            hdr.details.variables(num_d).values      = {str_data.Groups.Groups(mask_dim).Datasets(num_d).Attributes(:).Value};
            hdr.details.variables(num_d).type        = {str_data.Groups.Groups(mask_dim).Datasets(num_d).Datatype.Type};
            hdr.details.variables(num_d).size        = {str_data.Groups.Groups(mask_dim).Datasets(num_d).Dataspace.Type};
            hdr.details.variables(num_d).chunksize   = {str_data.Groups.Groups(mask_dim).Datasets(num_d).ChunkSize};
            hdr.details.variables(num_d).filters     = {str_data.Groups.Groups(mask_dim).Datasets(num_d).Filters};
            hdr.details.variables(num_d).fillValue   = {str_data.Groups.Groups(mask_dim).Datasets(num_d).FillValue};

        end

        %% Read Info

        mask_info  = ismember(labels,'/minc-2.0/info');
        nb_var = length(list_dimensions);

        if ~isempty(str_data.Groups.Groups(mask_info).Datasets)
            list_info = {str_data.Groups.Groups(mask_info).Datasets(:).Name};

            for num_d = 1:length(list_info)
                nb_var = nb_var+1;

                if  ~isempty(str_data.Groups.Groups(mask_info).Datasets(num_d).Attributes)

                    hdr.details.variables(nb_var).name        = list_info{num_d};
                    hdr.details.variables(nb_var).attributes  = {str_data.Groups.Groups(mask_info).Datasets(num_d).Attributes(:).Name};
                    hdr.details.variables(nb_var).values      = {str_data.Groups.Groups(mask_info).Datasets(num_d).Attributes(:).Value};
                    hdr.details.variables(nb_var).type        = {str_data.Groups.Groups(mask_info).Datasets(num_d).Datatype.Type};
                    hdr.details.variables(nb_var).size        = {str_data.Groups.Groups(mask_info).Datasets(num_d).Dataspace.Type};
                    hdr.details.variables(nb_var).chunksize   = {str_data.Groups.Groups(mask_info).Datasets(num_d).ChunkSize};
                    hdr.details.variables(nb_var).filters     = {str_data.Groups.Groups(mask_info).Datasets(num_d).Filters};
                    hdr.details.variables(nb_var).fillValue   = {str_data.Groups.Groups(mask_info).Datasets(num_d).FillValue};

                end
            end

        end

        %% Read image-min / image-max
        hdr.details.data.image_min = h5read(file_name,'/minc-2.0/image/0/image-min');
        hdr.details.data.image_max = h5read(file_name,'/minc-2.0/image/0/image-max');

        %% Read Image info
        mask_image  = ismember(labels,'/minc-2.0/image');
        list_image = {str_data.Groups.Groups(mask_image).Groups.Datasets(:).Name};
        for num_d = 1:length(list_image)

            hdr.details.image(num_d).name        = list_image{num_d};
            hdr.details.image(num_d).attributes  = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).Attributes(:).Name};
            hdr.details.image(num_d).values      = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).Attributes(:).Value};
            hdr.details.image(num_d).type        = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).Datatype.Type};
            hdr.details.image(num_d).size        = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).Dataspace.Type};
            hdr.details.image(num_d).chunksize   = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).ChunkSize};
            hdr.details.image(num_d).filters     = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).Filters};
            hdr.details.image(num_d).fillValue   = {str_data.Groups.Groups(mask_image).Groups.Datasets(num_d).FillValue};

        end

        %% Read volume
        if nargout>1

            vol = h5read(file_name,'/minc-2.0/image/0/image');
            vol = double(vol);

            % Rescale slices for max and min
            vol_rescale = vol;

            for i = 1:length(hdr.details.data.image_max)

                slice = vol(:,:,i);
                volMin = min(slice(:));
                volMax = max(slice(:));

                % Get a weird response where some images don't need
                % rescaling. Can check if the slice max already matches
                % Rounding/scaling issues, set arbitrary threshold to 0.01
                % If properly rescaled, it should be a greater change
                % anyway
                if abs(volMax - hdr.details.data.image_max(i)) < 0.01
                    vol_rescale(:,:,i) = vol(:,:,i); % don't scale
                else

                    vol_rescale(:,:,i) = ((vol(:,:,i) - volMin) ./ ...
                            (volMax - volMin)) .* (hdr.details.data.image_max(i) - ...
                            hdr.details.data.image_min(i)) + hdr.details.data.image_min(i);
                end

            end

            vol = vol_rescale;
            clear slice vol_rescale volMin volMax

        end
    end
end

