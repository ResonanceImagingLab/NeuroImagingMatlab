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
    

    % Apply minc_write function if file is minc1 or minc2 
    if strcmp(hdr.type, 'minc1')
        minc1_write(file_name,hdr,vol)
    elseif strcmp(hdr.type, 'minc2')
        minc2_write(file_name,hdr,vol);
    end 


end 

function minc1_write(file_name, hdr, vol)

    % Test 
    % file = 'DeepStructureMask.mnc';
    % [hdr, vol] = minc_read(file);
    % file_name = 'DSM.mnc';

    % Create netCDF file 
    ncid = netcdf.create(file_name, 'CLOBBER'); % CLOBBER overwrite any existing file with same name 

    % Create new dimension specified by ncid 
    dimid = zeros(1, length(hdr.info.dimension_order));

    for i = 1:length(hdr.info.dimension_order)
        dim_name = hdr.info.dimension_order{i};
        dim_size = hdr.info.dimensions(i);
        dimid(i) = netcdf.defDim(ncid, dim_name, dim_size);
    end 

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


    % Define variable attributes
    for i = 1:length(hdr.details.variables)-1
        var_name = hdr.details.variables(i).name;
        varid = netcdf.defVar(ncid, var_name, hdr.details.variables(i).type,[]);

        for j = 1:length(hdr.details.variables(i).attributes)
        netcdf.putAtt(ncid, varid, hdr.details.variables(i).attributes{j,1}, hdr.details.variables(i).values{j,1})
        end

    end 

   
    last_var = hdr.details.variables(end).name;
    last_varid = netcdf.defVar(ncid, last_var, hdr.details.variables(end).type, dimid);
    for j = 1:length(hdr.details.variables(end).attributes)
    netcdf.putAtt(ncid, last_varid, hdr.details.variables(end).attributes{j, 1}, hdr.details.variables(end).values{j, 1});
    end

    % End definitions --> move into data mode 
    netcdf.endDef(ncid);

    % Write data for every variable
    for i = 1:length(hdr.details.variables) -1
        var_name = hdr.details.variables(i).name;
        varid = netcdf.inqVarID(ncid, var_name);

        var_data = vol(i);
        netcdf.putVar(ncid, varid,var_data);
        
    end

    last_var_data = vol(end);
    netcdf.putVar(ncid, varid,last_var_data);

    % Close data
    netcdf.close(ncid);

end 


function minc2_write(file_name, hdr, vol)

    % Test 
    % file = 'hfa.mnc';
    % [hdr, vol] = minc_read(file);
    % file_name = 'hfa_test1.mnc';

    % Set up correct dimension order 
    hdr.info.dimension_order = {'xspace', 'yspace', 'zspace'};

    % Write dimensions
    for i = 1:length(hdr.info.dimension_order)
        dim_name = hdr.info.dimension_order{i};
        dim_size = hdr.info.dimensions(i);
        
        h5create(file_name, ['/minc-2.0/dimensions/' dim_name], 1, 'Datatype', 'double');
        h5write(file_name, ['/minc-2.0/dimensions/' dim_name], dim_size);

        % Write dimension attributes 
        for j = 1:length(hdr.details.variables(i).attributes)
        h5writeatt(file_name,['/minc-2.0/dimensions/' dim_name] , hdr.details.variables(i).attributes{1,j}, hdr.details.variables(i).values{1,j})
        end 
        
    end 

    % Write global attributes  
    h5writeatt(file_name, '/minc-2.0', 'ident', hdr.details.globals.ident);
    h5writeatt(file_name, '/minc-2.0', 'minc_version', hdr.details.globals.minc_version);
    h5writeatt(file_name, '/minc-2.0', 'history', hdr.details.globals.history);


    % Create and write image 
    h5create(file_name, '/minc-2.0/image/0/image', size(vol), 'Datatype', 'double');
    h5write(file_name, '/minc-2.0/image/0/image', vol);

    % Write image attributes 
    for i = 1:length(hdr.details.image(1).attributes)

        h5writeatt(file_name, '/minc-2.0/image/0/image', hdr.details.image(1).attributes{1,i}, hdr.details.image(1).values{1,i});
    end 
    
    % Create and write image min
    h5create(file_name, '/minc-2.0/image/0/image-min', size(hdr.details.data.image_min), 'Datatype', 'double');
    h5write(file_name, '/minc-2.0/image/0/image-min', hdr.details.data.image_min);

    % Write image min attributes 
    for i = 1:length(hdr.details.image(2).attributes)
        h5writeatt(file_name, '/minc-2.0/image/0/image-min', hdr.details.image(2).attributes{1,i}, hdr.details.image(2).values{1,i});
    end  

    % Create and write image max 
    h5create(file_name, '/minc-2.0/image/0/image-max', size(hdr.details.data.image_max), 'Datatype', 'double');
    h5write(file_name, '/minc-2.0/image/0/image-max', hdr.details.data.image_max); 

    % Write image max attributes 
    for i = 1:length(hdr.details.image(3).attributes)
        h5writeatt(file_name, '/minc-2.0/image/0/image-max', hdr.details.image(3).attributes{1,i}, hdr.details.image(3).values{1,i});
    end

    % Create and write acquisition info 
    for i = 4:length(hdr.details.variables)

        info_name = hdr.details.variables(i).name;

        h5create(file_name,[ '/minc-2.0/info/' info_name], 1, 'Datatype', 'double');
        h5write(file_name, ['/minc-2.0/info/' info_name], dim_size);

        % Write info attributes 
        for j = 1:length(hdr.details.variables(i).attributes)
            h5writeatt(file_name, ['/minc-2.0/info/' info_name], hdr.details.variables(i).attributes{1,j}, hdr.details.variables(i).values{1,j});
        end


    end


end 



   

















