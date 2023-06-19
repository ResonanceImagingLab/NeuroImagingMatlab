addpath(genpath('/data_/tardiflab/chris/development/scripts/MP2RAGE-related-scripts-master')) % needed for ihMTsat noise calc

tic

%% Setup Parameters
t1_csf = 4500;
t1_wm = 900;
t1_gm = 1300;

sortString = 'all-combined'; % Protocol sorting condition
% other options:
% 'WM-CSF' , 'GM-CSF', 'all-combined', 'GM-WM';


thres_bkgd_level = 0.001; % If trying to 'mute' background signal, set this to be low.
thres_sig_min = 0.03; % ensure a minimal signal for the GM and WM


% For simplicity, use Marques' code for MPRAGE
% use milliseconds
MPRAGE_tr = linspace(500, 5000,60);
inversiontimes1 = linspace(100, 3000,60); 
inversiontimes2 = linspace(100, 5000,60); 
nZslices = 100;
FLASH_tr = 7;
flipangle = [4, 5];
sequence = 'normal';
t1s = [t1_csf; t1_wm; t1_gm];
nimages = 2;

%% Need to loop through and make sure parameters are compatible.

ParameterSet = zeros(length(MPRAGE_tr)*length(inversiontimes1)*length(inversiontimes2), 3);

idx = 1;
for i = 1:length(MPRAGE_tr)
    for j = 1:length(inversiontimes1)
        for k = 1:length(inversiontimes2)

            % conditions:

            % no overlaps between the readouts
            if (inversiontimes1(j)+nZslices/2*FLASH_tr) >= (inversiontimes2(k)-nZslices/2*FLASH_tr) 
                continue;
            end

            % Second readout must fit within the TR;
            if (inversiontimes2(k)+nZslices/2*FLASH_tr) >  MPRAGE_tr(i)
                continue;
            end

            % First readout must fit:
            if (inversiontimes1(j)-nZslices/2*FLASH_tr) < 0
                continue;
            end

            ParameterSet(idx,:) = [MPRAGE_tr(i),inversiontimes1(j), inversiontimes2(k)];
            idx = idx+1;

        end
    end
end

% Remove extra entries:
ParameterSet(idx:end,:) = [];


%% Calculate the MP2RAGE Signal.
%%%%%%%%%%%%%%%%%%%%% Calculations:
y1 = zeros(length(ParameterSet),2);
y2 = zeros(length(ParameterSet),2);
y3 = zeros(length(ParameterSet),2);

for j  = 1:length(ParameterSet)
    y1(j,:) = MPRAGEfunc(nimages,ParameterSet(j,1), [ParameterSet(j,2),ParameterSet(j,3)], nZslices,FLASH_tr,flipangle,sequence,t1s(1));
    y2(j,:) = MPRAGEfunc(nimages,ParameterSet(j,1), [ParameterSet(j,2),ParameterSet(j,3)], nZslices,FLASH_tr,flipangle,sequence,t1s(2));
    y3(j,:) = MPRAGEfunc(nimages,ParameterSet(j,1), [ParameterSet(j,2),ParameterSet(j,3)], nZslices,FLASH_tr,flipangle,sequence,t1s(3));
end

%% I need to somehow use this to get good T1 estimation values for each T1.

% Calculate the uni-value
Uni1 = (y1(:,1).*y1(:,2)) ./ (y1(:,1).^2 + y1(:,2).^2) ;
Uni2 = (y2(:,1).*y2(:,2)) ./ (y2(:,1).^2 + y2(:,2).^2) ;
Uni3 = (y3(:,1).*y3(:,2)) ./ (y3(:,1).^2 + y3(:,2).^2) ;


% Calculate 3way CNR per unit time:
noise = 0.0005;
CNR12 = abs(Uni1 - Uni2)./ (sqrt(2*noise^2)) .*(1./sqrt(ParameterSet(j,1)));
CNR23 = abs(Uni2 - Uni3)./ (sqrt(2*noise^2)) .*(1./sqrt(ParameterSet(j,1)));
CNR13 = abs(Uni1 - Uni3)./ (sqrt(2*noise^2)) .*(1./sqrt(ParameterSet(j,1)));


%% Should we combine the CNR?
CNR_c = CNR12+CNR13+CNR23;

switch sortString
    case 'GM-WM'
        CNR = CNR23;
    case 'WM-CSF'
        CNR = CNR12;
    case 'GM-CSF'
        CNR = CNR13;
    case 'all-combined'
        CNR = CNR_c;
    otherwise
        error('see function for options in setting sortString')
end


%% Concatenate into a matrix for Viewing:
temp = [ParameterSet, Uni1, Uni2, Uni3, CNR,y1, y2, y3 ];

%% Sort by which provides the best CNR:
[~, idx] = sort(CNR,'descend');
prot = temp(idx,:);

%% To visualize this, probably best to do 3D scatter plots:

% 3D scatter: TR vs Inversion1 vs CNR
figure;
scatter3( ParameterSet(:,1), ParameterSet(:,2),CNR,40,CNR,'filled'   ) 
ylabel('Inversion Time 1 (ms)')
xlabel('TR (ms)')
zlabel('CNR')
hold on
scatter3( prot(1,1), prot(1,2),CNR(idx(1)),80,'red','filled'   ) 
    ax = gca;
    ax.FontSize = 12; view(2)
    colorbar

% 3D scatter: TR vs Inversion2 vs CNR

figure;
scatter3( ParameterSet(:,1), ParameterSet(:,3),CNR,40,CNR,'filled'   ) 
ylabel('Inversion Time 2 (ms)')
xlabel('TR (ms)')
zlabel('CNR')
hold on
scatter3( prot(1,1), prot(1,3),CNR(idx(1)),80,'red','filled'   ) 
    ax = gca;
    ax.FontSize = 12; 
view(2)
colorbar

% 3D scatter: Inversion1 vs Inversion2 vs CNR
figure;
scatter3( ParameterSet(:,2), ParameterSet(:,3),CNR,40,CNR,'filled'   ) 
xlabel('Inversion Time 1 (ms)')
ylabel('Inversion Time 2 (ms)')
zlabel('CNR')
hold on
scatter3( prot(1,2), prot(1,3),CNR(idx(1)),80,'red','filled'   ) 
    ax = gca;
    ax.FontSize = 12; 
view(2)
colorbar


% Change this to include more variables by concatentating the above.
% Perhaps the CNR values, and signal values 
prot = array2table(prot,'VariableNames',{'MP2RAGE TR','Inversion Time 1',...
    'Inversion Time 2', 'Uni1', 'Uni2', 'Uni3', 'CNR', 'CSF Inv 1',...
    'CSF Inv 2', 'WM Inv 1', 'WM Inv 2', 'GM Inv 1', 'GM Inv 2'});

disp(prot(1,:))
disp('Note the UNI values are scaled to be between -0.5 and 0.5')

toc




