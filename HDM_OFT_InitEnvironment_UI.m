function o_Env_UI=HDM_OFT_InitEnvironment_UI...
    (i_OutPlotColourDir, ...
    i_OutPlotBWDir, ...
    i_SavePlot, ...
    i_ExportPlot, ...
    i_BW)

    global globalOFT_Env_UI;

    if(isempty(globalOFT_Env_UI))

    l_position = [ 50 50 700 700 ];
    set(0, 'DefaultFigurePosition', l_position);


    % Change default axes fonts.
    set(0,'DefaultAxesFontName', 'Arial');
    set(0,'DefaultAxesFontSize', 10);

    % Change default text fonts.
    set(0,'DefaultTextFontname', 'Arial');
    set(0,'DefaultTextFontSize', 10);

    %set(0,'DefaultAxesLineStyleOrder','-|--|:|-.|.');

    % dco=get(0,'DefaultAxesColorOrder');
    set(0,...
        'DefaultAxesLineStyleOrder','-|--|-.|-..|.|+|:|o',...
        'DefaultAxesColorOrder',...
    ...%    [0.0 0.0 0.0;0.45 0.45 0.45;0.7 0.7 0.7]); % grayish
            [0, 0, 0;... %y m cmy ordered
            0.3, 0.3, 0.3;...
            1, 0, 0;...
            0, 1, 0;...
            0, 0, 1;...
            1, 0, 1;...
            0, 1, 1]);

    %         [0, 0, 1;... %rgb cmy ordered
    %         0, 1, 0;...
    %         1, 0, 0;...
    %         1, 1, 0;...
    %         1, 0, 1;...
    %         0, 1, 1;...
    %         0.5, 0.5, 0.5]);    

    l_Env_UI = HDM_OFT_Environment_UI();

    l_Env_UI.OFT_PlotColourDir = i_OutPlotColourDir;
    l_Env_UI.OFT_PlotBWDir = i_OutPlotBWDir;
    
    l_Env_UI.OFT_SavePlot = i_SavePlot;
    l_Env_UI.OFT_ExportPlotToClipBoard = i_ExportPlot;
    
    l_Env_UI.OFT_BW = i_BW;

    o_Env_UI=l_Env_UI;
    globalOFT_Env_UI=l_Env_UI;

    %clear classes %commented out due to in arg preserving
    delete(findall(0,'Type','figure'));

    else
        o_Env_UI=globalOFT_Env_UI;    
    end

end
        

        
