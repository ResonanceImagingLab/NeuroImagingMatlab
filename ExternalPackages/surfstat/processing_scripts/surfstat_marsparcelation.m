%%Surfstat script for surface analysis of thickness data
clear all
close all
%%%%%%%%%%%%%%%inputs 
depth_thick = '1-2signal'; %1-2signal,1-4signal,3-4signal WM, T, G, M 
mars_depth = 'half'; %half,1quart, 3quart, wm
%%control n1=female
n1=37;
n2=30;
Age_group1 = [23,23,45,41,26,44,24,20,25,28,26,29,40,35,27,28,21,21,21,33,32,21,21,29,43,41,32,21,18,41,24,36,38,40,31,42,45];
Age_group2 = [26,26,22,17,30,34,19,25,23,19,19,37,21,21,19,28,27,25,31,32,43,38,41,35,30,34,42,40,41,30];

%%%%%%%%%%%%%%%%%%%%%%Code
%set up demographics for GLM
cat1=repmat({'Women'},1,n1); %gender
cat2=repmat({'Men'},1,n2);
sex=horzcat(cat1,cat2);

Age = horzcat(Age_group1,Age_group2)'; %age

grey = [0.7,0.7,0.7]; %good background colour for images

%%%%%%%%%%%%%%%%%Now work with the data
%load vtk surface
S = Load_and_Combine_sides( depth_thick,'con','male');

%load group 1 thickness
T_group1 = Load_and_Combine_thickness(depth_thick,'con','female',n1); %specify depth, con/bipolar, gender, number subjects


%load group 2 thickness data
T_group2 = Load_and_Combine_thickness(depth_thick,'con','male',n2); %specify depth, con/bipolar, gender, number subjects


%smooth the surface
Y = SurfStatSmooth( S.coord, S, 10 );
Ysmooth=struct('tri',S.tri,'coord',Y);

% pca_female =  T_group1([1,6,8:37],:);
% pca_age = Age([1,6,8:end],:);
% thick_comb = vertcat(pca_female,T_group2); %use for pca
% sex=sex(:,[6:end]);

%thick_comb = vertcat(T_group1,T_group2);

smoothed_thick1 = SurfStatSmooth( T_group1, S, 5 );
smoothed_thick2 = SurfStatSmooth( T_group2, S, 5 ); %have to decrease smoothing for WM or you get lots of NA
thick_comb = vertcat(smoothed_thick1,smoothed_thick2);

%Inflate the surface**** need an inflated surface first? wtf. it uses the
%sphere surface output from freesurfer. 
%avsurfinfl = SurfStatInflate( Ysmooth,0.75 ); %first input is surface, second is a number between 0-1, closer to 1, the more inflated it is. 

%%Load cortex mask and ROIs
% MASK.t = Load_and_Combine_thickness(); %no inputs for ROI
% MASK.tri=S.tri;
%ROI parcellation
mars_roi = Load_and_Combine_thickness(mars_depth, 'MARS');
discard_roi = [5,6,7,10,12,41,105,106,107,110,112,141]; 
Lia = ismember(mars_roi,discard_roi);
mars_cropped = mars_roi - (mars_roi.*Lia); %remove 5,6,7,10,12,41


%%
%visualize
% figure; 
%     SurfStatView(mars_roi, Ysmooth, 'Mars ROI- full brain',grey);
%     colormap('lines')
%     SurfStatColLim([0 141]) 
%%
%%%%%%%%%%%%%%%%%%%%%%%Linear model

%%%%%%%%%%%%%%%%%%%%%%%%%
%p-values %Goodness fit R-squared


% inter = ones(size(Age));
% predictors = horzcat(inter,Age); %predictor matrix   ,Age.^2
% p_stat=zeros(1,size(mars_cropped,2)); 
% Rsquared_stat=zeros(1,size(mars_cropped,2));
% for k = 1:140 %if you change the size, delete the variables below
%     maskROI = mars_roi == k;
%     ROI_values(:,k) = nanmean( thick_comb(:, maskROI), 2 );
%     [b,bint,r,rint,stats] = regress(ROI_values(:,k),predictors); %reun regression of signal values with age for each ROI
%     Rsquared_stat(mars_cropped==k) = stats(:,1);
%     R_ROI(k,1) = stats(:,1);
%     p_stat(mars_cropped==k) = stats(:,3);
%     p_ROI(k,1) = stats(:,3);
% end
% 
% figure;
%     SurfStatViewData(p_stat,Ysmooth, 'p-values quadratic', grey)
%     SurfStatColLim([0 0.1]), colormap(flipud(coolmap))
%     
% figure;
%     SurfStatViewData(Rsquared_stat,Ysmooth, 'R-squared values', grey)
%     SurfStatColLim([0 0.5]), colormap('hot')
%%
% %%%%view smoothed map
% figure;
%     SurfStatViewData(smoothed_thick2(26,:), S, 'Smoothed')
%     SurfStatColLim([1.5 1.85]), colormap('jet')



% % FDR correct data
% qval = SurfStatQ(slm);
% 
% f3=figure;
%     SurfStatViewData(qval.Q, S, 'FDR')
%     SurfStatColLim([0 0.1])

%%
%%%%%%%%ROI analysis
A = term(Age);
Model =1+  A + A^2; 


slm = SurfStatLinMod(thick_comb,Model,S);
%ROI values for signal or thickness
num_labels = 155;
ROI_values=zeros(n1+n2,num_labels); 
for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    ROI_values(:,k) = nanmean( thick_comb(:, maskROI), 2 ); %%Calculates the ROI values for every subject in the vtk file
end

%ROI coefficient map for slope of Age
num_labels = 141;
ROI_coefficients=zeros(1,size(thick_comb,2)); 
for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    masked_coeff = maskROI.*slm.coef(2,:);
    
    coeffMean = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
    ROI_coefficients(mars_cropped==k) = coeffMean; %fill ROI matrix for each label with the mean coefficient. 
end

% ROI_coef_square=zeros(1,size(thick_comb,2)); 
% for k = 1:num_labels  %for each of the labels
%     maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
%     masked_coeff = maskROI.*slm.coef(3,:);
%     
%     coeffMean = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
%     ROI_coef_square(mars_cropped==k) = coeffMean; %fill ROI matrix for each label with the mean coefficient. 
% end
% 
% ROI_coef_intercept=zeros(1,size(thick_comb,2)); 
% for k = 1:num_labels  %for each of the labels
%     maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
%     masked_coeff = maskROI.*slm.coef(1,:);
%     
%     coeffMean = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
%     ROI_coef_intercept(mars_cropped==k) = coeffMean; %fill ROI matrix for each label with the mean coefficient. 
% end
% 
% % quad_mean = nanmean(ROI_coef_square(ROI_coef_square~=0));
% % quad_std = nanstd(ROI_coef_square(ROI_coef_square~=0));
% % ROI_quadmax_zscore = (ROI_coef_square - quad_mean)./quad_std;
% % 
% quad_mean = nanmean(ROI_quad_max(ROI_quad_max~=0));
% quad_std = nanstd(ROI_quad_max(ROI_quad_max~=0));
% ROI_quadmax_zscore = (ROI_quad_max - quad_mean)./quad_std;

num_labels = 141;
ROI_quad_max = zeros(1,size(thick_comb,2)); %find the maximum value the fit takes on
for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    masked_coeff = maskROI.*slm.coef(2,:);
    coeffMean_lin = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
    masked_square = maskROI.*slm.coef(3,:);
    coeffMean_square = nanmean(masked_square(masked_square~=0));
    quad_max(k) = -coeffMean_lin/(2*coeffMean_square); %this is where the derivative is zero
    ROI_quad_max(mars_cropped==k) = quad_max(k); %fill ROI matrix for each label with the mean coefficient. 
end

ROI_quad_vertshift = zeros(1,size(thick_comb,2));
for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    coeff = ((4*slm.coef(3,:).*slm.coef(1,:) - (slm.coef(2,:).^2)))./(4*slm.coef(3,:));
    masked_coeff = maskROI.* coeff;
    ROI_quad_vertshift(mars_cropped==k) = mean(masked_coeff(masked_coeff>1.0));% mean of nonzero elements
end

%to find values without ROI
ROI_quad_vertshift = ((4*slm.coef(3,:).*slm.coef(1,:) - (slm.coef(2,:).^2)))./(4*slm.coef(3,:));
ROI_quad_horzshift = -slm.coef(2,:)./(2*slm.coef(3,:));
ROI_coef_square = SurfStatSmooth( slm.coef(3,:), Ysmooth, 10 );



figure;
    SurfStatViewData(ROI_quad_max, Ysmooth, 'WM depth horizontal shift',grey)
    SurfStatColLim([30 40])
    colormap(coolmap)
    
 figure;
    SurfStatViewData(ROI_coef_square, Ysmooth, '3/4 depth A^2 term',grey)
    SurfStatColLim([-0.0004 -0.0002])
    colormap(flipud(parula))

 figure;
    SurfStatViewData(ROI_quad_vertshift, Ysmooth, '1/2 depth vert shift',grey)
    SurfStatColLim([2 2.5]) %1.65
    colormap(hot)
    
    
 me1= nanmean(thick_comb,1) ;  
  figure;
    SurfStatViewData(me1, Ysmooth, '1/2 depth vert shift',grey)
    SurfStatColLim([2 2.5]) % 1.3 1.65
    colormap(hot)

   
% y_1 = @(x) 1.23828250268263+0.0202895003*x-0.0003033069*x.^2;
% x_1 = 15:0.1:45;
% figure;
% plot(x_1,y_1(x_1))
% hold on
% scatter(Age, ROI_values(:,4));
% hold off

%%
%rerun k-means with outliers removed. 
% half depth labelslinear model
% label1=[1,2,4,11,30,37,38,39,40,101,102,103,104,118,121,130,139,140];
% label2=[23,24,25,26,27,28,29,31,35,123,124,125,126,127,128,129,131];
% label3=[3,8,9,13,14,15,16,17,18,19,20,21,22,32,33,34,36,108,109,111,113,114,115,116,117,119,120,122,132,133,134,135,136,137,138];
% label4 = [5,10,105,110];
% % half depth labels 3 cluster
% label1=[8,9,13,14,16,17,19,21,31,32,33,36,37,103,108,113,114,116,117,119,120,121,133,134,136,138];
% label2=[1,2,3,4,11,15,18,30,38,39,40,101,102,104,109,111,115,118,130,139,140];
% label3=[20,22,23,24,25,26,27,28,29,34,35,122,123,124,125,126,127,128,129,131,132,135,137];
% half depth labels 4 cluster
label1=[3,8,9,15,16,17,18,21,32,36,37,38,39,102,103,111,113,114,115,116,117,119,121,136,138];
label2=[13,14,19,20,22,24,25,31,33,34,108,120,122,125,131,132,133,134,137];
label3=[23,26,27,28,29,35,123,124,126,127,128,129,135];
label4=[1,2,4,11,30,40,101,104,109,118,130,139,140];

clustered_roi = zeros(size(mars_roi));
for i= 1:141
    if ismember(i,label3)
        clustered_roi(mars_roi == i) =3;
    elseif ismember(i,label2)
        clustered_roi(mars_roi == i) =2;
    elseif ismember(i,label1)
        clustered_roi(mars_roi == i) =1;
    elseif ismember(i,label4)
        clustered_roi(mars_roi == i) =4;
    else
        clustered_roi(mars_roi == i) =0;
    end
end
        
figure; 
    SurfStatView(clustered_roi, Ysmooth, 'K-means cluster ROI',grey);
    colormap('lines')
    SurfStatColLim([0.9 200])



%%
%check coefficient values
ROI_coefficients=zeros(size(clustered_roi)); 

for k = 1:140  %for each of the labels, want to compare against slm results, broken up here because some ROIs were removed, and matlab matrices arn't numbered for that
    if k<6
        ROI_coefficients(mars_cropped==k) = b(2,k);
    elseif k>7 && k<11
        ROI_coefficients(mars_cropped==k) = b(2,k-3);
    elseif k>12 && k<41
        ROI_coefficients(mars_cropped==k) = b(2,k-3);
    elseif k>100 && k<106
        ROI_coefficients(mars_cropped==k) = b(2,k-63);%fill ROI matrix for each label with the mean coefficient. 
    elseif k>107 && k<112
        ROI_coefficients(mars_cropped==k) = b(2,k-65);
    elseif k>112 && k<141
        ROI_coefficients(mars_cropped==k) = b(2,k-70);
    else
        ROI_coefficients(mars_cropped==k) = 0;
    end
end

figure;
    SurfStatViewData(ROI_coefficients, Ysmooth, 'ROI coefficients',grey)
    SurfStatColLim([-0.02 0.02]), colormap(fireice)

%% 
%calculate average values for the ROIs. 
for k = 1:5  %for each of the labels
    j= k-1;
    maskROI = clustered_roi == j;  %make a matrix of 0,1's where the desired label is
    ROI_coeff_avg(:,k) = nanmean( thick_comb(:, maskROI), 2 ); %%Calculates the ROI values for every subject in the vtk file
end

for k = 1:5 %if you change the size, delete the variables below
    [B_2(:,k),Bint_int(:,:,k),r(:,k)] = regress(ROI_coeff_avg(:,k),predictors); %reun regression of signal values with age for each ROI
end

%%
for k = 1:5  %for each of the labels to determine the average age shift of the cluster
    j= k-1;
    maskROI = clustered_roi == j;  %make a matrix of 0,1's where the desired label is
    ROI_coeff_avg(:,k) = nanmean( ROI_quad_max(:, maskROI), 2 ); %%Calculates the ROI values for every subject in the vtk file
end

%%
%looking to calculate the number of optimal clusters
[idx,C,sumd] = kmeans(quad_max',8);
totald = sum(sumd); 

%%
%try fitting the age data with splines and finding the max to see how it
%compares to quadratic fit. 

k= 14;
datain = horzcat(Age,ROI_values(:,k));
[dataout, lowerLimit, upperLimit, xy] = lowess(datain,0.25,1,'/Users/christopherrowley/Desktop/loess.png'); %second term is smoothing between 0 and 1


[~, I] = max(xy(:,2));
spline_max(k) = xy(I,1);

%[dataout, lowerLimit, upperLimit, xy] = lowess(datain,0.75,1,'/Users/christopherrowley/Desktop/loess.png'); %second term is smoothing between 0 and 1
%[~,ii(:,k)] = findpeaks(xy(:,2),xy(:,1));



for k = 13:40  %for each of the labels
    datain = horzcat(Age,ROI_values(:,k));
    [dataout, lowerLimit, upperLimit, xy] = lowess(datain,0.75); %second term is smoothing between 0 and 1
    [~, I] = max(xy(:,2));
    spline_max(k) = xy(I,1);
end



%calculated the values of quadmax from R, now plot them.
%quad_max = [32,34,35,33,0,0,0,36,36,0,34,0,37,38,35,35,36,36,36,37,36,37,40,37,37,38,38,40,40,35,38,37,37,38,38,35,38,32,34,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,34,34,35,0,0,0,36,34,0,34,0,35,36,35,35,37,35,36,38,36,37,38,38,37,37,42,37,38,36,37,37,37,37,37,36,38,37,34,33]';
%quad_max = [31.37,35.41,36.17,33.64,0,0,0,36.68,36.68,0,35.16,0,37.68,38.69,35.16,34.41,36.67,37.18,36.42,38.19,37.18,37.18,39.95,37.93,37.18,38.94,38.69,39.45,39.95,35.91,38.69,37.18,37.68,38.44,38.44,35.41,33.64,31.63,33.64,35.67,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32.14,34.15,33.9,35.16,0,0,0,36.17,34.91,0,34.41,0,35.41,36.42,34.66,35.91,37.18,35.66,36.17,38.44,37.18,37.43,38.44,38.44,38.19,38.19,41.97,39.93,38.19,36.17,37.94,37.68,36.93,37.94,37.94,36.93,38.69,37.18,34.41,33.9];
quad_max = [32.24,32.24,34.72,34.01,0.00,0.00,0.00,35.08,36.14,0.00,34.72,0.00,36.85,36.85,35.08,35.08,35.08,35.08,36.85,37.20,35.43,37.20,38.27,37.20,37.20,37.56,37.56,37.91,38.27,35.43,36.85,36.14,36.49,37.56,37.91,36.14,35.43,35.08,34.72,35.43,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,32.24,35.43,35.78,35.43,0.00,0.00,0.00,36.85,35.43,0.00,35.78,0.00,35.78,36.14,35.78,36.14,36.49,35.43,36.49,36.85,35.78,37.56,37.91,37.91,37.56,37.56,38.97,37.56,37.56,36.49,37.20,37.20,36.85,36.85,37.56,34.37,37.20,36.49,35.08,34.37];
%use the above values to map the cortex based on ROIs
for k = 1:140
    ROI_quad_max(mars_cropped==k) = quad_max(k);
end

figure;
    SurfStatViewData(ROI_quad_max, Ysmooth, '1/2depth depth horizontal shift',grey)
    SurfStatColLim([30 40])
    colormap(coolmap)

signal_max = [1.637163741,1.480023731,1.477501233,1.579118169,0,0,0,1.413027338,1.508891157,0,1.414346991,0,1.468323111,1.48536094,1.533404114,1.526750906,1.534029399,1.614326084,1.480678076,1.565338874,1.550550592,1.498370614,1.618173007,1.645069308,1.4817184,1.503985623,1.527081542,1.471923337,1.483747939,1.568417188,1.453655239,1.450613143,1.457547489,1.445184818,1.430766029,1.487402783,1.421614196,1.428300686,1.427027884,1.47197795,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.589635976,1.443636197,1.457651164,1.595970837,0,0,0,1.41161703,1.520518534,0,1.431765656,0,1.455996737,1.465521851,1.511593441,1.538396503,1.535776721,1.619311942,1.497426249,1.591689175,1.564166313,1.503337539,1.62878781,1.654800268,1.478534343,1.531096424,1.529838951,1.499715272,1.505144766,1.580764928,1.487403515,1.483773964,1.479249805,1.450152833,1.47029272,1.483103582,1.446911948,1.46116567,1.467054738,1.524012459];
    
 for k = 1:140
    ROI_signal_max(mars_cropped==k) = signal_max(k);
end

figure;
    SurfStatViewData(ROI_signal_max, Ysmooth, '1/2depth depth vertical shift',grey)
    SurfStatColLim([1.3 1.65]) %1.65
    colormap(hot)
      
    
    
    
    
    
    
    %now rerun k-means

quad_max_nozero = quad_max(quad_max~=0)'; 

y=ones(size(quad_max_nozero));
X = [quad_max_nozero,y];
[idx,C] = kmeans(X,4);

figure;
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize',12)
plot(X(idx==4,1),X(idx==4,2),'k.','MarkerSize',12)
%plot(C(1,:)',C(2,:)',C(3,:)','kx', 'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4',...
       'Location','NW')
title 'Cluster Assignments and Centroids'
hold off



%idxx = [3,3,3,3,1,1,3,1,2,3,3,1,1,1,1,1,1,4,1,1,2,2,4,4,3,2,1,1,2,2,3,2,3,3,3,3,3,3,3,1,3,3,3,1,3,3,1,3,1,2,1,1,2,2,1,1,4,1,2,1,1,1,1,1,1,1,2,1,3,3];
clustered_roi=zeros(size(mars_cropped)); 


for k = 1:141  %for each of the labels, want to compare against slm results, broken up here because some ROIs were removed, and matlab matrices arn't numbered for that
    if k<5
        clustered_roi(mars_cropped==k) = idx(k);
    elseif k>7 && k<10
        clustered_roi(mars_cropped==k) = idx(k-3);
    elseif k == 11
        clustered_roi(mars_cropped==k) = idx(k-4);
    elseif k>12 && k<41
        clustered_roi(mars_cropped==k) = idx(k-5);
    elseif k>100 && k<105
        clustered_roi(mars_cropped==k) = idx(k-65);%fill ROI matrix for each label with the mean coefficient. 
    elseif k>107 && k<110
        clustered_roi(mars_cropped==k) = idx(k-68);
    elseif k == 111
        clustered_roi(mars_cropped==k) = idx(k-69);
    elseif k>112 && k<141
        clustered_roi(mars_cropped==k) = idx(k-70);
    else
        clustered_roi(mars_cropped==k) = 0;
    end
end


figure; 
    SurfStatView(clustered_roi, Ysmooth, 'K-means cluster ROI',grey);
    colormap('lines')
    SurfStatColLim([0.9 200])





