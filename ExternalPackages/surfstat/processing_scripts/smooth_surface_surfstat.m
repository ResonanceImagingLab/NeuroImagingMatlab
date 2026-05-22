% ROI_file = ('/Users/christopherrowley/Desktop/HBM-2016/HBM-atlases/left_1quarter-labels.vtk');
% [vertex, face]= read_vtk(ROI_file);
% S=struct('tri',face','coord',vertex);
% ROI.t=thickness_from_vtk_group(ROI_file,1);
% ROI.tri=S.tri;
grey = [0.7,0.7,0.7];

%%Try and smooth surface

Y = SurfStatSmooth( S.coord, S, 5 );
Ysmooth=struct('tri',face','coord',Y);

figure;
    SurfStatView(me1,Ysmooth, 'Female Mean',grey); %default bakground is white
     SurfStatColLim([0 5]), colormap('jet')
figure;
    SurfStatView(me2,Ysmooth, 'Male Mean',grey); %default bakground is white
     SurfStatColLim([0 5]), colormap('jet')
     
%look at ROI

% figure;
% SurfStatView( ROI.t, Ysmooth, 'Do you have the right side?',grey );