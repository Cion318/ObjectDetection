%==========================================================================
%                                SAVE DATA
%==========================================================================
% The purpose of this function is to save the data created by the different
% functions.
%
% This function creates a table with every given values of the desired data
% and saves it inside an appropriate named excel file.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: data      - dataset which needs to be saved
%           selection - defines what kind of data is being saved
%
%==========================================================================
%                           OUTPUT ARGUMENTS
% Data.xls Excel-Spreadsheet in folder of application with saved data.
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [] = odSaveData(data,selection)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
p = inputParser;
addRequired(p,'data');
addRequired(p,'selection');

parse(p,data,selection);

% Create save folder directory
folder = 'c:/odData';
if ~exist(folder,'dir')
    mkdir(folder);
end
baseFileName = 'Data.xlsx';
fullFileName = fullfile(folder,baseFileName);

%==========================================================================
% Selection 1 = save houghline dataset
if selection == 1
    % Define all columns for save data
    Lines        = {};
    Startpoint_x = {};
    Startpoint_y = {};
    Endpoint_x   = {};
    Endpoint_y   = {};
    Theta        = {};
    Rho          = {};
    Clear        = {};
    
    % Allocate all values to all variables
    for i = 1 : size(data,2)
        Lines(i)        = {['Line' num2str(i)]};
        Startpoint_x(i) = {data(i).point1(1,1)};
        Startpoint_y(i) = {data(i).point1(1,2)};
        Endpoint_x(i)   = {data(i).point2(1,1)};
        Endpoint_y(i)   = {data(i).point2(1,2)};
        Theta(i)        = {data(i).theta};
        Rho(i)          = {data(i).rho};
    end
    
    % Switching from row vector to column vector
    Lines        = Lines.';
    Startpoint_x = Startpoint_x.';
    Startpoint_y = Startpoint_y.';
    Endpoint_x   = Endpoint_x.';
    Endpoint_y   = Endpoint_y.';
    Theta        = Theta.';
    Rho          = Rho.';
    
    % Create Clear cell to remove previous data if necessary
    for i = 1 : (size(data,2)+1)
        Clear(i) = {''};
    end
    
    % Create a table using above data
    T = table(Lines,Startpoint_x,Startpoint_y,...
        Endpoint_x,Endpoint_y,Theta,Rho);
    
    % Write data into Excel file
    writecell(cellstr('All detected Hough-Lines'),...
    fullFileName,'Sheet',1,'Range','A1');

    writetable(T,fullFileName,'Sheet',1,'Range','A3');
    
    % Clear previous data
    for i = (size(data,2)+4) : (size(data,2)+54)
        writecell(Clear,fullFileName,'Sheet',1,'Range',...
            ['A' num2str(i)]);
    end
%==========================================================================
% Selection = 2 save houghcircle dataset    
elseif selection == 2
    % Define all columns for save data
    Circles    = {};
    Midpoint_x = {};
    Midpoint_y = {};
    Radius     = {};
    Clear      = {};
    
    % Allocate all values to all variables
    for i = 1 : size(data,1)
        Circles(i)    = {['Circle ' num2str(i)]};
        Midpoint_x(i) = {data(i,1)};
        Midpoint_y(i) = {data(i,2)};
        Radius(i)     = {data(i,3)};
    end
    
    % Switching from row vector to column vector
    Circles    = Circles.';
    Midpoint_x = Midpoint_x.';
    Midpoint_y = Midpoint_y.';
    Radius     = Radius.';
    
    % Create Clear cell to remove previous data if necessary
    for i = 1 : (size(data,2)+1)
        Clear(i) = {''};
    end
    
    % Create a table using above data
    T = table(Circles,Midpoint_x,Midpoint_y,Radius);
    
    % Write data into Excel file
    writecell(cellstr('All detected Hough-Circles'),...
    fullFileName,'Sheet',2,'Range','A1');
    
    writetable(T,fullFileName,'Sheet',2,'Range','A3');
    
    % Clear previous data
    for i = (size(data,2)+4) : (size(data,2)+54)
        writecell(Clear,fullFileName,'Sheet',1,'Range',...
            ['A' num2str(i)]);
    end
    
%==========================================================================
% Selection = 3 save ransacline dataset
elseif selection == 3
    % Define all columns for save data
    Lines        = {};
    Startpoint_x = {};
    Startpoint_y = {};
    Endpoint_x   = {};
    Endpoint_y   = {};
    Clear        = {};
    
    % Allocate all values to all variables
    for i = 1 : size(data,2)
        Lines(i)        = {['Line ' num2str(i)]};
        Startpoint_x(i) = {data(i).point1(1,1)};
        Startpoint_y(i) = {data(i).point1(1,2)};
        Endpoint_x(i)   = {data(i).point2(1,1)};
        Endpoint_y(i)   = {data(i).point2(1,2)};
    end
    
    % Switching from row vector to column vector
    Lines        = Lines.';
    Startpoint_x = Startpoint_x.';
    Startpoint_y = Startpoint_y.';
    Endpoint_x   = Endpoint_x.';
    Endpoint_y   = Endpoint_y.';
    
    % Create Clear cell to remove previous data if necessary
    for i = 1 : (size(data,2)+1)
        Clear(i) = {''};
    end
    
    % Create a table using above data
    T = table(Lines,Startpoint_x,Startpoint_y,Endpoint_x,Endpoint_y);    
    
    % Write data into Excel file
    writecell(cellstr('All detected Ransac-Lines'),...
    fullFileName,'Sheet',3,'Range','A1');

    writetable(T,fullFileName,'Sheet',3,'Range','A3');
    
    % Clear previous data
    for i = (size(data,2)+4) : (size(data,2)+54)
        writecell(Clear,fullFileName,'Sheet',1,'Range',...
            ['A' num2str(i)]);
    end
    
%==========================================================================
% Selection = 4 save ransaccircle dataset
elseif selection == 4
    % Define all columns for save data
    Circles    = {};
    Midpoint_x = {};
    Midpoint_y = {};
    Radius     = {};
    Clear      = {};
    
    % Allocate all values to all variables
    for i = 1 : size(data,1)
        Circles(i)    = {['Circle ' num2str(i)]};
        Midpoint_x(i) = {data(i,1)};
        Midpoint_y(i) = {data(i,2)};
        Radius(i)     = {data(i,3)};
    end
    
    % Switching from row vector to column vector
    Circles    = Circles.';
    Midpoint_x = Midpoint_x.';
    Midpoint_y = Midpoint_y.';
    Radius     = Radius.';

    % Create Clear cell to remove previous data if necessary
    for i = 1 : (size(data,2)+1)
        Clear(i) = {''};
    end
    
    % Create a table using above data
    T = table(Circles,Midpoint_x,Midpoint_y,Radius);
    
    % Write data into Excel file
    writecell(cellstr('All detected Ransac-Cricles'),...
    fullFileName,'Sheet',4,'Range','A1');

    writetable(T,fullFileName,'Sheet',4,'Range','A3');
    
    % Clear previous data
    for i = (size(data,2)+4) : (size(data,2)+54)
        writecell(Clear,fullFileName,'Sheet',1,'Range',...
            ['A' num2str(i)]);
    end
    
%==========================================================================
% Selection = 5 save templatematching dataset
elseif selection == 5
    % Define all columns for save data and allocate
    Top_Right_Corner_x = {data(1)};
    Top_Right_Corner_y = {data(2)};
    Width              = {data(3)};
    Hight              = {data(4)};
    Angle              = {data(5)};
    Consensus          = {data(6)};
    
    % Create a table using above data
    T = table(Top_Right_Corner_x,Top_Right_Corner_y,Width,Hight,...
        Angle,Consensus);

    % Write data into Excel file
    writecell(cellstr('Detected Template'),...
    fullFileName,'Sheet',5,'Range','A1');

    writetable(T,fullFileName,'Sheet',5,'Range','A3');
    
%==========================================================================
% Selection = 6 save objectdetect dataset
elseif selection == 6
    % Define all columns for save data
    Object  = {};
    Lines   = {};
    Clear   = {};

    % Allocate all values to all variables
    for i = 1 : size(data,2)
        Object(i) = {['Object ' num2str(i)]};
        Lines(i)  = {data(i).Lines};
    end
    
    % Create Clear cell to remove previous data if necessary
    for i = 1 : (size(data,2)+1)
        Clear(i) = {''};
    end
    
    % Switching from row vector to column vector
    Object = Object.';
    Lines  = Lines.';
    
    % Create a table using above data
    T = table(Object,Lines);
    
    % Write data into Excel file

    
    writecell(cellstr(['All detected Objects with line '...
    'coordinates extracted from Hough-Lines']),...
    fullFileName,'Sheet',6,'Range','A1');

    writetable(T,fullFileName,'Sheet',6,'Range','A3');
    
    % Clear previous data
    for i = (size(data,2)+4) : (size(data,2)+54)
        writecell(Clear,fullFileName,'Sheet',1,'Range',...
            ['A' num2str(i)]);
    end
end

