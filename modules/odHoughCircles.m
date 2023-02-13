%==========================================================================
%                          HOUGH-CIRCLE-TRANSFORM
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
% 'minRadius' - positive integer  >= 10
% 'maxRadius' - positive integer  >= 10 and >minRadius
%==========================================================================
%                           OUTPUT ARGUMENTS
% hCircleDataSet - Mx3 Matrix with the following information:
% 1. column: x-coordinate midpoint | 2. column: y:coordinate midpoint
% 3. column: radius
% 
% Each row represents an identified circle.
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [hCircleDataSet] = odHoughCircles(BW,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defMinRad = 10;     % Default minimum value for the radius
defMaxRad = 50;     % Default maximum value for the radius

p = inputParser;
addRequired(p,'BW');
addParameter(p,'minRadius',defMinRad,@(x) mod(x,1)==0 && (x>=10));
addParameter(p,'maxRadius',defMaxRad,@(x) mod(x,1)==0 && (x>=10));

parse(p,BW,varargin{:});

% Assign name-value arguments to used variables
% Check whether maxRadius is indeed bigger than minRadius else swap them.
if p.Results.minRadius <= p.Results.maxRadius
    minRad = p.Results.minRadius;
    maxRad = p.Results.maxRadius;
else
    minRad = p.Results.maxRadius;
    maxRad = p.Results.minRadius;
end


hCircleDataSet = [];    % Outputparameter with saved circle data
%==========================================================================

% Create tempRad to reduce radius range and make algorithm work smoother
% and more accurate. (Rule: maxRad < 3*minRad && (maxRad-minRad) < 100)
tempRad = minRad + 20;
while (minRad < maxRad)
    % Locate all circles inside the radius range.
    [centers, radii] = imfindcircles(BW,[minRad tempRad-1], ...
        'ObjectPolarity','bright');
    
    % Save coordinates and radius of every detected circle.
    hCircleDataSet = [hCircleDataSet; centers radii];
    
    % To keep accuracy solid search in intervalls of 10
    minRad  = minRad  + 20;
    tempRad = tempRad + 20;
end
