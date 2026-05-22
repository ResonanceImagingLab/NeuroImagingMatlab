%%%%
%load the saved .mat matrices for the smoothed data
%then save image plots. 
%%%%

%load thickness
load('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/saved_matrices/thick_smooth.mat');
%load half depth surface
load('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/saved_matrices/half_surf.mat');
Y = SurfStatSmooth(half_surf.coord,half_surf,3);
Ysmooth = struct('tri',half_surf.tri,'coord',Y);

%create non-visible plots then same them.
i=2;

for i= 1:size(thick_smooth,1);
    filename = strcat('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/thickness_plots/',num2str(i),'_thickness.png');

    %set(fig, 'visible','off')
    f = figure('visible','off');
    SurfStatViewData(thick_smooth(i,:),Ysmooth,'thickness plot');
    SurfStatColLim([0 4]), colormap('jet')
    saveas(f,filename)
    close(f)
    done = i
end
%create average

    filename = strcat('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/thickness_plots/','average_thickness.png');
    av_thick = mean(thick_smooth);
    f = figure('visible','off');
    SurfStatViewData(av_thick,Ysmooth,'thickness plot');
    SurfStatColLim([0 4]), colormap('jet')
    saveas(f,filename)
    close(f)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load signal 
load('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/saved_matrices/half_comb.mat');
half_comb(isnan(half_comb)) = 0.5; %values dont seem to be below this, and will have less effect then0 on smoothing

half_smooth = SurfStatSmooth( half_comb, Ysmooth, 3 );

for i= 1:size(half_smooth,1);
    filename = strcat('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/halfsig_plots/smoothed/',num2str(i),'_halfsig.png');
    f = figure('visible','off');
    SurfStatViewData(half_smooth(i,:),Ysmooth,'thickness plot');
    SurfStatColLim([1 2]), colormap('jet')
    saveas(f,filename)
    close(f)
    done = i
end
%create average

    filename = strcat('/media/crowley/ROWLEY_DATA/track-hd/surf_files/matlab_files/halfsig_plots/smoothed/','average_halfsig.png');
    av_half = nanmean(half_smooth);
    f = figure('visible','off');
    SurfStatViewData(av_half,Ysmooth,'thickness plot');
    SurfStatColLim([1 2]), colormap('jet')
    saveas(f,filename)
    close(f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%separate the different sites, and look just at controls for their
%histogram

%want to find out how to match the histograms so the signal is the same.
%make sure equal distribution of age as well. 

sites = readtable('/home/crowley/Desktop/trackhd_demo.csv');
sites = table2cell(sites);


%find just controls
llc = cellfun(@(x)strcmp('cont',x),sites(:,2));

%find each site
lond = cellfun(@(x)strcmp('london',x),sites(:,1));
paris = cellfun(@(x)strcmp('paris',x),sites(:,1));
van = cellfun(@(x)strcmp('vancouver',x),sites(:,1));
leid = cellfun(@(x)strcmp('leiden',x),sites(:,1));

londcont = logical(lond.* llc); %needs to be logical for the next step
pariscont = logical(paris.* llc);
vancont = logical(van.* llc);
leidcont = logical(leid.* llc);

lond_signal = half_smooth(londcont,:);
paris_signal = half_smooth(pariscont,:);
van_signal = half_smooth(vancont,:);
leid_signal = half_smooth(leidcont,:);


%view averages for controls at each site
lond_mean = nanmean(lond_signal);
paris_mean = nanmean(paris_signal);
van_mean = nanmean(van_signal);
leid_mean = nanmean(leid_signal);

edges = [0.3:0.005:2];

figure;
hist(lond_mean,edges);
axis([0.8 1.9 0 7000])

figure;
hist(paris_mean,edges);
axis([0.8 1.9 0 7000])

figure;
hist(van_mean,edges);
axis([0.8 1.9 0 7000])

figure;
hist(leid_mean,edges);
axis([0.8 1.9 0 7000])




% 
%     figure; 
%     SurfStatViewData(lond_mean,Ysmooth,'thickness plot');
%     SurfStatColLim([0 0.6]), colormap('jet')
%     
%     figure; 
%     SurfStatViewData(paris_mean,Ysmooth,'thickness plot');
%     SurfStatColLim([0 0.6]), colormap('jet')
%     
%     figure;
%     SurfStatViewData(van_mean,Ysmooth,'thickness plot');
%     SurfStatColLim([0 0.6]), colormap('jet')
%     
%     figure;
%     SurfStatViewData(leid_mean,Ysmooth,'thickness plot');
%     SurfStatColLim([0 0.6]), colormap('jet')















