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
    
    % Test if the file is in MINC1 or MINC2 format
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

    % Apply minc_write function if file is minc1 or minc2 
    if strcmp(hdr.type, 'minc1')
        minc1_write(file_name,hdr,vol)
    elseif strcmp(hdr.type, 'minc2')
        minc2_write(file_name,hdr,vol);
    end 


end 

function minc1_write(file_name, hdr, vol)

end 


function minc2_write(file_name, hdr, vol)

    % Create HDF5 file 
    h5create(file_name, '/minc-2.0/image/0/image', size(vol), 'Datatype', 'double');

    % Write HDF5 file 
    h5write(file_name, '/minc-2.0/image/0/image', vol);

    % Write dimensions 
    for i = 1:length(hdr.info.dimension_order)
        dim_name = hdr.info.dimension_order{i};
        dim_size = hdr.info.dimensions(i);
        h5create(file_name, ['/minc-2.0/dimensions/' dim_name], 1, 'Datatype', 'double');
        h5write(file_name, ['/minc-2.0/dimensions/' dim_name], dim_size);
    end 

    % Write global attributes
    globals = hdr.details.globals;
    h5writeatt(file_name, '/', 'history', globals.history);
    h5writeatt(file_name, '/', 'ident', globals.ident);
    h5writeatt(file_name, '/', 'minc_version', globals.minc_version);

    % Create and Write image min and max
    h5create(file_name, '/minc-2.0/image/0/image-min', size(hdr.details.data.image_min), 'Datatype', class(hdr.details.data.image_min));
    h5write(file_name, '/minc-2.0/image/0/image-min', hdr.details.data.image_min);
    h5create(file_name, '/minc-2.0/image/0/image-max', size(hdr.details.data.image_max), 'Datatype', class(hdr.details.data.image_max));
    h5write(file_name, '/minc-2.0/image/0/image-max', hdr.details.data.image_max);

    % Write image attributes
    image_attrs = hdr.details.image;
    for i = 1:length(image_attrs)
        attr_name = image_attrs(i).name;
        attr_values = image_attrs(i).values;
        for j = 1:length(attr_values)
            h5writeatt(file_name, '/minc-2.0/image/0/image', attr_name, attr_values{j});
        end
    end


end 
























