addpath(genpath('MP2RAGE-related-scripts-master')) % download from here: https://github.com/JosePMarques/MP2RAGE-related-scripts

%% Setup Parameters
% use milliseconds throughout.
t1_csf = 4500;
t1_wm = 900;
t1_gm = 1300;

thres_bkgd_level = 0.001; % If trying to 'mute' background signal, set this to be low.
thres_sig_min = 0.03; % ensure a minimal signal for the GM and WM


% For simplicity, use Marques' code for MPRAGE
MPRAGE_tr = linspace(500, 5000,60);
inversiontimes = linspace(100, 2500,60); 
nZslices = 100;
FLASH_tr = 7;
flipangle = 5;
sequence = 'normal';
t1s = [t1_csf; t1_wm; t1_gm];
nimages = 1;

%% No need to adjust anything below here:
%%%%%%%%%%%%%%%%%%%%% Calculations:
y1 = zeros(length(MPRAGE_tr),length(inversiontimes));
y2 = zeros(length(MPRAGE_tr),length(inversiontimes));
y3 = zeros(length(MPRAGE_tr),length(inversiontimes));

for j  = 1:length(MPRAGE_tr)
    for i = 1:length(inversiontimes)
        y1(j,i) = MPRAGEfunc(nimages,MPRAGE_tr(j),inversiontimes(i),nZslices,FLASH_tr,flipangle,sequence,t1s(1));
        y2(j,i) = MPRAGEfunc(nimages,MPRAGE_tr(j),inversiontimes(i),nZslices,FLASH_tr,flipangle,sequence,t1s(2));
        y3(j,i) = MPRAGEfunc(nimages,MPRAGE_tr(j),inversiontimes(i),nZslices,FLASH_tr,flipangle,sequence,t1s(3));
    end
end


% Perhaps a better summary plot would be a surface.
[X,Y] = meshgrid(inversiontimes,MPRAGE_tr);

% If we assume a noise level of 0.001, we can derive CNR and plot that. 
Z1 = (y2 - y3)/ 0.001;

% Set a cutoff threshold
temp = abs(y1);

% concatenate matrices for sorting and extraction
temp = [temp(:), X(:), Y(:), Z1(:),y2(:),y3(:) ];
TF = (temp(:,1) <thres_bkgd_level) & (temp(:,5) > thres_sig_min) & (temp(:,6) > thres_sig_min);
thresSig = temp(TF,:);

[cnr, idx] = sort(thresSig(:,4),'descend');
prot = thresSig(idx,:);

figure;
surf(X,Y,Z1)
xlabel('Inversion Time(ms)')
ylabel('TR (ms)')
zlabel('CNR')
hold on
scatter3( prot(1,2), prot(1,3), prot(1,4),80,'red','filled'   ) 
    ax = gca;
    ax.FontSize = 12; 
view(-10,50)

% Display the table results for easy viewing
prot = array2table(prot,'VariableNames',{'Background Signal','Inversion Time',...
    'TR', 'GM-WM CNR','WM Signal','GM Signal'});

disp(prot(1,:))
