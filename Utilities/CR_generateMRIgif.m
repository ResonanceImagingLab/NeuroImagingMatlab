function CR_generateMRIgif (input_img, clim, colourmap)


% Taken from https://www.mathworks.com/matlabcentral/answers/94495-how-can-i-create-animated-gif-images-in-matlab
% This is intended to take an input 3D MRI image, and generate 3 GIF files
% that go through each plane

if (nargin < 2)
	clim(1) = nanmin(input_img,[],'all');
    clim(2) = nanmax(input_img,[],'all');
    
    if clim(1) < -10 
        clim(1) = -10;
    end
end


if (nargin < 3)
	colourmap = gray;
end


%% Matlab isn't great with image scaling, so rescale image to 0-255
input_scaled = (input_img/clim(2)) *255;

clim2 = [0 255];

% You can check here if any dimension needs a rotation
% figure;
% imshow(rot90(squeeze(input_scaled(:,:,n)), -1), clim2,'Colormap',colourmap)


%%


[x, y, z] = size(input_img);

h1 = figure;
axis tight manual % this ensures that getframe() returns a consistent size

filename = 'MRI_gif_dim1.gif';


for n = 1:x
    % Show this image slice
    imshow(squeeze(input_scaled(n,:,:)), clim2,'Colormap',colourmap)
    drawnow 
      % Capture the plot as an image 
      frame = getframe(h1); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if n == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
end
  

%% Second dimension
h2 = figure;
axis tight manual % this ensures that getframe() returns a consistent size

filename = 'MRI_gif_dim2.gif';

for n = 1:y
    % Show this image slice
    imshow(squeeze(input_scaled(:,n,:)), clim2,'Colormap',colourmap)
    drawnow 
      % Capture the plot as an image 
      frame = getframe(h2); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if n == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
end
  
%% Third dimension

h3 = figure;
axis tight manual % this ensures that getframe() returns a consistent size

filename = 'MRI_gif_dim3.gif';

for n = 1:z
    % Show this image slice
    imshow(rot90(squeeze(input_scaled(:,:,n)), -1), clim2,'Colormap',colourmap)
    drawnow 
      % Capture the plot as an image 
      frame = getframe(h3); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if n == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
end
  

