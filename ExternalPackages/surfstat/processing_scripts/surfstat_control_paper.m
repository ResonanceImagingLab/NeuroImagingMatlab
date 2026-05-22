%%Surfstat script for surface analysis of thickness data
clear all
close all
%%%%%%%%%%%%%%%inputs 
depth_thick = '1-2signal'; %1-2signal

%%control n1=female
n1=37;
n1_cog=30;
n2=30;

Age_group1 = [20,25,28,26,29,40,35,27,28,21,21,21,33,32,21,21,29,43,41,32,21,18,41,24,36,38,40,31,42,45];
Age_group2 = [26,26,22,17,30,34,19,25,23,19,19,37,21,21,19,28,27,25,31,32,43,38,41,35,30,34,42,40,41,30];
%Age_group1_full = [23,23,45,41,26,44,24,20,25,28,26,29,40,35,27,28,21,21,21,33,32,21,21,29,43,41,32,21,18,41,24,36,38,40,31,42,45];

Psych1 = [217,206,223,224,182,187,190,223,166,189,229,210,185,177,205,187,95,160,181,152,186,181,186,197,138,161,195,170,215,202,153,181,186,188,63,177,206,171,203,200,174,237,190,168,222,188,196,184,195,198,157,219,234,164,196,177,180,158,196,227]';
Proc_speed1 = [101,87,91,84,70,72,67,72,59,60,74,80,64,69,75,76,57,53,65,52,72,66,67,73,40,62,65,69,38,70,63,78,60,54,61,54,89,57,59,72,44,76,58,69,79,81,71,59,70,70,49,74,67,51,62,60,60,44,78,75]';
Verb_mem1 = [56,57,58,55,54,58,52,56,47,54,54,55,49,60,57,51,56,51,57,49,52,54,51,52,44,54,57,46,52,57,49,56,56,58,40,54,55,51,53,55,53,55,51,55,41,55,50,54,41,56,56,59,60,53,57,52,58,57,58,55]';
Simple_attent1 = [40,39,40,7,39,39,40,39,40,40,40,39,40,40,40,40,37,40,39,29,40,40,39,40,40,40,40,39,39,40,40,40,38,37,40,39,39,36,40,40,19,40,40,39,39,39,40,40,40,39,39,35,40,37,39,40,40,38,40,40]';
Motor_speed1 = [116,119,132,140,112,113,123,150,107,128,155,129,121,108,129,110,103,94,116,99,114,115,118,123,95,99,129,100,166,131,89,102,126,133,141,121,116,114,141,125,120,161,132,99,141,107,123,124,124,128,106,145,167,111,134,117,119,114,117,151]';
%%%%%%%%%%%%%%%%%%%%%%Code
%set up demographics for GLM
cat1=repmat({'Women'},1,n1_cog); %gender
cat2=repmat({'Men'},1,n2);
sex=horzcat(cat1,cat2);

Age = horzcat(Age_group1,Age_group2)'; %age

grey = [0.7,0.7,0.7]; %good background colour for images

%%%%%%%%%%%%%%%%%Now work with the data
%load vtk surface
S = Load_and_Combine_sides( depth_thick,'con','male');

%load group 1 thickness
T_group1 = Load_and_Combine_thickness(depth_thick,'con','female',n1);
T_group1_5 = T_group1(8:37,:); %remove the first 7 that have no cognitive data.
smoothed_thick1 = SurfStatSmooth( T_group1_5, S, 5 );

%load group 2 thickness data
T_group2 = Load_and_Combine_thickness(depth_thick,'con','male',n2);
smoothed_thick2 = SurfStatSmooth( T_group2, S, 5 );

%smooth the surface
Y = SurfStatSmooth( S.coord, S, 5 );
Ysmooth=struct('tri',S.tri,'coord',Y);
thick_comb = vertcat(smoothed_thick1,smoothed_thick2);

ROI.t = Load_and_Combine_thickness(); %no inputs for ROI
%ROI.t=thickness_from_vtk_group(ROI_half,1);
ROI.tri=S.tri;
%%
%%%%%%%%%%%%%%%%%%%%%%%Linear model
%create terms for cognitive variables
Psych = term(Psych1);
Proc_speed = term(Proc_speed1);
Verb_mem = term(Verb_mem1);
Simple_attent = term(Simple_attent1);
Motor = term(Motor_speed1);
%other terms
G = term(sex);
A = term(Age);
PCA_term = (score(:,2));
made_up_variable = term(PCA_term);

Model = 1 + made_up_variable;
%Model = 1 + A + sex + Psych + Proc_speed + Verb_mem + Simple_attent + Motor; 
slm = SurfStatLinMod(thick_comb,Model,S);
%to estimate parameters slm.X, slm.df, slm.coeff, slm.SSE, slm.tri,
%slm.resl
contrast = -PCA_term; %set up the contrast for the T test
%now estimate the effect by looking at T scores
slm = SurfStatT(slm,contrast);
%slm = SurfStatT(slm, (-Age.*B.Control)-(-Age.*B.Bipolar)); 
% slm = SurfStatT(slm, -Age) ;
%next we have p-values
p = 1 - tcdf(abs(slm.t),slm.df);
figure;
    SurfStatViewData(p,Ysmooth, 'p-values- psycho motor', grey)
    SurfStatColLim([0 0.3])
    
%Random field theory clustering
slm.t=abs(slm.t); %for some reason this is working directionally? we don't want to miss anything,
[l,v]=size(slm.t);
mask=  true(1,v); %ROI.t == 1;
[pval,peak,clus,clusid] = SurfStatP(slm,mask,0.15);
figure; 
    SurfStatView(pval, Ysmooth, 'RFT-FWE- psychomotor');
term(clus)
%%
% %%%%view smoothed map
% figure;
%     SurfStatViewData(smoothed_thick2(26,:), S, 'Smoothed')
%     SurfStatColLim([1.5 1.85]), colormap('jet')
figure;
    SurfStatViewData(smoothed_thick2(14,:), S, 'Smoothed')
    SurfStatColLim([0 2.5]), colormap('jet')

% % FDR correct data
% qval = SurfStatQ(slm);
% 
% f3=figure;
%     SurfStatViewData(qval.Q, S, 'FDR')
%     SurfStatColLim([0 0.1])

%%
%%%%%%%%View interaction effects from a cluster
clus_no=1; 
Yclus=zeros(60,1);
mask_clus = (clusid==clus_no);

for i=1:(60) %for each person in the group
        masked_data = mask_clus.*thick_comb(i,:); %multiply data by cluster locations
        Yclus(i,:) = nanmean(masked_data(masked_data~=0)); %now take the average over the cluster

end

%for full brain average
%%ROI file
% ROI_half = ('/Users/christopherrowley/Desktop/Masters/Atlases/surface-masks/right-onlycortex.vtk');
% ROI.t=thickness_from_vtk_group(ROI_half,1);
% ROI.tri=S.tri;
% 
% maskROI = ROI.t == 1;
% Yclus = nanmean( thick_comb(:, maskROI), 2 );

figure;
SurfStatPlot(Proc_speed1, Yclus, 1, 1,'LineWidth',6, 'MarkerSize',20 ) ; %plot the cluster with fit lines 'LineWidth',6, 'MarkerSize',20 )

figure; 
    SurfStatView(maskROI, Ysmooth, 'Cluster');


%%
%Extras

%Simple stats
% me1 = nanmean(vertcat(smoothed_thick1,smoothed_thick2),1);
% me2 = nanmean(vertcat(smoothed_thick3,smoothed_thick4),1);

% figure;
%     SurfStatView(me1,Ysmooth, 'control Mean',grey); %default bakground is white
%      SurfStatColLim([2.1 2.4]), colormap('jet')
% figure;
%     SurfStatView(me2,Ysmooth, 'bipolar Mean',grey); %default bakground is white
%      SurfStatColLim([0 5]), colormap('jet')

% abs_diff = me1 - me2;
% percent_diff = (abs_diff./me1)*100; 
% var1= ((var(vertcat(smoothed_thick1,smoothed_thick2))) ./me1) *100;
% var2= ((var(vertcat(smoothed_thick3,smoothed_thick4))) ./me2) *100;

%view t maps
% figure;
%     SurfStatViewData(slm.t,S, 'T-values', grey)
%     SurfStatColLim([-4 4])
    
%Plot data from a seed
% seed_numb = 75528;
% Yseed = double( thick_comb(:,seed_numb) );
% figure;
% SurfStatPlot( Age, Yseed);
