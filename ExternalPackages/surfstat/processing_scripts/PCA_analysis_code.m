%Code to perform PCA analysis

%load data
BMI = [18.4,NaN,NaN,NaN,NaN,21.0,NaN,23.0,21.8,20.4,23.8,22.7,32.9,22.6,21.0,25.0,22.0,32.9,17.5,22.3,25.6,26.2,24.5,18.8,20.0,43.6,26.5,22.2,18.4,36.6,26.6,36.6,24.4,21.3,20.1,27.6,25.2,29.3,24.3,29.2,18.8,21.3,24.7,24.6,27.4,22.1,26.6,24.1,22.5,21.6,34.3,21.5,25.8,27.2,30.3,26.3,27.5,31.5,25.8,19.7,30.3,24,23.7,25.7,32.3,33.0,32.4]'; %remove women 2,3,4,5,7
Smoker = {'No','No','No','Yes','No','No','No','No','No','No','No','No','Yes','No','No','Yes','No','No','No','No','No','No','No','No','No','No','No','No','No','No','Yes','Yes','Yes','Yes','Yes','Yes','No','No','No','No','No','No','No','No','Yes','Yes','Yes','No','No','No','Yes','No','No','No','No','Yes','Yes','No','No','Yes','Yes','Yes','Yes','Yes','Yes','No','No'}';
Education = [18,18,NaN,13,18,18,18,15,16,18,17,18,13,17,15,13,13,13.5,15,18,21,15,16,16,18,14,14,15,12,15,15,25,12,14,15.5,14,20,20,20,16,13,13,17,20,15,14,15,17,21,15,15,13,16,19.5,13,18,18.5,16,20,12,15,12,15,11,14,18.5,16]'; %remove 3rd woman
Sex=sex';

Sex2= grp2idx(Sex); 
Smoker2= grp2idx(Smoker);

%First construct a matrix containing all of the data. Each column is a
%different variable
PCA_data = horzcat(Age, BMI,Education,Sex2,Smoker2);

%Make a new matrix with z-score transformed data from the first matrix
PCA_data_trans = nanzscore(PCA_data);


%Pca analysis

%[coeff,score,latent,~,explained,~] = pca(PCA_data_trans,'algorithm','als'); %Rows of X correspond to observations and columns to variables.


%%%%%%%%%%
%try again with cognitive data
Psych1 = [217,206,223,224,182,187,190,223,166,189,229,210,185,177,205,187,95,160,181,152,186,181,186,197,138,161,195,170,215,202,153,181,186,188,63,177,206,171,203,200,174,237,190,168,222,188,196,184,195,198,157,219,234,164,196,177,180,158,196,227]';
Proc_speed1 = [101,87,91,84,70,72,67,72,59,60,74,80,64,69,75,76,57,53,65,52,72,66,67,73,40,62,65,69,38,70,63,78,60,54,61,54,89,57,59,72,44,76,58,69,79,81,71,59,70,70,49,74,67,51,62,60,60,44,78,75]';
Verb_mem1 = [56,57,58,55,54,58,52,56,47,54,54,55,49,60,57,51,56,51,57,49,52,54,51,52,44,54,57,46,52,57,49,56,56,58,40,54,55,51,53,55,53,55,51,55,41,55,50,54,41,56,56,59,60,53,57,52,58,57,58,55]';
Simple_attent1 = [40,39,40,7,39,39,40,39,40,40,40,39,40,40,40,40,37,40,39,29,40,40,39,40,40,40,40,39,39,40,40,40,38,37,40,39,39,36,40,40,19,40,40,39,39,39,40,40,40,39,39,35,40,37,39,40,40,38,40,40]';
Motor_speed1 = [116,119,132,140,112,113,123,150,107,128,155,129,121,108,129,110,103,94,116,99,114,115,118,123,95,99,129,100,166,131,89,102,126,133,141,121,116,114,141,125,120,161,132,99,141,107,123,124,124,128,106,145,167,111,134,117,119,114,117,151]';
Age1= Age(8:67,1);

%combine the variables and zscore
PCA_data = horzcat( Psych1,Proc_speed1,Verb_mem1,Simple_attent1,Motor_speed1);
PCA_data_trans = nanzscore(PCA_data);
%calculate PCA
[coeff,score,latent,~,explained,~] = pca(PCA_data_trans,'algorithm','als'); %Rows of X correspond to observations and columns to variables.
%latent is the amount of variance in that PCA, the eigenvalues of
%covariance matrix
%Principal component scores are the representations of X in the principal component space.

%%%%%%%%%%%%%%%%%%%%%%%%
%try again with ROIs for clustering
%load data using GLM_modeling_control.m 

%now choose only the data at one depth

ROI_PCA = Signal(68:134,:); 
PCA_data_trans = nanzscore(ROI_PCA);
[coeff,score,latent,~,explained,~] = pca(ROI_PCA);

figure;
scatter3(coeff(:,1),coeff(:,2),coeff(:,3));

figure;
scatter(coeff(:,1),coeff(:,2));


%%

%load values
depth_thick = 'WM'; %1-2signal,1-4signal,3-4signal WM, T, G, M 
mars_depth = 'wm'; %half,1quart, 3quart, wm

S = Load_and_Combine_sides( depth_thick,'con','male');
Y = SurfStatSmooth( S.coord, S, 5 );
Ysmooth=struct('tri',S.tri,'coord',Y);

mars_roi = Load_and_Combine_thickness(mars_depth, 'MARS');
mars_cropped = mars_roi;

%Regression for ROI grouping 
ROI_PCA = Signal(1:67,:); %select the signal grouping
ROI_AGE = Age(1:67,:);
inter = ones(size(ROI_AGE));
predictors = horzcat(inter,ROI_AGE);
%find the outliers to remove them
y=zeros(1,82);
for k = 1:82 %if you change the size, delete the variables below
    [b(:,k),bint(:,:,k),r(:,k)] = regress(ROI_PCA(:,k),predictors); %reun regression of signal values with age for each ROI
end



ROI_reduced = ROI_PCA(:,[1:5,8:11,13:40,42:46,49:52,54:81]); %remove insula, isthmus cingulate, med.+ rostral inf. temporal
y=zeros(1,74);
clear b bint r 
for k = 1:74 %if you change the size, delete the variables below
    [b(:,k),bint(:,:,k),r(:,k)] = regress(ROI_reduced(:,k),predictors); %reun regression of signal values with age for each ROI
end

residual_sum = sum(abs(r));

figure;
scatter(b(2,:),residual_sum);
%scatter3(PC1,PC2,PC3); %plot the data in 3 planes to visualize for clustering


%% [b1,~] = regress(ROI_reduced(:,1),ROI_AGE);
%kmeans
%X = [b',residual_sum']; b(2,:)'
y=ones(size(ROImax));
X = [ROImax',y'];
[idx,C] = kmeans(X,3);

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

%%
%rerun k-means with outliers removed. 
% half depth labels
% label1=[1,2,4,5,10,11,30,37,38,39,40,101,102,103,104,118,121,130,139,140];
% label2=[23,24,25,26,27,28,29,31,35,123,124,125,126,127,128,129,131];
% label3=[3,8,9,13,14,15,16,17,18,19,20,21,22,32,33,34,36,108,109,111,113,114,115,116,117,119,120,122,132,133,134,135,136,137,138];
% label4 = [105,110];
% 3quarter depth labels
% label1=[8,17,23,24,26,27,28,29,31,32,35,36,114,117,118,123,124,125,126,127,128,129,131,133,135];
% label2=[1,2,3,5,9,11,13,14,15,16,18,19,20,22,25,30,33,34,37,38,39,40,103,104,108,109,113,115,116,120,121,122,130,132,134,136,137,138,139,140];
% label3=[4,10,21,101,102,111,119];
% label4 = [105,110];
% 1 quarter depth labels
% label1 = [3,8,9,14,15,16,17,20,21,22,25,32,33,34,35,36,37,38,40,108,109,111,113,115,116,117,120,121,132,134,136,137,138];
% label2=[13,19,23,24,26,27,28,29,31,114,119,122,123,124,125,126,127,128,129,131,133,135];
% label3=[1,2,4,5,11,18,30,39,101,102,103,104,118,130,139,140];
% label4 = [10,105,110];
% WM labels
label1 = [1,2,3,4,8,11,14,15,16,17,21,22,29,30,32,33,35,36,37,38,39,40,102,103,108,135,140];
label2=[9,109,110,120,123,124,126,132,136];
label3=[5,13,18,19,20,23,24,25,26,27,28,31,34,101,104,105,111,113,114,115,116,117,118,119,121,122,125,127,128,129,130,131,133,134,137,138,139];
label4 = [10];
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
    SurfStatView(clustered_roi, Ysmooth, 'checking');
    SurfStatColLim([0 4]), colormap('lines')



%%
%check coefficient values
ROI_coefficients=zeros(size(clustered_roi)); 
for k = 1:141  %for each of the labels, want to compare against slm results
    if k<6
        ROI_coefficients(mars_cropped==k) = b(2,k);
    elseif k>7 && k<11
        ROI_coefficients(mars_cropped==k) = b(2,k-2);
    elseif k>12 && k<41
        ROI_coefficients(mars_cropped==k) = b(2,k-3);
    elseif k>100 && k<106
        ROI_coefficients(mars_cropped==k) = b(2,k-63);%fill ROI matrix for each label with the mean coefficient. 
    elseif k>107 && k<112
        ROI_coefficients(mars_cropped==k) = b(2,k-65);
    elseif k>112 && k<141
        ROI_coefficients(mars_cropped==k) = b(2,k-66);
    else
        ROI_coefficients(mars_cropped==k) = 0;
    end
end

figure;
    SurfStatViewData(ROI_coefficients, Ysmooth, 'ROI coefficients')
    SurfStatColLim([0 0.005]), colormap('jet')

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




%%% generate max values from quadratic for each ROI
for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    masked_coeff = maskROI.*slm.coef(2,:);
    coeffMean_lin = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
    masked_square = maskROI.*slm.coef(3,:);
    coeffMean_square = nanmean(masked_square(masked_square~=0));
    ROImax(k) = -coeffMean_lin/(2*coeffMean_square); %this is where the derivative is zero
end


%% 
%look at R2 for fits
stat_total = zeros(4,(size(mars_roi,2)));
for k = 250030:size(mars_roi,2) %if you change the size, delete the variables below
    [~,~,~,~,stats] = regress(thick_comb(:,k),predictors); %reun regression of signal values with age for each vertex
    stat_total(:,k) = stats'; 
end


predictors = horzcat(inter,ROI_AGE,ROI_AGE.^2);

stat_total_quad = zeros(4,(size(mars_roi,2)));
for k = 1:size(mars_roi,2) %if you change the size, delete the variables below
    [~,~,~,~,stats] = regress(thick_comb(:,k),predictors); %reun regression of signal values with age for each vertex
    stat_total_quad(:,k) = stats'; 
end

%R2 statistic, the F statistic and its p value, and an estimate of the error variance
%%
%redo this with ROIs %choose dept

signalstat = Signal(68:134,:);

linpredictors = horzcat(inter,ROI_AGE);
stat_total = zeros(4,size(signalstat,2));
for k = 1:size(signalstat,2) %if you change the size, delete the variables below
    [~,~,~,~,stats] = regress(signalstat(:,k),linpredictors); %reun regression of signal values with age for each vertex
    stat_total(:,k) = stats'; 
end

quadpredictors = horzcat(inter,ROI_AGE,ROI_AGE.^2);
stat_total_quad = zeros(4,size(signalstat,2));
for k = 1:size(signalstat,2) %if you change the size, delete the variables below
    [~,~,~,~,stats] = regress(signalstat(:,k),quadpredictors); %reun regression of signal values with age for each vertex
    stat_total_quad(:,k) = stats'; 
end

%we have the values, now map them back onto the ROIs

stat_values=zeros(size(clustered_roi)); 
stat_investigate = 3;
for k = 1:141  %for each of the labels, want to compare against slm results, broken up here because some ROIs were removed, and matlab matrices arn't numbered for that
    if k<42
        stat_values(mars_cropped==k) = stat_total(stat_investigate,k);
    elseif k>100 && k<142
        stat_values(mars_cropped==k) = stat_total(stat_investigate,k-59);
    else
        stat_values(mars_cropped==k) = 0;
    end
end

stat_values_quad=zeros(size(clustered_roi)); 
for k = 1:141  %for each of the labels, want to compare against slm results, broken up here because some ROIs were removed, and matlab matrices arn't numbered for that
    if k<42
        stat_values_quad(mars_cropped==k) = stat_total_quad(stat_investigate,k);
    elseif k>100 && k<142
        stat_values_quad(mars_cropped==k) = stat_total_quad(stat_investigate,k-59);
    else
        stat_values_quad(mars_cropped==k) = 0;
    end
end



figure;
    SurfStatViewData(stat_values, Ysmooth, 'Pvalue - linear model',grey)
    SurfStatColLim([0 0.1]), colormap(flipud(coolmap))
    
figure;
    SurfStatViewData(stat_values_quad, Ysmooth, 'Pvalue - quadratic model',grey)
    SurfStatColLim([0 0.1]), colormap(flipud(coolmap))
    
 
    
    
    
    
    
    
    
    

