
%number subjects per file
n1 = 44;
n2 = 45;
n3 = 44;
n4 = 48;
n5 = 42;
n6 = 53;
n7 = 43;
n8 = 29;

%load surfaces
half_surf = Load_and_Combine_sides_2('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal1.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal1.vtk');
wm_surf = Load_and_Combine_sides_2('/Users/christopherrowley/Desktop/track-hd/vtk_files/left-wm-T12-signal.vtk','/Users/christopherrowley/Desktop/track-hd/vtk_files/right-wm-T12-signal.vtk');

%load thickness data
tic
thick1 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick1.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick1.vtk',n1);
thick2 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick2.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick2.vtk',n2);
thick3 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick3.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick3.vtk',n3);
thick4 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick4.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick4.vtk',n4);
thick5 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick5.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick5.vtk',n5);
thick6 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick6.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick6.vtk',n6);
thick7 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick7.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick7.vtk',n7);
thick8 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/left-thick8.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/thickness/right-thick8.vtk',n8);

thick_comb = vertcat(thick1,thick2,thick3,thick4,thick5,thick6,thick7,thick8);
thick_smooth = SurfStatSmooth( thick_comb, half_surf, 10 );

toc
%load half depth signal data
half1 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal1.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal1.vtk',n1);
half2 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal2.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal2.vtk',n2);
half3 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal3.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal3.vtk',n3);
half4 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal4.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal4.vtk',n4);
half5 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal5.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal5.vtk',n5);
half6 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal6.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal6.vtk',n6);
half7 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal7.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal7.vtk',n7);
half8 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/left-halfsignal8.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/halfdepth-t1t2/right-halfsignal8.vtk',n8);

half_comb = vertcat(half1,half2,half3,half4,half5,half6,half7,half8);
half_smooth = SurfStatSmooth( half_comb, half_surf, 10 );

%load norm signal
norm1 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm1.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm1.vtk',n1);
norm2 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm2.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm2.vtk',n2);
norm3 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm3.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm3.vtk',n3);
norm4 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm4.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm4.vtk',n4);
norm5 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm5.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm5.vtk',n5);
norm6 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm6.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm6.vtk',n6);
norm7 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm7.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm7.vtk',n7);
norm8 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/left-norm8.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/norm-sig/right-norm8.vtk',n8);

norm_comb = vertcat(norm1,norm2,norm3,norm4,norm5,norm6,norm7,norm8);
norm_smooth = SurfStatSmooth( norm_comb, half_surf, 10 );

%load SWM data
svm1 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm1.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm1.vtk',n1);
svm2 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm2.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm2.vtk',n2);
svm3 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm3.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm3.vtk',n3);
svm4 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm4.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm4.vtk',n4);
svm5 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm5.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm5.vtk',n5);
svm6 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm6.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm6.vtk',n6);
svm7 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm7.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm7.vtk',n7);
svm8 = Load_and_Combine_vtkmetric('/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/left-swm8.vtk','/Volumes/ROWLEY_DATA/track-hd/surf_files/vtk_files/wm-signal/right-swm8.vtk',n8);

svm_comb = vertcat(svm1,svm2,svm3,svm4,svm5,svm6,svm7,svm8);
svm_smooth = SurfStatSmooth( svm_comb, wm_surf, 10 );
















