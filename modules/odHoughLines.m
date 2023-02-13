%==========================================================================
%                           HOUGH-LINE-TRANSFORM
%==========================================================================
% The purpose of this function is to locate hLineDataSet in a binary image.
% 
% This function uses the standard hough-transform to open up a hough space
% and identify lines as a matter of frequency or brightness in this space.
% For this the hLineDataSet are being described with their normal form.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: BW - logical MxN matrix (binary image)
% Optional: All of the following arguments are Name-Value-Pairs.
%
% 'peaks'     - positive integer >0
% 'threshold' - positive value >0 and <=1
% 'fillgap'   - positive value >=0
% 'minlength' - positive value >=0
%==========================================================================
%                           OUTPUT ARGUMENTS
% hLineDataSet - 1xN struct
% 
% Each N represents a line and has values for Point 1, Point 2, theta and 
% rho saved.
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================
function [hLineDataSet] = odHoughLines(BW,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defPNum = 5;      % Default number of peaks to look out for
defTNum = 0.5;    % Default threshold value to consider a value a peak
defGNum = 20;     % Default gap to be closed for two lines with same HT-bin
defLNum = 40;     % Default min. line length. Shorter lines are discarded

p = inputParser;
addRequired(p,'BW',@islogical);
addParameter(p,'peaks',defPNum,@(x) mod(x,1)==0 && (x>0));
addParameter(p,'threshold',defTNum,@(x) (x>=0) && (x<=1));
addParameter(p,'fillgap',defGNum,@(x) (x>=0));
addParameter(p,'minlength',defLNum,@(x) (x>=0));

parse(p,BW,varargin{:});

% Assign name-value arguments to used variables
pNum = p.Results.peaks;
tNum = p.Results.threshold;
gNum = p.Results.fillgap;
lNum = p.Results.minlength;


%==========================================================================

% Transformation of binary image into hough-space
% H = Hough-space, T = angle theta, R = distance from origin to line rho
[H,T,R] = hough(BW);

% Identify the biggest peaks (brightest spots in hough-space)
P = houghpeaks(H, pNum, 'threshold', ceil(tNum*max(H(:))));

% Identify the hough-lines
hLineDataSet = houghlines(BW,T,R,P,'Fillgap',gNum,'MinLength',lNum);



LDS = hLineDataSet; % LineDataSet (short variable name for following code)

loopBreakCheck = true;  % Variable to start loop

while loopBreakCheck == true
    loopBreakCheck = false; % Loop will terminate if nothing is found
    
    % Check through every possible line combination in LDS
    for i=1:size(LDS,2)
        for k=1:size(LDS,2)
            % If current selected lines are not the exact same
            if i~=k
                % Check whether the length difference between both lines is
                % under 15 and the angle difference is under 10 to find
                % lines that possibly were wrongfully detected or are too
                % similar to each other.
                if abs(LDS(i).rho - LDS(k).rho) < 15 && ...
                        abs(LDS(i).theta - LDS(k).theta) < 10
                    % Run the odIntersect function to check whether the
                    % lines have an intersection point and in case they do
                    % calculate both line lengths.
                    if odIntersect(LDS(i).point1, LDS(i).point2, ...
                            LDS(k).point1, LDS(k).point2)
                        lenI = sqrt((LDS(i).point1(1,1) - ...
                            LDS(i).point2(1,1))^2 + ...
                            (LDS(i).point1(1,2) - ...
                            LDS(i).point2(1,2))^2);
                        
                        lenK = sqrt((LDS(k).point1(1,1) - ...
                            LDS(k).point2(1,1))^2 + ...
                            (LDS(k).point1(1,2) - ...
                            LDS(k).point2(1,2))^2);
                        
                        % Remove the shorter line from the LDS
                        % Loop check will be set back to true to start
                        % another run, because not every line might have
                        % been run through.
                        if lenI > lenK
                            LDS(k) = [];
                            loopBreakCheck = true;
                        else
                            LDS(i) = [];
                            loopBreakCheck = true;
                        end
                    end
                end
            end
            % Break out of first and second for loop one a line has been
            % deleted to start a new for loop search with the new number of
            % rows in LDS.
            if loopBreakCheck == true
                break
            end
        end
        if loopBreakCheck == true
            break
        end
    end
end

hLineDataSet = LDS; % Pass LDS back to hLineDataSet to output correct data.