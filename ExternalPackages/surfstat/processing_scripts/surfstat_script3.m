%%Surfstat script for surface analysis of thickness data
clear all
close all
%%%%%%%%%%%%%%%inputs 
depth_thick = '1-2signal'; %1-2signal,1-4signal,3-4signal WM, T, G, M 
mars_depth = 'half'; %half,1quart, 3quart, wm

%%control n1=female
n1=37;
n2=30;
%%bipolar
n3=40;
n4=31;

Age_group1 = [23,23,45,41,26,44,24,20,25,28,26,29,40,35,27,28,21,21,21,33,32,21,21,29,43,41,32,21,18,41,24,36,38,40,31,42,45];
Age_group2 = [26,26,22,17,30,34,19,25,23,19,19,37,21,21,19,28,27,25,31,32,43,38,41,35,30,34,42,40,41,30];
Age_group3 = [29,41,32,29,42,42,28,39,42,36,24,24,38,21,25,37,36,21,39,35,33,44,20,36,30,27,24,22,34,28,42,39,24,40,38,34,45,35,23,35];
Age_group4 = [20,25,24,42,23,41,24,44,29,20,43,28,32,32,26,36,28,30,22,31,21,26,23,29,26,42,17,45,30,25,35];

%CRP = [6.27,NaN,NaN,22.79,0.21,0,3.55,1.72,1.16,1.26,1.29,0.96,15.29,18.05,12.01,3.1,4.75,2.14,1.07,2.97,11.93,7.19,8.7,1.88,1.08,82.87,8.1,1.59,2.21,22.82,3.77,8.38,1.98,3.05,6.73,15.92,2.83,9.37,1.84,2.59,7.24,1.13,2.67,6.25,1.1,1.9,1.08,0.75,23.93,8.55,1.44,1.65,14.24,6.37,6.93,8.52,2.18,2.04,6.16,3.05,6.67,0.47,4.61,6.39,13.79,8.88,5.91]';

%num = xlsread('/Users/christopherrowley/Downloads/CNSVSICMfull.xlsx',7,'C60:AJ98');

%%%%%%%%%%%%%%%%%%%%%%Code
%set up demographics for GLM
cat1=repmat({'Women'},1,n1); %gender
cat2=repmat({'Men'},1,n2);
cat3=repmat({'Women'},1,n3);
cat4=repmat({'Men'},1,n4);
sex=horzcat(cat1,cat2,cat3,cat4);

conDX=repmat({'Control'},1,(n1+n2)); %mental illness
bpDX=repmat({'Bipolar'},1,(n3+n4));
DX=horzcat(conDX,bpDX);

bptypefemale = {'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp2' 'bp1' 'bp2' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp1' 'bp2' 'bp2' 'bp2' 'bp1' 'bp1' 'bp2' 'bp2' 'bp2' 'bp2' 'bp1' 'bp1' 'bp1' 'bp1' 'bp2' 'bp2' 'bp1' 'bp2' 'bp1' 'bp1' 'bp1' 'bp1'}; 
bptypemale = {'bp1' 'bp1' 'bp1' 'bp1' 'bp2' 'bp1' 'bp1' 'bp2' 'bp2' 'bp2' 'bp1' 'bp1' 'bp1' 'bp2' 'bp1' 'bp1' 'bp2' 'bp1' 'bp2' 'bp1' 'bp1' 'bp2' 'bp1' 'bp2' 'bp1' 'bp1' 'bp1' 'bp1' 'bp2' 'bp1' 'bp1'};
bptype = horzcat(bptypefemale,bptypemale);
ill_type = horzcat(conDX,bptype);

Age = horzcat(Age_group1,Age_group2,Age_group3,Age_group4)'; %age
%Age = horzcat(Age_group1,Age_group2)';
grey = [0.7,0.7,0.7]; %good background colour for images

%%%%%%%%%%%%%%%%%Now work with the data
%load vtk surface
S = Load_and_Combine_sides( depth_thick,'con','male');
%load group 1 thickness
T_group1 = Load_and_Combine_thickness(depth_thick,'con','female',n1);
smoothed_thick1 = SurfStatSmooth( T_group1, Ysmooth, 6 );

%load group 2 thickness data
T_group2 = Load_and_Combine_thickness(depth_thick,'con','male',n2);
smoothed_thick2 = SurfStatSmooth( T_group2, Ysmooth, 6 );

T_group3 = Load_and_Combine_thickness(depth_thick,'bp','female',n3);
smoothed_thick3 = SurfStatSmooth( T_group3, S, 6 );

%load group 2 thickness data
T_group4 = Load_and_Combine_thickness(depth_thick,'bp','male',n4);
smoothed_thick4 = SurfStatSmooth( T_group4, S, 6 );


Y = SurfStatSmooth( S.coord, S, 10 );
Ysmooth=struct('tri',S.tri,'coord',Y);

%thick_comb = vertcat(T_group1,T_group2,T_group3,T_group4);
thick_comb = vertcat(smoothed_thick1,smoothed_thick2,smoothed_thick3,smoothed_thick4);


%%load in the mars ROI
mars_roi = Load_and_Combine_thickness(mars_depth, 'MARS');
discard_roi = [5,6,7,10,12,41,105,106,107,110,112,141]; 
Lia = ismember(mars_roi,discard_roi);
mars_cropped = mars_roi - (mars_roi.*Lia); %remove 5,6,7,10,12,41


%%average over ROIs
num_labels = 141;
ROI_values=zeros(n1+n2+n3+n4,num_labels); %   +n3+n4
for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    ROI_values(:,k) = nanmean( thick_comb(:, maskROI), 2 ); %%Calculates the ROI values for every subject in the vtk file
end

%whole brain average

for i = 1:size(thick_comb,1)
    sub = thick_comb(i,:);
    WB_avg(i) = nanmean(sub(mars_cropped>0),2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%remove subjects that we aren't including
Age2 = Age([1,6,8:46,48:55,57:71,73,74,76,78,79,81:86,91,96:99,102,104:111,113,114,118:119,120,122,123,125,127,128,130,132:135,138]);
ill_type =ill_type([1,6,8:46,48:55,57:71,73,74,76,78,79,81:86,91,96:99,102,104:111,113,114,118:119,120,122,123,125,127,128,130,132:135,138]);
thick_comb2 = thick_comb([1,6,8:46,48:55,57:71,73,74,76,78,79,81:86,91,96:99,102,104:111,113,114,118:119,120,122,123,125,127,128,130,132:135,138],:);


% 
% %we want the average over the whole brain. 
% maskROI(mars_cropped ~= 0) = 1; 
% wholebrain_values = nanmean(thick_comb(:, maskROI), 2);

%separate bp1 and bp2
ill_transpose = ill_type';

llc = cellfun(@(x)strcmp('Control',x),ill_transpose(:,1));
con_thickcomb = thick_comb2(llc,:);
Age_con = Age2(llc,:);

ll1 = cellfun(@(x)strcmp('bp1',x),ill_transpose(:,1));
bp1_thickcomb = thick_comb2(ll1,:);
Age_bp1 = Age2(ll1,:);

ll2 = cellfun(@(x)strcmp('bp2',x),ill_transpose(:,1));
bp2_thickcomb = thick_comb2(ll2,:);
Age_bp2 = Age2(ll2,:);


%%
%make A, h and k maps

A = term(Age_bp1);
Model = 1 + A + A^2; 
slm = SurfStatLinMod(bp1_thickcomb,Model,S);
%slm.coef(3,:) = SurfStatSmooth( slm.coef(3,:), Ysmooth, 10 );

num_labels = 140;
ROI_quad_max = zeros(1,size(bp1_thickcomb,2)); %find the maximum value the fit takes on
ROI_quad_vertshift = zeros(1,size(bp1_thickcomb,2));
ROI_coef_square=zeros(1,size(bp1_thickcomb,2));

% for k = 1:num_labels  %for each of the labels
%     maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
%     masked_coeff = maskROI.*slm.coef(2,:);
%     coeffMean_lin = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
%     masked_square = maskROI.*slm.coef(3,:);
%     coeffMean_square = nanmean(masked_square(masked_square~=0));
%     quad_max(k) = -coeffMean_lin/(2*coeffMean_square); %this is where the derivative is zero
%     ROI_quad_max(mars_cropped==k) = quad_max(k); %fill ROI matrix for each label with the mean coefficient. 
% end

for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    masked_coeff = maskROI.*slm.coef(3,:);
    coeffMean = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
    ROI_coef_square(mars_cropped==k) = coeffMean; %fill ROI matrix for each label with the mean coefficient. 
end
% 
% for k = 1:num_labels  %for each of the labels
%     maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
%     coeff = ((4*slm.coef(3,:).*slm.coef(1,:) - (slm.coef(2,:).^2)))./(4*slm.coef(3,:));
%     masked_coeff = maskROI.* coeff;
%     ROI_quad_vertshift(mars_cropped==k) = mean(masked_coeff(masked_coeff>1.0));% mean of nonzero elements
% end



%%
%view the maps
% figure;
%     SurfStatViewData(ROI_quad_max, Ysmooth, 'horizontal shift',grey)
%     SurfStatColLim([30 40])
%     colormap(coolmap)
    
 figure;
    SurfStatViewData(ROI_coef_square, Ysmooth, 'A^2 term',grey)
    SurfStatColLim([-0.0004 0.0004])
    colormap(fireice)
    %colormap(flipud(parula))


%  figure;
%     SurfStatViewData(ROI_quad_vertshift, Ysmooth, 'vert shift',grey)
%     SurfStatColLim([1.3 1.8]) %1.65
%     colormap(hot)
    
    %%

inter = ones(size(Age_con));
predictors = horzcat(inter,Age_con, Age_con.^2); %predictor matrix   ,Age.^2
p_stat=zeros(1,size(mars_cropped,2)); 
Rsquared_stat=zeros(1,size(mars_cropped,2));
for k = 1:140 %if you change the size, delete the variables below
    maskROI = mars_roi == k;
    ROI_values(:,k) = nanmean( con_thickcomb(:, maskROI), 2 );
    [b,bint,r,rint,stats] = regress(ROI_values(:,k),predictors); %reun regression of signal values with age for each ROI
    Rsquared_stat(mars_cropped==k) = stats(:,1);
    R_ROI(k,1) = stats(:,1);
    p_stat(mars_cropped==k) = stats(:,3);
    p_ROI(k,1) = stats(:,3);
end

figure;
    SurfStatViewData(p_stat,Ysmooth, 'p-values quadratic', grey)
    SurfStatColLim([0 0.1]), colormap(flipud(coolmap))
    
figure;
    SurfStatViewData(Rsquared_stat,Ysmooth, 'R-squared values', grey)
    SurfStatColLim([0 0.4]), colormap('hot')   




















%%
%February 8 meeting

mars_roi = Load_and_Combine_thickness(mars_depth, 'MARS');
%discard_roi = [1,2,4,5,6,7,10,11,12,17,18,30,37,38,39,40,41,101,104,105,106,107,110,112,117,118,130,134,139,140,141]; %not meeting bonferonni
discard_roi =  [1,2,4,5,6,7,10,11,12,17,18,20,30,32,33,37,38,39,40,41,101,103,104,105,106,107,110,112,115,117,118,130,134,135,136,138,139,140,141]; %not meeting bonferonni
Lia = ismember(mars_roi,discard_roi);
trending_roi = [20,33,103,115,135,136,138]; %roi's with pvalye between 0.05 and 0.1
Lia2 = ismember(mars_roi,trending_roi); 
Lia2 = 0.5 * Lia2;
Lia3 = ~Lia; %take the inverse logic of the remove 
mars_view = Lia3 + Lia2;

%mars_cropped = mars_roi - (mars_roi.*Lia);

figure;
    SurfStatViewData(mars_view,Ysmooth, 'Regions meeting Bonferonni Correction and A term significance', grey)
    SurfStatColLim([0 1]), colormap('hot')











%%
%Linear Model
%%

% %Bipolar analysis
% G = term(sex);
BMI = [18.4,nan,nan,nan,nan,21.0,nan,23.0,21.8,20.4,23.8,22.7,32.9,22.6,21.0,25.0,22.0,32.9,17.5,22.3,25.6,26.2,24.5,18.8,20.0,43.6,26.5,22.2,18.4,36.6,26.6,36.6,24.4,21.3,20.1,27.6,25.2,29.3,24.3,29.2,30.1,24.7,24.6,22.1,27.4,24.1,18.8,21.3,22.5,21.6,34.3,21.5,25.8,27.2,30.3,26.3,27.5,31.5,25.8,19.7,30.3,24.4,23.7,25.7,32.3,33.0,32.4,27.8,26.8,23.6,30.5,nan,27.5,25.8,35.5,28.3,23.8,19.2,24.9,nan,27.4,24.0,31.9,34.9,21.1,28.1,34.3,33.3,30.7,25.0,33.9,22.3,31.4,22.5,36.9,22.9,25.4,29.2,25.1,28.2,30.9,29.0,33.1,23.9,31.0,22.6,25.0,18.5,27.5,26.8,22.8,20.9,29.0,34.9,33.0,28.7,30.4,23.0,20.3,39.5,21.7,29.9,30.7,25.3,28.6,21.5,28.1,18.0,nan,22.0,35.9,22.6,32.1,27.4,27.0,23.0,27.7]';
%need to remove 47,56,75,90,115
%numbers missing BMI: 2,3,4,5,7,72,80,129,
BMI2=BMI([1,6,8:46,48:55,57:71,73,74,76:79,81:89,91:114,116:128,130:end],:);
Age2 = Age([1,6,8:46,48:55,57:71,73,74,76:79,81:89,91:114,116:128,130:end],:);
ill_type = ill_type';
ill_type2 = ill_type([1,6,8:46,48:55,57:71,73,74,76:79,81:89,91:114,116:128,130:end],:);
thick_comb2 = thick_comb([1,6,8:46,48:55,57:71,73,74,76:79,81:89,91:114,116:128,130:end],:);
A = term(Age2);
ILL= term(ill_type2);
B = term(BMI2);






new_comb = thick_comb([8:46,48:55,57:67,78:83,85:86,90:91,96:99,102,104:111,113:114,118:120,122:123,125,127:128,130,132:135,138],:);

new_comb2 = new_comb(59:end,:);

new_comb3 = new_comb(1:58,:);
num2 = xlsread('/Users/christopherrowley/Downloads/CNSVSICMfull.xlsx',7,'C2:AJ59'); %59

B = term(num(:,1));
%Model =1+  A + A^2 + ILL  + B + A^2*ILL; 
Model = 1 + B;
%slm = SurfStatLinMod(thick_comb2,Model,S); %you get your predictor matrix in slm.X
slm = SurfStatLinMod(new_comb2,Model,Ysmooth); %you get your predictor matrix in slm.X

p_stat=zeros(1,size(mars_cropped,2)); 
Rsquared_stat=zeros(1,size(mars_cropped,2));

for k = 1:140 %if you change the size, delete the variables below
    maskROI = mars_roi == k;
    ROI_values(:,k) = nanmean( new_comb2(:, maskROI), 2 );
    [b,bint,r,rint,stats] = regress(ROI_values(:,k),slm.X); %reun regression of signal values with age for each ROI
    Rsquared_stat(mars_cropped==k) = stats(:,1);
    R_ROI(k,1) = stats(:,1);
    p_stat(mars_cropped==k) = stats(:,3);
    p_ROI(k,1) = stats(:,3);
   % F_stat(mars_roi==k) = stats(:,2);
    %f_ROI(k,1) = stats(:,2);
    %coeff_confidence(k,:) = bint;
end


figure;
    SurfStatViewData(p_stat,Ysmooth, 'p-values quadratic', grey)
    SurfStatColLim([0 0.05]), colormap(flipud(coolmap))
    
figure;
    SurfStatViewData(Rsquared_stat,Ysmooth, 'R-squared values', grey)
    SurfStatColLim([0 0.35]), colormap('hot') 
    
% figure;
%     SurfStatViewData(F_stat,Ysmooth, 'F-statistic values', grey)
%     SurfStatColLim([0 10]), colormap('jet') 


 %%%%%%%%%%%%%%
 B = term(num2(:,1));
%Model =1+  A + A^2 + ILL  + B + A^2*ILL; 
Model = 1 + B;
%slm = SurfStatLinMod(thick_comb2,Model,S); %you get your predictor matrix in slm.X
slm = SurfStatLinMod(new_comb3,Model,Ysmooth); %you get your predictor matrix in slm.X

p_stat=zeros(1,size(mars_cropped,2)); 
Rsquared_stat=zeros(1,size(mars_cropped,2));

for k = 1:140 %if you change the size, delete the variables below
    maskROI = mars_roi == k;
    ROI_values2(:,k) = nanmean( new_comb3(:, maskROI), 2 );
    [b,bint,r,rint,stats] = regress(ROI_values2(:,k),slm.X); %reun regression of signal values with age for each ROI
    Rsquared_stat(mars_cropped==k) = stats(:,1);
    R_ROI(k,1) = stats(:,1);
    p_stat(mars_cropped==k) = stats(:,3);
    p_ROI(k,1) = stats(:,3);
   % F_stat(mars_roi==k) = stats(:,2);
    %f_ROI(k,1) = stats(:,2);
    %coeff_confidence(k,:) = bint;
end


figure;
    SurfStatViewData(p_stat,Ysmooth, 'p-values quadratic', grey)
    SurfStatColLim([0 0.05]), colormap(flipud(coolmap))
    
figure;
    SurfStatViewData(Rsquared_stat,Ysmooth, 'R-squared values', grey)
    SurfStatColLim([0 0.35]), colormap('hot') 
    
  %%
  %mapping R outputs
  
  p_vals = [0.3,0.3,0.058232769,0.3,100,100,100,0.058822036,0.042412152,100,0.3,100,0.038036188,0.068762031,0.059637909,0.037134149,0.3,0.3,0.3,0.081088125,0.02502607,0.079820764,0.005800644,0.007028947,0.028614076,0.002384085,0.011560823,0.029790969,0.001677483,0.3,0.053613577,0.10943467,0.053573899,0.019825333,0.013766007,0.03987362,0.3,100,100,0.3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.3,0.3,0.070471381,0.076251266,100,100,100,0.017903414,0.3,100,0.3,100,0.040219229,0.026176507,0.071417669,0.021422609,0.3,0.3,0.022286071,0.028144327,0.3,0.026183362,0.002629829,0.011814703,0.056059072,0.012051901,0.004908036,0.018020871,0.022647681,0.3,0.029078356,0.005567432,0.013754468,0.3,0.110482865,0.3,0.031050369,0.052903963,0.167804536,0.3];
  p_vals(p_vals>0.05) = 0.11;
  
  
for k = 1:140
    ROI_p_vals(mars_roi==k) = p_vals(k);
end  
   
figure;
    SurfStatViewData(ROI_p_vals, Ysmooth, '1/2depth depth vertical shift',grey)
    SurfStatColLim([0 0.15]) %1.65
    colormap(hotcoldmapzscore)


%check the colour bar
figure;
imagesc(interp2(rand(10),2))
colormap(hotcoldmapzscore); colorbar   
    
%%%new plots for manpreet on Aug 23, 2017
part_eta = [0,0,0,0,0,0,0,0.08577023,0,0,0.04384086,0,0.04099969,0.06154358,0.05644366,0.04827013,0,0,0,0,0,0,0,0,0,0,0,0.05012832,0.05194028,0,0.03634713,0.07949524,0.02520619,0.02249454,0.04098876,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.04558622,0,0,0.03568299,0,0.0571769,0.04332751,0.05322922,0.05016643,0,0,0,0,0,0,0,0,0,0,0,0.06565884,0.04758668,0,0.01781853,0.05495085,0.01917237,0.03681999,0.01319304,0,0,0,0,0,0];
coef_con = [0,0,0,0,0,0,0,3.8,0,0,8.7,0,10.6,10.05,9.8,11.6,0,0,0,0,0,0,0,0,0,0,0,7.18,11.22,0,13.56,8.4,12.4,12.48,6.8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3.07,0,0,12.02,0,8.13,4.8,7.2,9.65,0,0,0,0,0,0,0,0,0,0,0,6.97,9.08,0,11.3,7.4,8.15,8.74,13.9,0,0,0,0,0,0];
coef_bp = [0,0,0,0,0,0,0,64.35,0,0,48.22,0,48.76,56.61,54.1,54.2,0,0,0,0,0,0,0,0,0,0,0,46.91,55.15,0,45.38,61.59,43.2,40.8,45.64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,47.5,0,0,48.81,0,53.53,45.31,53.34,55.71,0,0,0,0,0,0,0,0,0,0,0,51.42,49.38,0,35.84,51.81,35.2,48.17,36.07,0,0,0,0,0,0];

grey = [0.7,0.7,0.7];
mars_roi_data_view(part_eta,vertcat(grey, summer),5, 0,0.1, Ysmooth, mars_roi) %partial eta
mars_roi_data_view(coef_con,vertcat(grey, jet),5, 0,70, Ysmooth, mars_roi) %coef con
mars_roi_data_view(coef_bp,vertcat(grey, jet),5, 0,70, Ysmooth, mars_roi) %coef bp


grey = [0.7,0.7,0.7];
colour = vertcat(grey, summer);


%test the sides
ROI_p_vals=zeros(1,size(mars_roi,2));
for k = 1:140
    if k<41
        ROI_p_vals(mars_roi==k) = 1;
    end
end  
figure;
    SurfStatViewData(ROI_p_vals, Ysmooth, '1/2depth depth vertical shift',grey)
    SurfStatColLim([0 1])





 %Partial eta2
 
 eta2_p = [0.031897785,0.020248796,0.035760298,0.024577496,0,0,0,0.035596571,0.04095064,0,0.029624765,0,0.042747428,0.033067685,0.035372691,0.043144275,0.031841569,0.031394447,0.027655316,0.030419868,0.049705974,0.030671732,0.074357955,0.071104235,0.047471023,0.089421495,0.062687537,0.0468,0.095366162,0.025487808,0.037107035,0.02567782,0.037119121,0.05360626,0.05974175,0.041968238,0.031289391,0.016051219,0.022693674,0.018342329,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.013198219,0.048186113,0.032671805,0.031404561,0,0,0,0.055318355,0.045289128,0,0.042487478,0,0.041825824,0.048955522,0.032456977,0.05230712,0.033472429,0.014058282,0.051645283,0.047746782,0.019668976,0.048951152,0.087760832,0.062320738,0.0363796,0.061985154,0.077189551,0.055208482,0.051375834,0.022585391,0.047202989,0.075053284,0.059755888,0.031972793,0.025528791,0.030292544,0.046111371,0.037324604,0.019128473,0.011851807];
 
for k = 1:140
    ROI_eta2_p(mars_roi==k) = eta2_p(k);
end  
 %dont need to set areas to 0 where linear model didnt fit. Still ok to have effect size of non-significant interaction term. This can tell you if it was due to no effect, or possibly small populace.     
 %eta2_p2(p_vals >0.29) = 0;   
    
  figure;
    SurfStatViewData(ROI_eta2_p, Ysmooth, '1/2depth depth vertical shift',grey)
    SurfStatColLim([0 0.1]) %1.65
    colormap(autumn)  

%colour bar testing...    
%     
%        imagesc(interp2(rand(10),2))
%       colormap(hotcoldmapzscore); colorbar   
    
    
    
    
    
    
    
    
    
    
    %try regstats2
 
% ROI_values = ROI_values([1,6,8:46,48:55,57:71,73,74,76:79,81:89,91:114,116:128,130:end],:);
% 
% linear_ouput_stats = fitlm(ROI_values, slm.X);
% 
% 
% tbl = table(Age2, BMI2, ill_type2, ROI_values);
% tbl.ill_type2 = nominal(tbl.ill_type2);
% 
% lm = fitlm(tbl,'ROI_values1~ Age2 + Age2^2 + BMI2 + ill_type2 + Age2^2*ill_type2','quadratic')



% %to estimate parameters slm.X, slm.df, slm.coeff, slm.SSE, slm.tri,%slm.resl
% contrast = Age.*ILL.Control - Age.*ILL.bp1; %set up the contrast for the T test
% 
% %now estimate the effect by looking at T scores
% slm = SurfStatT(slm,contrast);
% %slm = SurfStatT(slm, (-Age.*B.Control)-(-Age.*B.Bipolar)); 
% % slm = SurfStatT(slm, -Age) ;
% %next we have p-values
% p = 1 - tcdf(abs(slm.t),slm.df);
% figure;
%     SurfStatViewData(p,Ysmooth, 'p-values- bipolar1 vs control interaction age', grey)
%     SurfStatColLim([0 0.3])
%p-values %Goodness fit R-squared

% ILL2 = double(ILL);
% 
% inter = ones(size(Age));
% predictors = horzcat(inter,Age, Age.^2,); %predictor matrix   ,Age.^2
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
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EXTRAS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  
% %Simple stats
% % me1 = nanmean(vertcat(smoothed_thick1,smoothed_thick2),1);
% % me2 = nanmean(vertcat(smoothed_thick3,smoothed_thick4),1);
% %me1=mean(thick_comb,1);
% 
% 
% % figure;
% %     SurfStatView(me1,Ysmooth, 'control Mean',grey); %default bakground is white
% %      SurfStatColLim([2.1 2.4]), colormap('jet')
% % figure;
% %     SurfStatView(me2,Ysmooth, 'bipolar Mean',grey); %default bakground is white
% %      SurfStatColLim([0 5]), colormap('jet')
% 
% % abs_diff = me1 - me2;
% % percent_diff = (abs_diff./me1)*100; 
% % var1= ((var(vertcat(smoothed_thick1,smoothed_thick2))) ./me1) *100;
% % var2= ((var(vertcat(smoothed_thick3,smoothed_thick4))) ./me2) *100;
% 
% % figure;
% %     SurfStatView(var1,Ysmooth, 'variance control',grey) %default bakground is white
% %     SurfStatColLim([-10 10]), colormap('jet')    
% % figure;
% %     SurfStatView(slm.coef(2,:),Ysmooth, 'variance bipolar',grey) %default bakground is white
% %     SurfStatColLim([-10 10]), colormap('jet') %for signal [0.0005 0.002]
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%Linear model
% % %CRP
% % thick_comb = vertcat(smoothed_thick1,smoothed_thick2); %for unsmoothed
% % CRP2 = CRP([1,4:end],:);
% % Age2 = Age([1,4:end],:);
% % thick_comb2 = thick_comb([1,4:end],:);
% % C = term(CRP2);
% % A = term(Age2);
% % Model = 1 + A + C;
% % slm = SurfStatLinMod(thick_comb2,Model,S);
% % slm = SurfStatT(slm, -CRP2) ;
% % p = 1 - tcdf(abs(slm.t),slm.df);
% % figure;
% %     SurfStatViewData(p,Ysmooth, 'p-values- Effect of CRP on M', grey)
% %     SurfStatColLim([0 0.3])
% 

%%%%%%%% Gender controls for Nick %%%%%%%%%%
Age = (Age_group2)';
A = term(Age);
Model = 1 + A + A^2; 
slm = SurfStatLinMod(smoothed_thick2,Model,S);
%slm.coef(3,:) = SurfStatSmooth( slm.coef(3,:), Ysmooth, 10 );

num_labels = 141;
ROI_quad_max = zeros(1,size(smoothed_thick2,2)); %find the maximum value the fit takes on
ROI_quad_vertshift = zeros(1,size(smoothed_thick2,2));
ROI_coef_square=zeros(1,size(smoothed_thick2,2));

for k = 1:num_labels  %for each of the labels
    maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
    masked_coeff = maskROI.*slm.coef(2,:);
    coeffMean_lin = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
    masked_square = maskROI.*slm.coef(3,:);
    coeffMean_square = nanmean(masked_square(masked_square~=0));
    quad_max(k) = -coeffMean_lin/(2*coeffMean_square); %this is where the derivative is zero
    ROI_quad_max(mars_cropped==k) = quad_max(k); %fill ROI matrix for each label with the mean coefficient. 
end

% for k = 1:num_labels  %for each of the labels
%     maskROI = mars_cropped == k;  %make a matrix of 0,1's where the desired label is
%     masked_coeff = maskROI.*slm.coef(3,:);
%     coeffMean = nanmean(masked_coeff(masked_coeff~=0));% mean of nonzero elements
%     ROI_coef_square(mars_cropped==k) = coeffMean; %fill ROI matrix for each label with the mean coefficient. 
% end


%view the maps
figure;
    SurfStatViewData(ROI_quad_max, Ysmooth, 'horizontal shift',grey)
    SurfStatColLim([30 40])
    colormap(coolmap)
    
%  figure;
%     SurfStatViewData(ROI_coef_square, Ysmooth, 'A^2 term',grey)
%     SurfStatColLim([-0.0004 0.0004])
%     colormap(fireice)
    %colormap(flipud(parula))


%  figure;
%     SurfStatViewData(ROI_quad_vertshift, Ysmooth, 'vert shift',grey)
%     SurfStatColLim([1.3 1.8]) %1.65
%     colormap(hot)


