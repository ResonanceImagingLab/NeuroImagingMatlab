function [T1mapL, T1mapS, resmap] = fit_biexp_T1_IR_data(img, TI)

% I keep getting issues the qMRlab code, so lets adapt it.
% Currently assumes 2D


% Fit to modified Barral Model: 
% General model:
%      val(x) = a+b*exp(-x/S) + c*exp(-x/L)

% We have the issue with magnitude data where each signal could be flipped
% Find index of inflection. Then you either have to flip to the left , ON, or to
% the right of that. Try both and take the one with the lowest residuals


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For now, we assume the data has been stacked 2D, each column corresponds
% to an inversion time TI.

[x,y] = size(img);

if y ~= length(TI)
    error('Mismatch between TIs provided and number of images')
end

% if ~exist("method","var") 
%     disp("Assuming magnitude data, if complex, please enter 'complex' as the method")
%     method = 'magnitude';
% end
% 
% if strcmp( method, 'magnitude')
%     % Find index of column closest to 0
%     [~, minInd] = min(img,[],2);
%     
%     T1vector = zeros(x,3);
%     sse = zeros(x,3);
%     
%     %% Start with left
%     invImg = img;
%     for i = 1:x
%         idx = minInd(i)-1;
%         if idx > 0
%             invImg(i, 1:idx) = -1*invImg(i, 1:idx);
%         end
%     end
%         
%     % Fit T1 and get residuals
%     output = T1_fit_function(invImg, TI);
%     T1vector(:,1) = output(:,1);
%     sse(:,1) = output(:,4);
%     
%     
%     %% Center
%     invImg = img;
%     for i = 1:x
%         idx = minInd(i);
%         invImg(i, 1:idx) = -1*invImg(i, 1:idx);
%     end
%         
%     % Fit T1 and get residuals
%     output = T1_fit_function(invImg, TI);
%     T1vector(:,2) = output(:,1);
%     sse(:,2) = output(:,4);
%     
%     
%     %% Last, to the right
%     invImg = img;
%     for i = 1:x
%         idx = minInd(i)+1;
%         if idx <= y % check that we aren't outside 
%             invImg(i, 1:idx) = -1*invImg(i, 1:idx);
%         end
%     end
%         
%     % Fit T1 and get residuals
%     output = T1_fit_function(invImg, TI);
%     T1vector(:,3) = output(:,1);
%     sse(:,3) = output(:,4);
%     
%     %% Take the one with the lowest residuals
%     [~, minInd2] = min(abs(sse),[],2);
%     
%     resmap = zeros(x,1);
%     T1map = zeros(x,1);
%     
%     for i = 1:x
%         idx = minInd2(i);
%         resmap(i) = sse(i,idx);
%         T1map(i) = T1vector(i, idx);
%     end
% 
% else 
% With complex data, we assume that the Z-magnetization is flipped to 
% negative already

    % [T1L, T1S, a, b, c, resid]
    output = biexp_T1_fit_function(img, TI);
    T1mapL = output(:,1);
    T1mapS = output(:,2);
    resmap = output(:,6);

end
























