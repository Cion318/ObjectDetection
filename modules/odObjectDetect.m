%==========================================================================
%                           OBJECT-DETECTION
%==========================================================================
% The purpose of this function is to detect Object based on the line and
% circle dataset.
%
% This function uses a variable threshold to identify connections between
% lines from the linedataset. In the next step the function identifies,
% whether every of those connected lines appeary twice. Only when every
% line appeary twice a "closed" shape is being detected.
%
% Example: connected lines: (1 2) (3 2) (3 4) (4 1)
%
%               Line 1
%           +-------------+
%    Line 4 |             | Line 2
%           |             |
%           +-------------+
%               Line 3
%
% Once the dataset has been filterd so that every line appears twice the
% linepairs are being saved in a graph with each value being a node in
% space with a line between them. Each node is then being calculated as a
% part of a component. This component saves the number of nodes that belong
% to it and the value (eg. line 1, line 2 and line 3).
% Lastly the identified componenty are being marked in the image using
% different colors for differente types of objects. At this point the
% circle dataset is being used to draw the circles in the image.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: LDS  - linedataset with start- and endpoints of lines
%           CDS  - circledataset with middlepoint coordinates and radi
%           GRAY - grayscale image gray to print objects onto
% Optional: All of the following arguments are Name-Value-Pairs.
%
% 'threshold' - positive value >0
%==========================================================================
%                           OUTPUT ARGUMENTS
% hLineDataSet - 1xN struct
%
% Each N represents a line and has values for Point 1, Point 2, theta and
% rho saved.
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================


function [shapes] = odObjectDetect(LDS,CDS,GRAY,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defThreshold = 7;      % Default threshold to accept connected lines

p = inputParser;
addRequired(p,'LDS');
addRequired(p,'CDS');
addRequired(p,'GRAY');
addParameter(p,'threshold',defThreshold,@(x) mod(x,1)==0 && (x>0));

parse(p,LDS,CDS,GRAY,varargin{:});

% Assign name-value arguments to used variables
tVal = p.Results.threshold;

shapes = struct('Lines',{}); % Outputparameter with detected objects
%==========================================================================

% Code to locate coherent lines in the LDS
conLines = [];      % Matrix with all connected lines

for i = 1 : size(LDS,2)
    for k = 1 : size(LDS,2)
        % Makes sure to not compare the same line against itself
        if k ~= i
            % Calculate distance between every SP-EP combination
            d1=sqrt(sum(abs(LDS(i).point1-LDS(k).point1)).^2);
            d2=sqrt(sum(abs(LDS(i).point1-LDS(k).point2)).^2);
            d3=sqrt(sum(abs(LDS(i).point2-LDS(k).point1)).^2);
            d4=sqrt(sum(abs(LDS(i).point2-LDS(k).point2)).^2);
            % If distance < threshold lines building a corner
            if (d1<tVal) || (d2<tVal) || (d3<tVal) || (d4<tVal)
                % Because of the for loops lines will be double saved. To
                % remove them later using the unique function lines have to
                % be saved in the same order.
                if i <= k
                    conLines = [conLines; i k];
                else
                    conLines = [conLines; k i];
                end
            end
        end
    end
end
% Remove double entries in connected line data
conLines = unique(conLines,'rows');
%==========================================================================

% Check every line for appearing twice in the connected lines dataset
cDbl = unique(conLines);           % Save every available line
counts = histc(conLines(:),cDbl);  % Chech how many times each line appears

% This code only works for shapes which have a maximum of 2 lines in a node
% and will throw out errors when performing it with 3 or more lines.
if any(counts(:) > 2)
    return
end

% While not every appears twice reapeat process to filter out values which
% do not appear twice.
while any(counts(:) ~= 2)
    % Loop through every connected line and check whether the counts value
    % for that line is unequal 2. Then find the corresponding value in cDbl
    % variable and use it to find the location of the line that does not
    % appear twice in conLines.
    for i = 1 : size(conLines,1)
        if counts(i) ~= 2
            x = find(conLines==cDbl(i));
            % If find location exceeds size of conLines the value has to be
            % recalculated by removing the size of conLines from it.
            if x > size(conLines,1)
                x = x - size(conLines,1);
            end
            % Remove the line that does not appear twice in conLines
            conLines(x,:) = [];
            break
        end
    end
    % Recalculate cDbl and counts with new conLines and repeat process.
    cDbl = unique(conLines);
    counts = histc(conLines(:),cDbl);
end


% Create shaGraph using the linepairs of conLines as nodes
shaGraph = graph(conLines(:,1),conLines(:,2));
% Calculate the connections and the size of the connected components
[bins, binsize] = conncomp(shaGraph,'OutputForm', 'cell');

counter = 0;    % Counter to count number of objects

% Loop through every foung bin (component) and check whether number of
% lines in bin are greated than 2 (first object (triangle) needs 3
% connected lines). If an object has been found increase the counter by 1
% and save the bin data (all lines that are part of the object) into the
% shape struct at position of the counter.
for i = 1 : size(bins,2)
    if binsize(i) > 2
        counter = counter + 1;
        shapes(counter).Lines = bins{i};
    end
end



% Plot every detected object with their appropiate lines with different
% colors for different types of objects and name them.
imshow(GRAY); hold on;
for i = 1 : size(shapes,2)
    if size(shapes(i).Lines,2) == 3
        
        for j = 1 : 3
            xy = [LDS(shapes(i).Lines(1,j)).point1;...
                LDS(shapes(i).Lines(1,j)).point2];
            % Plot triangle lines
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','g');
        end
        x = LDS(shapes(i).Lines(1,1)).point1(1,1) + 5;
        y = LDS(shapes(i).Lines(1,2)).point1(1,2) + 5;
        str = 'Triangle';
        text(x,y,str,'Fontweight','bold');
        
    elseif size(shapes(i).Lines,2) == 4
        
        for j = 1 : 4
            xy = [LDS(shapes(i).Lines(1,j)).point1;...
                LDS(shapes(i).Lines(1,j)).point2];
            % Plot quadrangle lines
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','r');
        end
        x = LDS(shapes(i).Lines(1,1)).point1(1,1) + 5;
        y = LDS(shapes(i).Lines(1,2)).point1(1,2) + 5;
        str = 'Quadrangle';
        text(x,y,str,'Fontweight','bold');
        
    else
        
        for j = 1 : size(shapes(i).Lines,2)
            xy = [LDS(shapes(i).Lines(1,j)).point1;...
                LDS(shapes(i).Lines(1,j)).point2];
            % Plot quadrangle lines
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','c');
        end
        x = LDS(shapes(i).Lines(1,1)).point1(1,1) + 5;
        y = LDS(shapes(i).Lines(1,2)).point1(1,2) + 5;
        str = [num2str(size(shapes(i).Lines,2)),'-sided Shape'];
        text(x,y,join(str),'Fontweight','bold');
    end
end

if (size(CDS,2) >= 3)
    viscircles(CDS(:,1:2), CDS(:,3),'Color','b');
    str = 'Circle';
    text(CDS(:,1)-18, CDS(:,2),str,'Fontweight','bold');
end
hold off;