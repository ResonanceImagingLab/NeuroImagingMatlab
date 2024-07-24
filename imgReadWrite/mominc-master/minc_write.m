function [] = minc_write(file_name, hdr, vol)

    
    if ~ischar(file_name)
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

    if nargin<2
        error('Need to provide hdr and vol info')
    end 
    
    % % Test if the file is in MINC1 or MINC2 format
    % fid = fopen(file_name, 'r');
    % if (fid < 0)
    %     error('Cannot open file %.',file_name);
    % end
    % % Read the first 4 bytes to detect the format
    % f = fread(fid, [1 4], '*char'); 
    % if isequal(f(2:4), 'HDF')
    %     hdr.type = 'minc2';
    % elseif isequal(f(1:3), 'CDF')
    %     hdr.type = 'minc1';
    % else
    %     error('Could not detect MINC version.');
    % end
    % % Close file
    % fclose(fid);

    % Apply minc_write function if file is minc1 or minc2 
    if strcmp(hdr.type, 'minc1')
        minc1_write(file_name,hdr,vol)
    elseif strcmp(hdr.type, 'minc2')
        minc2_write(file_name,hdr,vol);
    end 


end 

function minc1_write(file_name, hdr, vol)

    % Create netCDF file 
    ncid = netcdf.create(file_name, 'CLOBBER'); % CLOBBER overwrite any existing file with same name 

    % Create new dimension specified by ncid 
    dimid = zeros(1, length(hdr.info.dimension_order));

    for i = 1:length(hdr.info.dimension_order)
        dim_name = hdr.info.dimension_order{i};
        dim_size = hdr.info.dimensions(i);
        dimid(i) = netcdf.defDim(ncid, dim_name, dim_size);
    end 

    % Define new variable and attributes 
    varid = netcdf.defVar(ncid, 'image', 'NC_DOUBLE', dimid);
    netcdf.putAtt(ncid, varid, 'valid_range', [hdr.details.data.image_min, hdr.details.data.image_max]);

    % Define global attributes 
    nglobalatt = length(hdr.details.globals);
    for num_g = 1:nglobalatt
        if strcmp(hdr.details.globals(num_g).name,'history')
            % The history specified in hdr.info.history overrides what's stored in the header
            netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),hdr.details.globals(num_g).name,hdr.info.history);         
        else
            netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),hdr.details.globals(num_g).name,hdr.details.globals(num_g).values);
        end
    end

    % End definitions --> move into data mode 
    netcdf.endDef(ncid);

    % Write data 
    netcdf.putVar(ncid, varid,vol);

    % Close data
    netcdf.close(ncid);

end 


function minc2_write(file_name, hdr, vol)

    % Create HDF5 file 
    h5create(file_name, '/minc-2.0/image/0/image', size(vol), 'Datatype', 'double');

    % Write HDF5 file 
    h5write(file_name, '/minc-2.0/image/0/image', vol);

    % Write dimensions 
    
    for i = 1:length(hdr.info.dimension_order)
        dim_name = hdr.info.dimension_order{i};
        disp(dim_name)
        dim_size = hdr.info.dimensions(i);
        disp(dim_size)
        
        h5create(file_name, ['/minc-2.0/dimensions/' dim_name], 1, 'Datatype', 'int32');
        h5write(file_name, ['/minc-2.0/dimensions/' dim_name], dim_size);

        % Dimension Attributes 
        %dim_attrs = hdr.details.variables.(dim_name);
        % disp(dim_attrs)
        % for attr_name = fieldnames(dim_attrs)
        %     h5writeatt(file_name, ['/minc-2.0/dimensions/' dim_name], attr_name{1}, dim_attrs.(attr_name{1}) );
        % end 
       
    end 
    % Write global attributes
    %globals = hdr.details.globals;
    h5writeatt(file_name, '/minc-2.0', 'ident', hdr.details.globals.ident);
    h5writeatt(file_name, '/minc-2.0', 'minc_version', hdr.details.globals.minc_version);
    h5writeatt(file_name, '/minc-2.0', 'history', hdr.details.globals.history);

    % Write image attributes
    image_attrs = hdr.details.image;
    for i = 1:length(image_attrs)
        attr_name = image_attrs(i).name;
        attr_values = image_attrs(i).values;
        for j = 1:length(attr_values)
            h5writeatt(file_name, '/minc-2.0/image/0/image', attr_name, attr_values{j});
        end
    end

    % Write valid_range attribute
    h5writeatt(file_name, '/minc-2.0/image/0/image', 'valid_range', [hdr.details.data.image_min, hdr.details.data.image_max]);

    % Create and Write image min and max
    h5create(file_name, '/minc-2.0/image/0/image-min', size(hdr.details.data.image_min), 'Datatype', 'double');
    h5write(file_name, '/minc-2.0/image/0/image-min', hdr.details.data.image_min);
    h5create(file_name, '/minc-2.0/image/0/image-max', size(hdr.details.data.image_max), 'Datatype', 'double');
    h5write(file_name, '/minc-2.0/image/0/image-max', hdr.details.data.image_max);

    % Write info group and datasets 
    info = hdr.details.info; 
    for info_group = fieldnames(info)
        info_group_name = info_group{1};
        h5create(file_name, ['/minc-2.0/info' info_group_name], 1, 'Datatype', 'int32');
        h5write(file_name, ['/minc-2.0/info' info_group_name], info.(info_group_name).size);

        info_attrs = info.(info_group_name).attributes;
        for attr_name = fieldnames(info_attrs)
            h5writeatt(file_name, ['/minc-2.0/info' info_group_name], attr_name{1}, info_attrs.(attr_name{1}));
        end 
    end 



end 



    % % Dimension attributes 
    % dim_attrs = hdr.details.variables;
    % for i = 1:length(dim_attrs)
    %     dimatt_name = dim_attrs(i).name;
    %     dimatt_values = dim_attrs(i).values;
    %     for j = 1:length(dimatt_values)
    %         h5writeatt(file_name, '/minc-2.0/dimensions', dimatt_name, dimatt_values{j});
    %     end 
    % end 




















