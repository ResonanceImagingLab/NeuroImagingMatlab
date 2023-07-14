function v_ur = unring3D(v,readout_dim,params)
% This is a wrapper function for the code available at https://github.com/josephdviviano/unring
% calls the original unring function, while looping through each slice in
% the specified readout direction. 

% readout_dim should be 1,2 or 3.
% If used, cite:
% Kellner, E, Dhital B., Kiselev VG and Reisert, M. 
% Gibbs‐ringing artifact removal based on local subvoxel‐shifts. 
% Magnetic resonance in medicine, 76(5), 1574-1581.
% 
% Written by Christopher Rowley 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 2
    params = [1 3 20];
end


[x,y,z] = size(v); 
v_ur = zeros(x,y,z);

if readout_dim == 1
    for j = 1:x
        img_s = v(j,:,:);  
        %de-ring
        v_ur(j,:,:) = unring(img_s ,params);
    end   

elseif readout_dim == 2
    for j = 1:y
        img_s = v(:,j,:);  
        %de-ring
        v_ur(:,j,:) = unring(img_s ,params);
    end   

elseif readout_dim == 3
    for j = 1:z
        img_s = v(:,:,j);  
        %de-ring
        v_ur(:,:,j) = unring(img_s ,params);
    end   
end


