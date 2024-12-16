function [k_map, T2_star] = CR_T2star_fit(input_img, mask, TE)

% input_img = magnitude data stacked in the 4th dimension for each echo
% mask = brain mask to speed up calculation to only masked voxels
% TE = TE vector. a 1xnumber_echos vector that stores the TE value for each
% echo. 
% thres = pixel value to threshold whether you want to include the data or not. Important for exlcuding points in later echos. (150 is a good value)




% input_img = mgre_unring;
% mask = mask;
% TE = TEs;
% thres = 150;
% i = 98;j = 77; k = 56; % idx of bad inhomogeneity

[x,y,z,t] = size(input_img);


% T2* can be found by fitting the equation S = k*exp(-TE/T2*); 
% http://mriquestions.com/iront2-mapping.html
  
%% Fitting works better if TEs are in milliseconds
if max(TE) < 0.5
    TE = TE *1000;
end

k_map = zeros(x,y,z);
T2_star = zeros(x,y,z);

for i = 1:x
    for j = 1:y
        for k = 1:z
            if mask(i,j,k,5) > 0 % Need min 5 points for fit
 
                img_voxel = squeeze(input_img(i,j,k,:)); % squeeze necessary to reformat to 1D array
                
                %remove values from fitting procedure where signal drops
                %low due to dephasing 
                TE_fit = TE';
                mask_fit = squeeze(mask(i,j,k,:));
                TE_fit (mask_fit < 1) = [];
                img_voxel (mask_fit < 1) = [];
        
                if length(TE_fit) > 4 % double check lenth as still got errors.
                    opts = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',[0,0],'Upper',[5000,200], 'Start', [1500, 50]);
                    opts.Robust = 'Bisquare';
                    % now fit
                    myfittype = fittype('k * exp(-TE_fit/T2st)','dependent', {'img_voxel'}, 'independent',{'TE_fit'},'coefficients', {'k','T2st'});
                    fitT2st = fit( TE_fit, img_voxel, myfittype, opts ); % Add in upper and lower bounds to help with fit
                    %fitT2st = fit( TE_fit, img_voxel, myfittype, 'Lower',[0,0],'Upper',[5000,200], 'Start', [1500, 25] ); % Add in upper and lower bounds to help with fit
                    T2stcoef = coeffvalues(fitT2st);

                    k_map(i,j,k) = T2stcoef(1);
                    T2_star(i,j,k) = T2stcoef(2);
                end

            end
        end
    end
    i/x
end

%% you can plot to check the fit

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









