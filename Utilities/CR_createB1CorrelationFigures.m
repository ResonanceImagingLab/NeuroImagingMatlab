function CR_createB1CorrelationFigures( b1, input1N0B1correction, input2WithCor, inputText   )

% This code generates two plots:
% 1. is a correlation plot between input1 and input2
% 2. Bland-Altman plot


% inputText is a structure that holds the following fields
% inputText.input1Label = 'input1';
% inputText.input2Label = 'input2';
% inputText.BAxLabel = 'Average of Two Methods'; % customize if you want it to be different!
% inputText.BAyLabel = ['Difference Between ',inputText.input1Label, ' and ', inputText.input2Label]; % customize if you want it to be different!
% inputText.outputFigureName = 'Filename'; % optional field if you want the figure saved

b1 = double(b1);
input1N0B1correction = double(input1N0B1correction);
input2WithCor = double(input2WithCor);


% First plot is correlation between two dataset
[FitInput1Input2, gof, ~] = fit( b1, input1N0B1correction, 'poly1');
x_val = linspace(0, max(b1),25) ;
fit_calc = FitInput1Input2(x_val);
fitvals = coeffvalues(FitInput1Input2);    

% We want the equation
if fitvals(2) < 0
    caption = sprintf('y = %.2g*x %.2g', fitvals(1), fitvals(2));
else
    caption = sprintf('y = %.2g*x +%.2g', fitvals(1), fitvals(2)); % include addition sign
end
caption2 = sprintf('R^2 = %.2g', gof.rsquare);

textClr = [0,0,0];

figure;
    subplot(1, 2 ,1)
    heatscatter(b1, input1N0B1correction, spring, 20)
    hold on
    plot(x_val,fit_calc,'LineWidth',2, 'Color',[0,0.2,0.8])
    
    xlim([min(b1)-min(b1)*0.02 max(b1)+0.02*max(b1)])
    ylim([min(input1N0B1correction)-min(input1N0B1correction)*0.02 max(input1N0B1correction+0.02*max(input1N0B1correction))])
    
    ax = gca;
    ax.FontSize = 18; 
    xlabel( 'Relative B_1 (p.u.)' , 'FontSize', 18);%, 'FontWeight', 'bold')
    ylabel(inputText.input1Label , 'FontSize', 18);%, 'FontWeight', 'bold')
    title('Without B_1 Correction' , 'FontSize', 18);%, 'FontWeight', 'bold')
    colorbar('off')
    % Add text to the figure
    text(min(b1)*1.02, max(input1N0B1correction)*0.96, caption, 'FontSize', 16, 'Color', textClr,'fontweight', 'bold');
    text(min(b1)*1.02, max(input1N0B1correction)*0.87, caption2, 'FontSize', 16, 'Color', textClr,'fontweight', 'bold');
    
   
    % Second plot with B1 corrected data
    [FitInput1Input2, gof, ~] = fit( b1, input2WithCor, 'poly1');
    x_val = linspace(0, max(b1),25) ;
    fit_calc = FitInput1Input2(x_val);
    fitvals = coeffvalues(FitInput1Input2);    
if fitvals(2) < 0
    caption = sprintf('y = %.2g*x %.2g', fitvals(1), fitvals(2));
else
    caption = sprintf('y = %.2g*x +%.2g', fitvals(1), fitvals(2)); % include addition sign
end
caption2 = sprintf('R^2 = %.2g', gof.rsquare);


    subplot(1, 2 ,2)
    heatscatter(b1 ,input2WithCor, spring, 20)
    hold on
    plot(x_val,fit_calc,'LineWidth',2, 'Color',[0,0.2,0.8])
   
    xlim([min(b1)-min(b1)*0.02 max(b1)+0.02*max(b1)])
    ylim([min(input1N0B1correction)-min(input1N0B1correction)*0.02 max(input1N0B1correction+0.02*max(input1N0B1correction))]) % same y limit for comparison
    ax = gca;
    ax.FontSize = 18; 
    xlabel( 'Relative B_1 (p.u.)' , 'FontSize', 18);%, 'FontWeight', 'bold')
    ylabel(inputText.input1Label , 'FontSize', 18);%, 'FontWeight', 'bold')
    title('With B_1 Correction' , 'FontSize', 18);%, 'FontWeight', 'bold')
    colorbar('off')
    set(gcf,'position',[200,400,1000,400])  
     % Add text to the figure
    text(min(b1)*1.02, max(input1N0B1correction)*0.96, caption, 'FontSize', 16, 'Color', textClr,'fontweight', 'bold');
    text(min(b1)*1.02, max(input1N0B1correction)*0.87, caption2, 'FontSize', 16, 'Color', textClr,'fontweight', 'bold');
    
    
    
    % If output name is provided, save the figure
if isfield(inputText, 'outputFigureName')
    saveas( gcf, inputText.outputFigureName )

end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    