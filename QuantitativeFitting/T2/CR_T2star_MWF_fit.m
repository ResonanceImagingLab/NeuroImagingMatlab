function [MWF, A_my, A_ax, A_ex, T2st_my, T2st_ax, T2st_ex] = CR_T2star_MWF_fit(input_img, mask, TE)

% input_img = magnitude data stacked in the 4th dimension for each echo
% mask = brain mask to speed up calculation to only masked voxels
% TE = TE vector. a 1xnumber_echos vector that stores the TE value for each
% echo. 


% input_img = mgre_ur_filt;
% mask = mask;
% TE = TEs;

%% Following the paper my Nam et al., 2015 (NeuroImage), you can have 3 models. 
% for simiplicity we will start with the magnitude model.
% S(t) = A_my * exp(-t/T2*_my) + A_ax * exp(-t/T2*_ax) + A_ex * exp(-t/T2*_ex)

% Where MWF = A_my / (A_my + A_ax + A_ex)
% as per Table 1 in the paper, they used the following fitting conditions
% for a 6 parameter fit (corresponding to [A_my, A_ax, A_ex, T2st_my, T2st_ax, T2st_ex]:
% 'Start', [ 0.1*S1, 0.6*S1, 0.3*S1, 10, 64, 48], 'Lower',[0, 0, 0, 3, 25, 25],'Upper',[2*S1, 2*S1, 2*S1, 25, 150, 150]
% Where S1 = Signal at first echo

[x,y,z,t] = size(input_img);


% T2* can be found by fitting the equation S = k*exp(-TE/T2*); 
% http://mriquestions.com/iront2-mapping.html
  
%% Fitting works better if TEs are in milliseconds
if max(TE) < 0.5
    TE = TE *1000;
end

% initalize fit matrices 
A_my = zeros(x,y,z);
A_ax = zeros(x,y,z);
A_ex = zeros(x,y,z);
T2st_my = zeros(x,y,z);
T2st_ax = zeros(x,y,z);
T2st_ex = zeros(x,y,z);


for i = 1:x
    for j = 1:y
        for k = 1:z
            if mask(i,j,k,1) > 0 % use for masked data

                img_voxel = squeeze(input_img(i,j,k,:)); % squeeze necessary to reformat to 1D array
                
                %remove values from fitting procedure where signal drops
                %low due to dephasing 
                TE_fit = TE';
                mask_fit = squeeze(mask(i,j,k,:));
                TE_fit (mask_fit < 1) = [];
                
                if length(TE_fit) < 6  % if insufficient points for fitting
                	A_my (i,j,k) = 0;
                    A_ax (i,j,k) = 0;
                    A_ex (i,j,k) = 0;
                    T2st_my(i,j,k) = 0;
                    T2st_ax (i,j,k) = 0;
                    T2st_ex (i,j,k) = 0;
                    
                else 
                    img_voxel (mask_fit < 1) = [];                    
                    S1 = img_voxel(1); 
                    
                    
                    opts = fitoptions( 'Method', 'NonlinearLeastSquares','Start', [ 0.1*S1, 0.6*S1, 0.3*S1, 10, 64, 48], 'Lower',[0, 0, 0, 3, 25, 25],'Upper',[2*S1, 2*S1, 2*S1, 25, 150, 150]);
                    opts.Robust = 'Bisquare';
                    myfittype = fittype('A_my * exp(-t/T2st_my) + A_ax * exp(-t/T2st_ax) + A_ex * exp(-t/T2st_ex)','dependent', {'img_voxel'}, 'independent',{'t'},'coefficients', {'A_my', 'A_ax', 'A_ex', 'T2st_my', 'T2st_ax', 'T2st_ex'});
                    fitT2st = fit( TE_fit, img_voxel, myfittype, opts ); % Add in upper and lower bounds to help with fit
                    T2stcoef = coeffvalues(fitT2st);
                    
%                     myfittype = fittype('A_my * exp(-t/T2st_my) + A_ax * exp(-t/T2st_ax) + A_ex * exp(-t/T2st_ex)','dependent', {'img_voxel'}, 'independent',{'t'},'coefficients', {'A_my', 'A_ax', 'A_ex', 'T2st_my', 'T2st_ax', 'T2st_ex'});
%                     fitT2st = fit( TE_fit, img_voxel, myfittype,'Start', [ 0.1*S1, 0.6*S1, 0.3*S1, 10, 64, 48], 'Lower',[0, 0, 0, 3, 25, 25],'Upper',[2*S1, 2*S1, 2*S1, 25, 150, 150] ); % Add in upper and lower bounds to help with fit
%                     T2stcoef = coeffvalues(fitT2st);
                    
                    
                    A_my (i,j,k) = T2stcoef(1);
                    A_ax (i,j,k) = T2stcoef(2);
                    A_ex (i,j,k) = T2stcoef(3);
                    T2st_my(i,j,k) = T2stcoef(4);
                    T2st_ax (i,j,k) = T2stcoef(5);
                    T2st_ex (i,j,k) = T2stcoef(6);
                    
                end
            end

        end
    end
    i/x
end

MWF = A_my ./ (A_my + A_ax + A_ex + 0.000001); % add a small number to prevent divide by 0. 

%max(max(max(T2_star)));
%% testing

% msat_calc = fitT2st(TE_fit);
% figure;
% plot(TE_fit,msat_calc,'LineWidth',2)
% hold on
% scatter(TE_fit, img_voxel,40,'filled')
%     ax = gca;
%     ax.FontSize = 20; 
%     xlabel('TE (ms) ', 'FontSize', 20, 'FontWeight', 'bold')
%     ylabel('Signal}', 'FontSize', 20, 'FontWeight', 'bold')
%      %   colorbar('off')
%     legend('hide')
%     text(6.2, 0.0015, strcat('T_{2}^* = ',num2str(T2_star,'%.3g')), 'FontSize', 16); 
%     ylim([20 300])




