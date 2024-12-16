function [MWFrpca, L1_rpca, L2_rpca, S_rpca] = CR_rPCA_MWF_fitting( mGRE, echoTimes)
 % Code for paper: Blind Source Separation for Myelin Water Fraction Mapping Using Multi-Echo Gradient Echo Imaging
 % Song, Jae Eun; Shin, Jaewook; Lee, Hongpyo; Lee, Ho Joon; Moon, Won Jin; Kim, Dong Hyun
 % 2020
 

% This function takes the code from figure6_invivo.m and turns it into a
% function for running, adapted by Christopher Rowley (2022)

% Requires mGRE to be a complex 4D matrix
% with the 4th dimension being the echoes stacked
% 

% Outputs:
% MWFrpca - myelin water fraction map:
% L1 - is the estimated longer T2* values
% L2 - is the estimated shorter T2* (estimated to be the MW compartment)
% S - sparse noise component


%% Code: 

numEchoes = length(echoTimes);
[x,y,z,~] = size(mGRE);

%% Adjustable fit parameters:

% % They use im_temp to only fit a subset of the z-stack
maxIterations = 100;       
delta =  5e-1 *50;       
delta1 = 5e-1 *50;              
tol_update = 1e-4;   
nlr = [x y z]; 
sth = 0.01;         
scale = 2;           
L_hank = 8;                          
nb = 4;               
nplr = prod(nlr);
N = [x y z numEchoes];

%% Fitting:
tic
% format te to match the size of mGRE
te_3d = repmat(reshape(echoTimes,1,1,1,numEchoes),x,y,z,1);


cmp = exp(1000*te_3d/scale);
L = zeros(N);

disp('starting the fit for "L" '); 

for iz = 1 : floor(N(3)/nlr(3))
    pos(3) = nlr(3) * (iz-1) + 1;
    zp = pos(3) : (pos(3) + nlr(3) - 1);
    
    for ix = 1 : floor(N(1)/nlr(1))
        pos(1) = nlr(1) * (ix-1) + 1;
        xp = pos(1) : (pos(1) + nlr(1) - 1);
        
        for iy = 1 : floor(N(2)/nlr(2))
            pos(2) = nlr(2) * (iy-1) + 1;
            yp = pos(2) : (pos(2) + nlr(2) - 1);
            greC = mGRE(xp,yp,zp,:).*cmp(xp,yp,zp,:);
            qtmp_hankel = genHankel_matrix(reshape(greC ,[nplr,N(4)]), L_hank);
            [W,H] = seminmf(qtmp_hankel, nb);
            sol = W(:,1:1) * H(1:1,:);
            L(xp,yp,zp,:) = reshape(pons_matrix(sol,(N(4)-L_hank+1)),...
                [nlr(1) nlr(2) nlr(3) N(4)]) ./ cmp(xp,yp,zp,:);
        end
    end
end

L2 = mGRE - L;

X(:,:,:,:,1) = L*1;   
X(:,:,:,:,2) = L2*1;          
X(:,:,:,:,3) = 0;           

Z = X.*0;
U = X.*0;

L_hankel1 = L_hank/1;
hsize1 = (numEchoes - L_hankel1+1);
L_hankel2 = L_hank/1;
hsize2 = ( numEchoes - L_hankel2+1);


disp('running hankel matrix section'); 

for t = 1:maxIterations       
    if t == 1
        ru = [1 1 1]-1;
    else
        ru = [randi(nlr(1)) randi(nlr(2)) 1]-1;
    end    
    
    Z = Z.* 0;
    
    for iz = 1 : floor((N(3) - ru(3))/nlr(3))        
        pos(3) = ru(3) + nlr(3) * (iz-1) + 1;
        zp = pos(3) : (pos(3) + nlr(3) - 1);    
        
        for ix = 1 : floor((N(1) - ru(1))/nlr(1))            
            pos(1) = ru(1) + nlr(1) * (ix-1) + 1;
            xp = pos(1) : (pos(1) + nlr(1) - 1);         
            
            for iy = 1 : floor((N(2) - ru(2))/nlr(2))                
                pos(2) = ru(2) + nlr(2) * (iy-1) + 1;
                yp = pos(2) : (pos(2) + nlr(2) - 1);                
                qtmp_hankel = genHankel_matrix(reshape((X(xp,yp,zp,:,1) + 1/delta * U(xp,yp,zp,:,1))...
                    ,[nplr,N(4)]) , L_hankel1);
                [u,s,v] = svd(qtmp_hankel,0);
                Z(xp,yp,zp,:,1) = reshape(pons_matrix(u(:,1:1) * s(1:1,1:1) * v(:,1:1)',hsize1)...
                    ,[nlr(1) nlr(2) nlr(3) N(4)]);
                qtmp_hankel2 = genHankel_matrix(reshape((X(xp,yp,zp,:,2) + 1/delta1 * U(xp,yp,zp,:,2))...
                    ,[nplr,N(4)]) , L_hankel2);
                [u,s,v] = svd(qtmp_hankel2,0);
                Z(xp,yp,zp,:,2) = reshape(pons_matrix(u(:,1:2) * s(1:2,1:2) * v(:,1:2)',hsize2)...
                    ,[nlr(1) nlr(2) nlr(3) N(4)]);
                
            end % for iy
        end % for ix
    end    % for iz
    
    Z(:,:,:,:,3) = shrinkr(X(:,:,:,:,3) + 1/delta * U(:,:,:,:,3),sth);    
    
    if t ~=0
        X_prev = X;
        X(:,:,:,:,1) = ((mGRE - X_prev(:,:,:,:,2) - X_prev(:,:,:,:,3))...
            - U(:,:,:,:,1) + delta * Z(:,:,:,:,1))/ (1 + delta);
        X(:,:,:,:,2) = ((mGRE - X(:,:,:,:,1) - X_prev(:,:,:,:,3))...
            - U(:,:,:,:,2) + delta1 * Z(:,:,:,:,2))/ (1 + delta1);
        X(:,:,:,:,3) = ((mGRE - X(:,:,:,:,1) - X(:,:,:,:,2))...
            - U(:,:,:,:,3) + delta * Z(:,:,:,:,3))/ (1 + delta);
        nlr = randi([2 8],1,2);
        nlr = [nlr, 2];
        nplr = prod(nlr);
    end    
    
    U = U + delta * (X - Z);           
    x_update = 100 * norm(X(:)-X_prev(:)) / norm(X_prev(:));
    
    if x_update < tol_update
        break
    end
    disp( ['Finished iteration:', num2str(t),'. Difference metric is: ', num2str(x_update)])
end % for t

disp('Finished hankel matrix section, almost done!'); 

temp = real(X); temp(isnan(temp)) = 0; temp(isinf(temp)) = 0; temp(temp<0) = 0;
L1_rpca = temp(:,:,:,1,1);
L2_rpca = temp(:,:,:,1,2);
S_rpca = temp(:,:,:,1,3);

MWFrpca = L2_rpca./(L1_rpca+L2_rpca);

% mask to clean up for export:
msk = abs(mGRE(:,:,:,1)); msk(msk<0.1*max(msk(:))) = 0; msk(msk~=0) = 1;

L1_rpca = L1_rpca.*msk;
L2_rpca = L2_rpca.*msk;
S_rpca = S_rpca.*msk;
MWFrpca = MWFrpca.*msk;


disp('Finished!'); 
toc










































