% Methods for unwarping B0-induced geometric distortions in MRI images

% Please cite: Eckstein et al. Correction for Geometric Distortion in Bipolar Gradient Echo Images from B0 Field Variations, ISMRM 2019
% https://cds.ismrm.org/protected/19MProceedings/PDFfiles/4510.html

function unwarped = multiEchoUnwarp( mag, phase, TE, mask, dim, rbw, bipolarFlag)

% input image is 4D, with echos stack in the 4th dimension
% mask is a binary 3D image, with 1's where the anatomy of interest is.
% dim is the readout direction to correct distortions over
% rbw is the receiverbandwidth or PixelBandwidth in [Hz].
% bipolar flag is to know if even and odd echos are read in opposing directions


% could add in variable input to permit changing the interpolation method. default is b-spline

% This code is adapted for matlab from: https://github.com/korbinian90/MriResearchTools.jl/blob/master/src/VSMbasedunwarping.jl

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x, y, z, t] = size(mag);

% Make sure TE is in seconds so that we get Hz later.
if max(TE) > 0.5
    TE = TE /1000;
end


%% First step is to make the B0 maps from even and odd echoes.
phase = phasestack;

img = phase(:,:,:,1:2);

p1 = phase(:,:,:,1);
p2 = phase(:,:,:,2);

p1 = p1(mask >0);
p2 = p2(mask >0);
yy = [p1'; p2'];

D = [TE(1), 1; TE(2), 1];

beta=(D'*D)\(D'*(yy)); % Fit B0, and intercept

B0 = zeros(x,y,z);
B0(mask >0) = beta(2,:);

figure; imshow3Dfull(B0, [-200, 200])

if bipolarFlag % do even and odd

else % just calculate over the first two.

end



figure; imshow3Dfull(phase(:,:,:,1))
figure; imshow3Dfull(phase(:,:,:,2))








%% Second step is to use the B0 map to calculate voxel shift maps
% based on the readout bandwidth. B0 needs to be in [Hz]

if bipolarFlag % do even and odd

else % just calculate over the first two.

end

VSM = B0 ./ rbw;

% function unwarp!(unwarped, VSM, distorted)
%     xi = axes(distorted, 1)
%     for J in CartesianIndices(size(distorted)[4:end])
%         for I in CartesianIndices(size(distorted)[2:3])
%             xtrue = xi .+ VSM[:,I]
%             xregrid = (xtrue[1] .<= xi .<= xtrue[end]) # only use x values inside (no extrapolation)
%             unwarped[.!xregrid,I,J] .= 0
%             unwarped[xregrid,I,J] .= unwarpline(xtrue, distorted[:,I,J], xi[xregrid])
%         end
%     end
%     unwarped
% end

%% Third step is to apply the voxel shift maps

% need to have a grid for the image size for the interpolation. 






% function unwarpline(xtrue, distorted, xnew)
%     #TODO try better interpolation than linear
%     interpolate((xtrue,), distorted, Gridded(Linear()))(xnew)
% end


