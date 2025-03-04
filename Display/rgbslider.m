%%%%% Inputs must be strings of the pathway to your image
%%%%% Images must be the same size
%%%%% Orientation is RPS and forces axial view



function rgbslider(file1, file2)
    % Read and process NIfTI files
    nii1_info = niftiinfo(file1);
    nii2_info = niftiinfo(file2);
    nii1 = niftiread(nii1_info);
    nii2 = niftiread(nii2_info);

    % Reorient images to RPS 
    nii1 = reorientToRPS(nii1, nii1_info.Transform);
    nii2 = reorientToRPS(nii2, nii2_info.Transform);

    % Normalize images
    nii1 = double(nii1);
    nii2 = double(nii2);
    nii1 = (nii1 - min(nii1(:))) / (max(nii1(:)) - min(nii1(:)));
    nii2 = (nii2 - min(nii2(:))) / (max(nii2(:)) - min(nii2(:)));

    % Prepare RGB volume
    rgbVolume = zeros([size(nii1), 3]);
    rgbVolume(:,:,:,1) = nii1; % Red channel
    rgbVolume(:,:,:,2) = nii2; % Green channel

    % Create separate RGB volumes for individual display
    rgbNii1 = zeros([size(nii1), 3]); % Only red channel for nii1
    rgbNii1(:,:,:,1) = nii1;
    rgbNii2 = zeros([size(nii2), 3]); % Only green channel for nii2
    rgbNii2(:,:,:,2) = nii2;

    % Default slice number (Middle slice in Z)
    sliceNum = round(size(rgbVolume, 3) / 2);

    % Create figure with three subplots
    fig = figure('Name', 'NIfTI Slice Viewer', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 400]);

    % Subplot 1: Overlay
    ax1 = subplot(1, 3, 1);
    img1 = imshow(squeeze(rgbVolume(:,:,sliceNum,:)));
    title('Overlay');

    % Subplot 2: nii1 (red only)
    ax2 = subplot(1, 3, 2);
    img2 = imshow(squeeze(rgbNii1(:,:,sliceNum,:)));
    title('nii1');

    % Subplot 3: nii2 (green only)
    ax3 = subplot(1, 3, 3);
    img3 = imshow(squeeze(rgbNii2(:,:,sliceNum,:)));
    title('nii2');

    % Slice navigation slider
    slider = uicontrol('Style', 'slider', 'Min', 1, 'Max', size(rgbVolume, 3), ...
                       'Value', sliceNum, 'SliderStep', [1/(size(rgbVolume,3)-1) 1], ...
                       'Position', [450, 50, 300, 20]);

    % Update function for slider
    addlistener(slider, 'ContinuousValueChange', @(src, event) updateSlice(round(src.Value), img1, img2, img3, rgbVolume, rgbNii1, rgbNii2));

    % Function to update displayed slices
    function updateSlice(sliceNum, img1, img2, img3, rgbVolume, rgbNii1, rgbNii2)
        img1.CData = squeeze(rgbVolume(:,:,sliceNum,:));  % Overlay
        img2.CData = squeeze(rgbNii1(:,:,sliceNum,:));    % nii1 (red)
        img3.CData = squeeze(rgbNii2(:,:,sliceNum,:));    % nii2 (green)
    end

    % Function to reorient NIfTI to RPS and force axial view
    function nii_corrected = reorientToRPS(nii, transform)
        affine = transform.T';

        % Determine if flipping is needed for RPS
        flipX = affine(1,1) < 0;  % Right should be Right
        flipY = affine(2,2) > 0;  % Posterior should be Posterior
        flipZ = affine(3,3) < 0;  % Superior should be Superior

        % Apply flips accordingly
        if flipX, nii = flip(nii, 1); end
        if flipY, nii = flip(nii, 2); end
        if flipZ, nii = flip(nii, 3); end

        % Coronal (Front view):  
        nii_corrected = permute(nii, [3, 1, 2]);  % (XZ plane)  
        % Fix: Flip Y-axis to correct orientation
        nii_corrected = flip(nii_corrected, 1); 
    end
end
