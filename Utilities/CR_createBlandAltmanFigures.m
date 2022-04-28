function CR_createBlandAltmanFigures( input1, input2, inputText, ylimVals   )

% This code generates two plots:
% 1. is a correlation plot between input1 and input2
% 2. Bland-Altman plot


% inputText is a structure that holds the following fields
% inputText.input1Label = 'input1';
% inputText.input2Label = 'input2';
% inputText.BAxLabel = 'Average of Two Methods'; % customize if you want it to be different!
% inputText.BAyLabel = ['Difference Between ',inputText.input1Label, ' and ', inputText.input2Label]; % customize if you want it to be different!
% inputText.outputFigureName = 'Filename'; % optional field if you want the figure saved
% ylimVals -> limits for Bland altman plot. Put '[]' if you don't care what
% it is. Might want this for comparing across different BA plots.

input1 = double(input1);
input2 = double(input2);


if ~isfield(inputText, 'BAxLabel')
    inputText.BAxLabel = 'Average of Two Methods';
end
if ~isfield(inputText, 'BAyLabel')
    inputText.BAyLabel = ['Difference Between ',inputText.input1Label, ' and ', inputText.input2Label];
end

if ~isempty(ylimVals)
    setYlim = 1;
else
    setYlim = 0;
end
    

% First plot is correlation between two dataset
FitInput1Input2 = fit( input1, input2, 'poly1');
x_val = linspace(0, max(input1),25) ;
fit_calc = FitInput1Input2(x_val);

figure;
    subplot(1, 2 ,1)
    heatscatter(input1,input2, spring, 20)
    hold on
    plot(x_val,fit_calc,'LineWidth',2,'Color',[0,0.2,0.8])
    hline = refline(1,0);
    hline.Color = [0,0,0];
    hline.LineStyle = '--';
    hline.LineWidth = 2;
    
    
    ylim([min(input2)-min(input2)*0.02 max(input2)+0.02*max(input2)])
    ax = gca;
    ax.FontSize = 18; 
    xlabel( inputText.input1Label , 'FontSize', 18)%, 'FontWeight', 'bold')
    ylabel(inputText.input2Label , 'FontSize', 18)%, 'FontWeight', 'bold')
    % Format X axis
    lowerX = round(min(input1,[],'omitnan')-min(input1,[],'omitnan')*0.02 , 2,'significant') ;
    upperX = round(max(input1,[],'omitnan')+0.02*max(input1,[],'omitnan'), 2,'significant');
    midX = (lowerX + upperX)/2;
    xlim([lowerX upperX])
    xticks([lowerX  midX upperX ])
        
    t = title('Correlation' , 'FontSize', 18, 'FontWeight', 'bold'); % left justify incase of y-axis scaling
    set(t, 'horizontalAlignment', 'right');
    set(t, 'units', 'normalized');
    h1 = get(t, 'position');
    set(t, 'position', [1 h1(2) h1(3)])
    
    colorbar('off')
    legend('Data','Fit Line', 'Unity Line','location','best', 'FontSize', 12)
    set(gcf,'position',[200,400,1000,400])

%% Second Plot is the Bland Altmann plot - SINGLE CODE

BA_yval = input2 - input1;
BA_xval = (input1 + input2)/2;
BA_std = nanstd(BA_yval);
BA_lineshift = 1.96*BA_std;
BA_mean = nanmean(BA_yval);

subplot(1,2,2)
    heatscatter(BA_xval,BA_yval, spring,20)
    hold on
    % add lines
    % Lower line
    hline = refline(0,BA_mean - BA_lineshift);
    hline.Color = [0,0.2,0.8];
    hline.LineStyle = '--';
    hline.LineWidth = 2;
    
    % Mean line
    hline = refline(0,BA_mean);
    hline.Color = [0,0,0];
    hline.LineStyle = '-';
    hline.LineWidth = 2;
    
    % Upper line
    hline = refline(0,BA_mean + BA_lineshift);
    hline.Color = [0,0.2,0.8];
    hline.LineStyle = '--';
    hline.LineWidth = 2;
    
    %ylim([min(BA_yval)*0.98 max(BA_yval)*1.02])
    ylim([BA_mean-2*BA_lineshift BA_mean+2*BA_lineshift])
    ax = gca;
    ax.FontSize = 18; 
    xlabel( inputText.BAxLabel, 'FontSize', 18)%, 'FontWeight', 'bold')
    ylabel( inputText.BAyLabel, 'FontSize', 18)%, 'FontWeight', 'bold')
    colorbar('off')
        % Format X axis
    lowerX = round(min(BA_xval,[],'omitnan')*0.98 , 2,'significant') ;
    upperX = round(max(BA_xval,[],'omitnan')*1.02, 2,'significant');
    midX = (lowerX + upperX)/2;
    xlim([lowerX upperX])
    xticks([lowerX  midX upperX ])
    if setYlim
        ylim( ylimVals);
    end
    t = title('Bland-Altman' , 'FontSize', 18, 'FontWeight', 'bold'); % left justify incase of y-axis scaling
    set(t, 'horizontalAlignment', 'right');
    set(t, 'units', 'normalized');
    h1 = get(t, 'position');
    set(t, 'position', [1 h1(2) h1(3)])
    
    caption1 = strcat('-1.96SD =',num2str(BA_mean - BA_lineshift, '%.2g'));
    caption2 = strcat('+1.96SD =',num2str(BA_mean + BA_lineshift, '%.2g') ); % , '(+1.96SD)'
    caption3 = strcat('Mean =',num2str(BA_mean, '%.2g'));
    
    xlocText = min(BA_xval)*0.98 + 0.01*min(BA_xval)*0.98;
    text( xlocText, BA_mean - BA_lineshift+(0.15*BA_lineshift), caption1, 'FontSize', 16,'FontWeight','bold');
    text( xlocText, BA_mean + BA_lineshift+(0.15*BA_lineshift), caption2, 'FontSize', 16,'FontWeight','bold');
    text( xlocText, BA_mean + (0.15*BA_lineshift), caption3, 'FontSize', 16,'FontWeight','bold');
    
    
% If output name is provided, save the figure
if isfield(inputText, 'outputFigureName')
    saveas( gcf, inputText.outputFigureName )

end
    
    