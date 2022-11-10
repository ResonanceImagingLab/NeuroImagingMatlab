function heatscatter3(X, Y, Z, cmap, markersize,numbins, marker, plot_colorbar,  xlab, ylab,zlab, titleSTR,fontSize)

% custom script that builds on heatscatter, to do a 3D scatterplot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% heatscatter3(X, Y, outpath, outname, numbins, markersize, marker, plot_colorbar,  xlab, ylab,zlab, titleSTR)
% mandatory:
%            X                  [x,1] array containing variable X
%            Y                  [y,1] array containing variable Y
%            z                  [z,1] array containing variable Z
%            outpath            path where the output-file should be saved.
%                                leave blank for current working directory
%            outname            name of the output-file. if outname contains
%                                filetype (e.g. png), this type will be used.
%                                Otherwise, a pdf-file will be generated
% optional:
%            numbins            [double], default 50
%                                number if bins used for the
%                                heat3-calculation, thus the coloring
%            markersize         [double], default 10
%                                size of the marker used in the scatter-plot
%            marker             [char], default 'o'
%                                type of the marker used in the scatter-plot
%            plot_colorbar      [double], boolean 0/1, default 1
%                                set whether the colorbar should be plotted
%                                or not
%            xlab               [char], default ''
%                                lable for the x-axis
%            ylab               [char], default ''
%                                lable for the y-axis
%            titleSTR              [char], default ''
%                                title of the figure

% CD Rowley add  
%            cmap               colormap, default is parula 
%          good sample call: heatscatter(X,Y, copper,1,'.')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%% mandatory
    if ~exist('X','var') || isempty(X)
        error('Param X is mandatory! --> EXIT!');
    end
    if ~exist('Y','var') || isempty(Y)
        error('Param Y is mandatory! --> EXIT!');
    end
    if ~exist('Z','var') || isempty(Z)
        error('Param Z is mandatory! --> EXIT!');
    end

    %%%% optional
    if ~exist('cmap','var')
         cmap = parula;
    end
    if ~exist('numbins','var') %|| isempty(numbins)
        numbins = 10;
    end
    if ~exist('markersize','var') || isempty(markersize)
        markersize = 1;
    end
    if ~exist('marker','var') || isempty(marker)
        marker = '.';
    end
    if ~exist('plot_colorbar','var') || isempty(plot_colorbar)
        plot_colorbar = 1;
    end
 
    if ~exist('xlab','var') || isempty(xlab)
        xlab = '';
    end
    if ~exist('ylab','var') || isempty(ylab)
        ylab = '';
    end
    if ~exist('zlab','var') || isempty(zlab)
        zlab = '';
    end
    if ~exist('titleSTR','var') || isempty(titleSTR)
        titleSTR = '';
    end
    
    if ~exist('fontSize','var') || isempty(fontSize)
        fontSize = 20;
    end
    
    [values, centers] = histogram3D([X Y Z], numbins);

    centers_X = centers{1,1};
    centers_Y = centers{1,2};
    centers_Z = centers{1,3};

    binsize_X = abs(centers_X(2) - centers_X(1)) / 2;
    binsize_Y = abs(centers_Y(2) - centers_Y(1)) / 2;
    binsize_Z = abs(centers_Z(2) - centers_Z(1)) / 2;
    bins_X = zeros(numbins, 2);
    bins_Y = zeros(numbins, 2);
    bins_Z = zeros(numbins, 2);

    for i = 1:numbins
        bins_X(i, 1) = centers_X(i) - binsize_X;
        bins_X(i, 2) = centers_X(i) + binsize_X;
        bins_Y(i, 1) = centers_Y(i) - binsize_Y;
        bins_Y(i, 2) = centers_Y(i) + binsize_Y;
        bins_Z(i, 1) = centers_Z(i) - binsize_Z;
        bins_Z(i, 2) = centers_Z(i) + binsize_Z;
    end

    scatter_COL = zeros(length(X), 1);

    onepercent = round(length(X) / 100);
    
    fprintf('Generating colormap...\n');
    
    for i = 1:length(X)

        if (mod(i,onepercent) == 0)
            fprintf('.');
        end            

        last_higher_X = NaN;
        id_X = NaN;

        c_X = X(i);
        last_lower_X = find(c_X >= bins_X(:,1));
        if (~isempty(last_lower_X))
            last_lower_X = last_lower_X(end);
        else
            last_higher_X = find(c_X <= bins_X(:,2));
            if (~isempty(last_higher_X))
                last_higher_X = last_higher_X(1);
            end
        end
        if (~isnan(last_lower_X))
            id_X = last_lower_X;
        else
            if (~isnan(last_higher_X))
                id_X = last_higher_X;
            end
        end

        last_higher_Y = NaN;
        id_Y = NaN;

        c_Y = Y(i);
        last_lower_Y = find(c_Y >= bins_Y(:,1));
        if (~isempty(last_lower_Y))
            last_lower_Y = last_lower_Y(end);
        else
            last_higher_Y = find(c_Y <= bins_Y(:,2));
            if (~isempty(last_higher_Y))
                last_higher_Y = last_higher_Y(1);
            end
        end
        if (~isnan(last_lower_Y))
            id_Y = last_lower_Y;
        else
            if (~isnan(last_higher_Y))
                id_Y = last_higher_Y;
            end
        end

        
     
        last_higher_Z = NaN;
        id_Z = NaN;

        c_Z = Z(i);
        last_lower_Z = find(c_Z >= bins_Z(:,1));
        if (~isempty(last_lower_Z))
            last_lower_Z = last_lower_Z(end);
        else
            last_higher_Z = find(c_Z <= bins_Z(:,2));
            if (~isempty(last_higher_Z))
                last_higher_Z = last_higher_Z(1);
            end
        end
        if (~isnan(last_lower_Z))
            id_Z = last_lower_Z;
        else
            if (~isnan(last_higher_Z))
                id_Z = last_higher_Z;
            end
        end
        
        
        scatter_COL(i) = values(id_X, id_Y, id_Z);
    
    end
    
    fprintf(' Done!\n');
    
    fprintf('Plotting...');
    
    %f = figure();
    scatter3(X, Y,Z, markersize, scatter_COL, marker);
    colormap(cmap);
    if (plot_colorbar)
        colorbar;
    end
    
    
    if (~isempty(xlab))
        xlabel(xlab, 'Fontsize',fontSize);
    end
    if (~isempty(ylab))
        ylabel(ylab, 'Fontsize',fontSize);
    end
    if (~isempty(zlab))
        zlabel(zlab, 'Fontsize',fontSize);
    end
    if (~isempty(titleSTR))
        title(titleSTR, 'Fontsize',fontSize);
    end
    ax = gca; ax.FontSize = fontSize; 
    
    fprintf(' Done!\n');
 