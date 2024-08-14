function minc_write(file_name, hdr, vol)

    if nargin<2
        error('Need to provide hdr and vol info')
    end 

    if ~ischar(file_name) && ~isstring(file_name)
        error('FILE_NAME should be a string, for example ''my_file.mnc'' or ''my_file.mnc.gz''')
    end
    
    % Test if the file name has the right extension
    [file_path,file_core,file_ext] = fileparts(file_name);
    if ~ismember(file_ext,{'.mnc','.gz'})
        error('The extension of the file should be either .mnc or .mnc.gz')
    end

    % Deal with .mnc.gz files  
     if strcmp(file_ext, '.gz')
        mnc_file = fullfile(file_path, file_core);
         if strcmp(hdr.type, 'minc1')
            minc1_write(mnc_file,hdr,vol)
         elseif strcmp(hdr.type, 'minc2')
            minc2_write(mnc_file,hdr,vol);
         end
         gzip(mnc_file, file_path)
         delete(mnc_file); % deleted original .mnc and just leaves .mnc.gz
         return
     else
         if strcmp(hdr.type, 'minc1')
            minc1_write(file_name,hdr,vol)
         elseif strcmp(hdr.type, 'minc2')
            minc2_write(file_name,hdr,vol);
         end 
     end 


end 

function minc1_write(file_name, hdr, vol)

    % Test 
    % file = 'DeepStructureMask.mnc';
    % [hdr, vol] = minc_read(file);
    % file_name = 'DSM.mnc';

    % Create netCDF file 
    ncid = netcdf.create(file_name, 'CLOBBER'); % CLOBBER overwrite any existing file with same name 


    %% Define global attributes 
    nglobalatt = length(hdr.details.globals);
    for num_g = 1:nglobalatt
        if strcmp(hdr.details.globals(num_g).name,'history')
            % The history specified in hdr.info.history overrides what's stored in the header
            netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),hdr.details.globals(num_g).name,hdr.info.history);         
        else
            netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),hdr.details.globals(num_g).name,hdr.details.globals(num_g).values);
        end
    end

    %% Create new dimension specified by ncid 
    ndim = length(hdr.info.dimensions);
    hdr.info.dimensions = flip(hdr.info.dimensions,2);
    dimid = zeros(1, ndim);
    

    for i = ndim:-1:1
        dim_name = hdr.info.dimension_order{i};
        disp(dim_name);
        dim_size = hdr.info.dimensions(flip(i, 2));
        disp(dim_size);
        dimid(i) = netcdf.defDim(ncid, dim_name, dim_size);
        disp(dimid);
    end 


    %% Define variable attributes
    for i = 1:length(hdr.details.variables)
        var_name = hdr.details.variables(i).name;
        if strcmp(var_name, 'image')
            varid = netcdf.defVar(ncid, var_name, hdr.details.variables(i).type, dimid);
        else
            varid = netcdf.defVar(ncid, var_name, hdr.details.variables(i).type,[]);
        end 

        switch var_name
            case 'image'
                imgid = varid;
            case 'image-min'
                min_imgid = varid;
            case 'image-max'
                max_imgid = varid;
        end 

        for j = 1:length(hdr.details.variables(i).attributes)
            netcdf.putAtt(ncid, varid, hdr.details.variables(i).attributes{j,1}, hdr.details.variables(i).values{j,1})
        end

    end 

    %% End definitions --> move into data mode 
    netcdf.endDef(ncid);

    netcdf.putVar(ncid, imgid, vol);
    netcdf.putVar(ncid, min_imgid, min(vol(:)));
    netcdf.putVar(ncid, max_imgid, max(vol(:)));

    % Close data
    netcdf.close(ncid);

end 


function minc2_write(file_name, hdr, vol)

    % Test 
    % file = 'hfa.mnc';
    % [hdr, vol] = minc_read(file);
    % file_name = 'hfa_test1.mnc';

    % If the file you are writing already exists...
    if exist(file_name, 'file')
        delete(file_name)
    end 

    % Set up correct dimension order 
    hdr.info.dimension_order = {'xspace', 'yspace', 'zspace'};

    %%  Create and Write dimensions
    for i = 1:length(hdr.info.dimension_order)
        dim_name = hdr.info.dimension_order{i};
        dim_size = hdr.info.dimensions(i);
        if strcmp(hdr.details.variables(i).size, 'scalar')
            dataset_size = 1;
        else
            %dataset_size = 0; % Should this be an error message? 
            error('Unrecognized dimensions size: %s', hdr.details.variables(i).size);
        end 

        if ~isempty(hdr.details.variables(i).chunksize{1,1}) && ~isempty(hdr.details.variables(i).filters{1,1})
            HDF5_dim_datatype = data_type(hdr.details.variables(i).type);
            dim_chunksize = hdr.details.variables(i).chunksize{1,1};
            dim_filters   = hdr.details.variables(i).filters{1,1};
            dim_fillValue = hdr.details.variables(i).fillValue{1,1};

            h5create(file_name, ['/minc-2.0/dimensions/' dim_name], dataset_size, 'Datatype', HDF5_dim_datatype, ...
                    'Chunksize', dim_chunksize, 'Deflate', dim_filters, 'Fillvalue', dim_fillValue);
            h5write(file_name, ['/minc-2.0/dimensions/' dim_name], cast(dim_size, HDF5_dim_datatype));

        else 
            HDF5_dim_datatype = data_type(hdr.details.variables(i).type);

            h5create(file_name, ['/minc-2.0/dimensions/' dim_name], dataset_size, 'Datatype', HDF5_dim_datatype);
            h5write(file_name, ['/minc-2.0/dimensions/' dim_name], cast(dim_size, HDF5_dim_datatype)); % Datatype conversion fixed 
        end 

        % Write dimension attributes 
        for j = 1:length(hdr.details.variables(i).attributes)
        h5writeatt(file_name,['/minc-2.0/dimensions/' dim_name] , hdr.details.variables(i).attributes{1,j}, hdr.details.variables(i).values{1,j})
        end 
        
    end 

    % Write global attributes  
    h5writeatt(file_name, '/minc-2.0', 'ident', hdr.details.globals.ident);
    h5writeatt(file_name, '/minc-2.0', 'minc_version', hdr.details.globals.minc_version);
    h5writeatt(file_name, '/minc-2.0', 'history', hdr.details.globals.history);

    
    %% Create and write image 
    if ~isempty(hdr.details.image(1).chunksize{1,1}) && ~isempty(hdr.details.image(1).filters{1,1}.Data)
        HDF5_img_datatype = data_type(hdr.details.image(1).type);
        %HDF5_img_datatype = 'double';
        img_chunkSize = (hdr.details.image(1).chunksize{1,1});
        img_filters = hdr.details.image(1).filters{1,1}.Data;
        img_fillValue = hdr.details.image(1).fillValue{1,1};
        h5create(file_name, '/minc-2.0/image/0/image', size(vol), 'Datatype',HDF5_img_datatype, ...
                 'Chunksize', img_chunkSize, 'Deflate', img_filters, 'Fillvalue', img_fillValue);
        h5write(file_name, '/minc-2.0/image/0/image', cast(vol, HDF5_img_datatype));
        %h5write(file_name, '/minc-2.0/image/0/image', vol);
    else 
        HDF5_img_datatype = data_type(hdr.details.image(1).type); 
        h5create(file_name, '/minc-2.0/image/0/image', size(vol), 'Datatype', HDF5_img_datatype);
        h5write(file_name, '/minc-2.0/image/0/image', cast(vol, HDF5_img_datatype)); % Datatype conversion fixed
        %h5write(file_name, '/minc-2.0/image/0/image', vol);
    end 


    % Write image attributes 
    for i = 1:length(hdr.details.image(1).attributes)

        h5writeatt(file_name, '/minc-2.0/image/0/image', hdr.details.image(1).attributes{1,i}, hdr.details.image(1).values{1,i});
    end 
    
    %% Create and write image max 
    if ~isempty(hdr.details.image(2).chunksize{1,1}) && ~isempty(hdr.details.image(2).filters{1,1}) 
        HDF5_img_max_datatype = data_type(hdr.details.image(2).type);
        img_max_chunksize = hdr.details.image(2).chunksize{1,1};
        img_max_filters = hdr.details.image(2).filters{1,1}.Data; 
        img_max_fillValue = hdr.details.image(2).fillValue{1,1};
        h5create(file_name, '/minc-2.0/image/0/image-max', length(hdr.details.data.image_max), 'Datatype', HDF5_img_max_datatype, ...
                 'ChunkSize', img_max_chunksize, 'Deflate', img_max_filters, 'Fillvalue', img_max_fillValue);
        h5write(file_name, '/minc-2.0/image/0/image-max', cast(hdr.details.data.image_max,HDF5_img_max_datatype));  % Datatype conversion fixed 
    else 
        HDF5_img_max_datatype = data_type(hdr.details.image(2).type);
        h5create(file_name, '/minc-2.0/image/0/image-max', length(hdr.details.data.image_max), 'Datatype', HDF5_img_max_datatype);
        h5write(file_name, '/minc-2.0/image/0/image-max', cast(hdr.details.data.image_max,HDF5_img_max_datatype));  % Datatype conversion fixed
    end 

    % Write image max attributes 
    for i = 1:length(hdr.details.image(2).attributes)
        h5writeatt(file_name, '/minc-2.0/image/0/image-max', hdr.details.image(3).attributes{1,i}, hdr.details.image(3).values{1,i});
    end

    %% Create and write image min
    if ~isempty(hdr.details.image(3).chunksize{1,1}) && ~isempty(hdr.details.image(2).filters{1,1}) 
        HDF5_img_min_datatype = data_type(hdr.details.image(3).type);
        img_min_chunksize = hdr.details.image(3).chunksize{1,1};
        img_min_filters = hdr.details.image(3).filters{1,1}.Data;
        img_min_fillValue = hdr.details.image(3).fillValue{1,1};
        h5create(file_name, '/minc-2.0/image/0/image-min', length(hdr.details.data.image_min), 'Datatype', HDF5_img_min_datatype, ...
                 'ChunkSize', img_min_chunksize, 'Deflate', img_min_filters, 'Fillvalue', img_min_fillValue);
        h5write(file_name, '/minc-2.0/image/0/image-min', cast(hdr.details.data.image_min, HDF5_img_min_datatype)); % Datatype conversion fixed 
    else 
        HDF5_img_min_datatype = data_type(hdr.details.image(3).type);
        h5create(file_name, '/minc-2.0/image/0/image-min', length(hdr.details.data.image_min), 'Datatype', HDF5_img_min_datatype);
        h5write(file_name, '/minc-2.0/image/0/image-min', cast(hdr.details.data.image_min, HDF5_img_min_datatype)); % Datatype conversion fixed 
    end 

    % Write image min attributes 
    for i = 1:length(hdr.details.image(3).attributes)
        h5writeatt(file_name, '/minc-2.0/image/0/image-min', hdr.details.image(2).attributes{1,i}, hdr.details.image(2).values{1,i});
    end  



    % Create the /minc-2.0/info group using H5G.create (low level function)
    file_id = H5F.open(file_name, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    group_id = H5G.create(file_id, '/minc-2.0/info', 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
    H5G.close(group_id);
    H5F.close(file_id);

    % Create and write acquisition info 
    if length(hdr.details.variables)<4  

    else
        for i = 4:length(hdr.details.variables)

            info_name = hdr.details.variables(i).name;

            if ~isempty(hdr.details.variables(i).chunksize{1,1}) && ~isempty(hdr.details.variables(i).filters{1,1})        
                HDF5_info_datatype = data_type(hdr.details.variables(i).type);
                info_chunksize = hdr.details.variables(i).chunksize{1,1};
                info_filters = hdr.details.variables(i).filters{1,1};
                info_fillValue = hdr.details.variables(i).fillValue{1,1};

                h5create(file_name,[ '/minc-2.0/info/' info_name], 1, 'Datatype', HDF5_info_datatype, ...
                         'ChunkSize', info_chunksize, 'Deflate', info_filters, 'Fillvalue', info_fillValue);
                h5write(file_name, ['/minc-2.0/info/' info_name], cast(dim_size, HDF5_info_datatype));
            else 
                if ~startsWith(info_name, 'dicom') % C.R. amie, I would remove this from the read function too --> I think I fixed this 
                    HDF5_info_datatype = data_type(hdr.details.variables(i).type);
            
                    h5create(file_name,[ '/minc-2.0/info/' info_name], 1, 'Datatype', HDF5_info_datatype);
                    h5write(file_name, ['/minc-2.0/info/' info_name], cast(dim_size, HDF5_info_datatype));  % Datatype Conversion fixed 

    
                    % Write info attributes 
                    for j = 1:length(hdr.details.variables(i).attributes)
                        h5writeatt(file_name, ['/minc-2.0/info/' info_name], hdr.details.variables(i).attributes{1,j}, hdr.details.variables(i).values{1,j});
                    end
    
                end
            end
        end

    end

end 



   
















