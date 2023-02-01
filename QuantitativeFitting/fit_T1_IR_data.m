function T1 = fit_T1_IR_data(img, TI, mask)

% I keep getting issues the qMRlab code, so lets adapt it.
% Currently assumes 2D


% Fit to Barral Model: a+b*exp(-TI/T1)
% Assume magnitude only data. Complex data is probably better handled by
% qMRlab

% fitting options
st = [  600     -1000      500 ]; % starting point
lb = [ 0.0001   -10000  0.0001 ]; % lower bound
ub = [  5000       0     10000 ]; % upper bound

opts = fitoptions( 'Method', 'NonlinearLeastSquares','Lower',lb,'Upper',ub, 'Start', st);
opts.Robust = 'Bisquare';
myfittype = fittype('(a+b*exp(-TI/T1))^2','dependent', {'img'}, 'independent',{'TI'},'coefficients', {'a','b','T1'});

% Have issue of where the flip point is from negative to positive
% We could just square the equation and fit it? 
[x,y,~] = size(img);

if max(TI) < 50
    TI = TI *1000;
end

TI = TI(:); % ensure it is column

T1 = zeros(x,y);

img = img.^2;

for i = 1:x
    for j = 1:y
        if mask(i,j) > 0 % Need min 5 points for fit

            img_voxel = squeeze(img(i,j,:)); % squeeze necessary to reformat to 1D array
            
            % fit     
            fitT1 = fit( TI, img_voxel, myfittype, opts ); % Add in upper and lower bounds to help with fit
            T1coef = coeffvalues(fitT1);

            T1(i,j) = T1coef(3);

        end
     end
end
