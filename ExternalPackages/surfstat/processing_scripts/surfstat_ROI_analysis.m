%%load ROI for surfstat
%Import volumetric atlas
%work on adjusting this so you pick your area first, then make everything
%else 0. 

clear all
close all
%%inputs 
file_1 = '/Users/christopherrowley/Desktop/Masters/surface_outputs/control/left-female-conWM.vtk';
file_2 = '/Users/christopherrowley/Desktop/Masters/surface_outputs/control/left-male-conWM.vtk';
%ROI_file = ('/Users/christopherrowley/Desktop/HBM-2016/HBM-atlases/right_3quarter-labels.vtk');
ROI_file = '/Users/christopherrowley/Desktop/stuff_for_Manpreet/manpreet-atlases/left-wm-FULLmfg.vtk';
grey = [0.7,0.7,0.7];

%load surface 1-4signal
[vertex, face]= read_vtk(ROI_file);
S=struct('tri',face','coord',vertex);
n1=37;
n2=30;
Age_group1 = [23,23,45,41,26,44,24,20,25,28,26,29,40,35,27,28,21,21,21,33,32,21,21,29,43,41,32,21,18,41,24,36,38,40,31,42,45];
Age_group2 = [26,26,22,17,30,34,19,25,23,19,19,37,21,21,19,28,27,25,31,32,43,38,41,35,30,34,42,40,41,30];
Age = horzcat(Age_group1,Age_group2)'; 
age = term(Age);
%load the values from the ROI surface

ROI.t=thickness_from_vtk_group(ROI_file,1);
ROI.tri=S.tri;

%Visualize the labels
% figure;
% SurfStatView( ROI.t, S, 'Do you have the right side?' );
%load data
T_group1=thickness_from_vtk_group(file_1,n1); %no need to smooth in ROIs
T_group2=thickness_from_vtk_group(file_2,n2);
thick_comb = vertcat(T_group1,T_group2);

%Setup variables for the model that are based on subjects
cat1=repmat({'Women'},1,n1);
cat2=repmat({'Men'},1,n2);
G=horzcat(cat1,cat2);
Gender = term(G);
%% 
%now you have everything loaded, now you can run different stats
mask_wanted = 1;   %choose what label you want

%pick a cluster
maskROI = ROI.t == mask_wanted;
figure;
SurfStatView( maskROI, S, 'ROI selected' );
    SurfStatColLim([0 4])
%average the data in the cluster
YROI = nanmean( thick_comb(:, maskROI), 2 );
%Run up till here to just get the average over the ROI for each subject%
YROI = nanmean( T_G1(:, maskROI), 2 );
%%
%extra stuff
smoothed_thick1 = SurfStatSmooth( T_group1, S, 5 );
smoothed_thick2 = SurfStatSmooth( T_group2, S, 5 );
me1 = mean(smoothed_thick1,1);
me2 = mean(smoothed_thick2,1);
thick_combined_smooth= vertcat(smoothed_thick1,smoothed_thick2);

% figure;
%     SurfStatView(me1,S, 'Female Mean',grey) %default bakground is white
%      SurfStatColLim([1.25 1.85]), colormap('jet')
% 
% figure;
%     SurfStatView(me2,S, 'Male Mean',grey) %default bakground is white
%     SurfStatColLim([1.25 1.85]), colormap('jet')

%Linear model
Model2 = 1 + Gender + age; 
slm2 = SurfStatLinMod(thick_combined_smooth,Model2,S);
%to estimate parameters slm.X, slm.df, slm.coeff, slm.SSE, slm.tri,
%slm.resl

%now estimate the effect by looking at T scores
slm2 = SurfStatT(slm2,Gender.Women-Gender.Men);
%next we have p-values
p = 1 - tcdf(abs(slm2.t),slm2.df);
figure;
    SurfStatViewData(p,S, 'p-values', 'white')
    SurfStatColLim([0 0.10])

%view t maps
figure;
    SurfStatViewData(slm2.t,S, 'T-values women', grey)
    SurfStatColLim([0 4])
figure;
    SurfStatViewData((slm2.t*(-1)),S, 'T-values men', grey)
    SurfStatColLim([0 4])
    
%Random field theory clustering
[l,v]=size(slm2.t);
mask= true(1,v);
[pval,peak,clus,clusid] = SurfStatP(slm2,mask,0.15);
figure; 
    SurfStatView(pval, S, 'RFT-FWE');
term(clus)


%%
%Extra stuff i don't need right now
% %This will give you a vector of the average thickness inside the ROI. To plot it against age, adjusting for gender:
% slm = SurfStatLinMod( thick_comb, 1 + Age + Gender);
% figure;
% SurfStatPlot( Gender, YROI);
% 
% % YROI can be treated exactly like Y itself, but without specifying the surface, e.g.
% % 
% % 
% slmROI = SurfStatLinMod( YROI, 1 + Age + Gender );
% slmROI = SurfStatT( slmROI, -Age )
% %        X: [147x4 double]
% %       df: 144
% %     coef: [4x1 double]
% %      SSE: 14.3026
% %       ef: 0.0159
% %       sd: 0.0054
% %        t: 2.9428
% % Obviously FDR is irrelevant, but to get P-values use
% % 
% SurfStatP( slmROI )
% %    P: 0.0019
% % You could also get F statistics in the usual way:
% % 
% % slmROI = SurfStatF( slmROI, slm0ROI )
% % SurfStatP( slmROI )