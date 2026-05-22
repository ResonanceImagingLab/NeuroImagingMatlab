%%%%%%%%%%%%%%%%
%Sample script to get you started
% Script is to help you load vtk files created using CBS tools for analysis
% in matlab
%%%%%%%%%%%%%%%%

%load half depth surf
half_surf = Load_and_Combine_sides_2('/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/left_middle_T1w_1.vtk','/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/right_middle_T1w_1.vtk');

%smooth surf
Y = SurfStatSmooth( half_surf.coord, half_surf, 10 );
Ysmooth = struct('tri',half_surf.tri,'coord',Y);

%number of subjects that are included in 1 vtk file
n1 = 62; %checked
n2 = 60; %checked
n3 = 42; %checked
n4 = 59; %checked

%load and save data as matlab matrices. 
half_signal1 = Load_and_Combine_vtkmetric('/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/left_swm_1.vtk','/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/right_middle_T1w_1.vtk',n1);
half_signal2 = Load_and_Combine_vtkmetric('/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/left_middle_T1w_2.vtk','/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/right_middle_T1w_2.vtk',n2);
half_signal3 = Load_and_Combine_vtkmetric('/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/left_middle_T1w_3.vtk','/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/right_middle_T1w_3.vtk',n3);
half_signal4 = Load_and_Combine_vtkmetric('/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/left_middle_T1w_4.vtk','/Users/christopherrowley/Desktop/Masters/surface_outputs/autism/right_middle_T1w_4.vtk',n4);

%smooth data
signalcomb = vertcat(signal1,signal2,signal3,signal4);
smoothed_signal = SurfStatSmooth( signalcomb, Ysmooth, 10 ); %where 10 is smoothing kernel size



%%%%%%%%%%%%%%%%%%%%%%%%%%  PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load the saved data
%load half depth surface
load('/home/chris/Desktop/Ecker_plots/matlab_data/wm_surf.mat');
%load data
load('/home/chris/Desktop/Ecker_plots/matlab_data/5mm-smooth_swmsignal.mat');


%load MARS ROIs
mars_roi = Load_and_Combine_vtkmetric('/home/chris/matlab_processing/mars-parcellation/surfaces/left-MARS-half.vtk','/home/chris/matlab_processing/mars-parcellation/surfaces/right-MARS-half.vtk',1);
%wm mars
% mars_roi = Load_and_Combine_vtkmetric('/home/chris/matlab_processing/mars-parcellation/surfaces/left-MARS-wm.vtk','/home/chris/matlab_processing/mars-parcellation/surfaces/right-MARS-wm.vtk',1);


%%%%%%%% average some value over the ROIs %%%%%%%%%%
n = 223; %number of subjects
surf_data = smoothed_signal; % may change depending on the data loaded
ROI_values=zeros(n, 141); %   
for k = 1:141  %for each of the labels
    maskROI = mars_roi == k;  %make a matrix of 0,1's where the desired label is
    ROI_values(:,k) = nanmean( surf_data(:, maskROI), 2 ); %%Calculates the ROI values for every subject in the vtk file
end



%%%%%%%%%% map calculated values back onto the ROIs %%%%%%%%%%
roi_vector = []; %a vector that is 1x141 in size. spots 42-100 should be 0 (ROIs don't exist)
for k = 1:141
    ROI_vals(mars_roi==k) = roi_vector(k);
end  

%%%%%%%%%%% visualize %%%%%%%%%%%%


figure;
    SurfStatViewData(ROI_vals, Ysmooth, 'Title',grey) %inputs: data, surface, title, background colour
    SurfStatColLim([0 0.05]) %colour bar limits
    colormap(jet)

    
    %go to surfstat online documentation for more functionality. 

