%==========================================================================
%                       CIRCLEDETECTION USING RANSAC
%==========================================================================
% The purpose of this function is to identify circles in a binary image and
% extract the middlepoint by their x/y-coordinates and the radius of each
% circle.
%
% Two variations are given to detect circles in binary image.
% The first method uses a predefined number of iterations to find the best
% fit for the available dataset and will definitely locate coordinates for
% a detected circle after that set number.
%
% The second method will also find the best fit after a predefined number
% of iterations but will check the result to actually resemble a circle by
% taking into consideration that a minimum number of pixels have to be in
% the inlierdataset with that minimum being calculated with the radius of
% sadi circle.
% To detect multiple circles or in case of method 2 even one circle
% multiple runs are required.
%
% In terms of speed both need the same time when it comes to running the
% procedure once. For multiple circles the second method is faster IF the
% first few circles are being detected in the first runs, due to the
% removal of datapoints after detection.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: BW - logical MxN matrix (binary image)
% Optional: All of the following arguments are Name-Value-Pairs.
%
% 'runs'      - positive integer (number of runs)
% 'iterations'- positive integer (number of iterations)
% 'threshold' - positive value greater or equal 0
%               determines if pixel is an inlier 
% 'method'    - 1 or 2 for method selection (1/2)
%==========================================================================
%                           OUTPUT ARGUMENTS
% rCircleDataSet - Mx3 matrix with midpoint coordinates and radius
% 1. column: x-coordinate | 2. column: y-Koordinate | 3. column: radius
%
% For every point in lineDataSet the z-coordinate is equal to 0. In case it
% is needed it has to be manually added. Each row equals one circle.
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [rCircleDataSet] = odRansacCircles(BW,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defMaxRuns       = 1;       % Max. number of runs
defMaxIterations = 1000;    % Max. number of iterations
defThreshold     = 1.5;     % Threshold for "Inlier"/"Outlier" detection
defMethod        = 2;       % Selected method to be used

p = inputParser;
addRequired(p,'BW',@islogical);
addParameter(p,'runs',defMaxRuns,@(x) mod(x,1)==0 && (x>0));
addParameter(p,'iterations',defMaxIterations,@(x) mod(x,1)==0 && (x>0));
addParameter(p,'threshold',defThreshold,@(x) (x>=0));
addParameter(p,'method',defMethod,@(x) mod(x,1)==0 && (x<3) && (x>0));

parse(p,BW,varargin{:});

% Assign name-value arguments to used variables
maxRuns       = p.Results.runs;
maxIterations = p.Results.iterations;
threshold     = p.Results.threshold;
method        = p.Results.method;
 

rCircleDataSet   = []; % Outpuparameter with Circleinformationen
dataSet = [];         % x/y/z-Koordinaten jedes weißen Pixels aus BW
%==========================================================================

% Loop to save all white pixels from the image BW into a dataset (Mx3) with
% Columns representing x,y,z and rows representing each pixel. z-value is 
% being set to 0 for later calculations.
for i = 1 : size(BW,1)
    for k = 1 : size(BW,2)
        if BW(i,k) == 1
            dataSet = [dataSet; k i 0]; % z-Value = 0
        end
    end
end

dataSetSave = dataSet; % Keep an unchanged version of dataset


% Execute the whole procedure until either less than 5% of the original 
% pixels remain or maxRuns is reached.
count = 0;    % Counter for the number of runs
while (size(dataSet,1) / size(dataSetSave,1)) > 0.05 && count < maxRuns
    count = count + 1;
    bInDataSet = [];            % Empty best inlierdataset
    

    for itCount = 1 : maxIterations

        inlierDataSet = [];                 % Empty Inlierdataset
        samplePts = datasample(dataSet,3);  % Select 3 random pixels

        sP1 = samplePts(1,1:2);     % Allocate pixel 1 (ohne z-Wert)
        sP2 = samplePts(2,1:2);     % Allocate pixel 2 (ohne z-Wert)
        sP3 = samplePts(3,1:2);     % Allocate pixel 3 (ohne z-Wert)

        % Calculate slopes for every possible point combination
        m12 = (sP2(1,2) - sP1(1,2)) / (sP2(1,1) - sP1(1,1));
        m13 = (sP3(1,2) - sP1(1,2)) / (sP3(1,1) - sP1(1,1));
        m23 = (sP3(1,2) - sP2(1,2)) / (sP3(1,1) - sP2(1,1));

        % Check if selected points are colinear (colinear -> radius = INF)
        if (m12 == m23) || (m23 == m13) || (m12 == m13)
            continue
        end
        
% Check if slope is unequal to 0 because further steps require to calculate
% the reciprocal value of the slope (0 -> INF). Allocate the points so that
% points 1 and 2 are the ones where the slope is unequal 0.
        if m12 ~= 0
            uP1 = sP1;
            uP2 = sP2;
            uP3 = sP3;
        elseif m13 ~= 0
            uP1 = sP1;
            uP2 = sP3;
            uP3 = sP2;
        elseif m23 ~= 0
            uP1 = sP2;
            uP2 = sP3;
            uP3 = sP1;
        end
        
% To calculate a circle with 3 points one first needs to identify the perp-
% endicular bisector of 2 of those points. Every point on this lane has the
% same distance to P1 and P2. To calculate it the following formulas are
% being used:
%
% Slope:             m = -1 / ((P2y-P1y) / (P2x-P1x))
% Midpoint:          x = (P2x + P1x)/2    y = (P2y + P1y)/2
% y-axis sector:     b = y - m * x

        % Slope, midpoint, y-axis sector of the perpendicular bisector
        m_P  = -1 / ((uP2(1,2) - uP1(1,2))/(uP2(1,1) - uP1(1,1)));
        mp_P = (uP1 + uP2)/2;
        b_P  = mp_P(1,2) - m_P * mp_P(1,1);

% The distance of P3 to the center midpoint is the same as P2 or P1 to the
% midpoint. Solving those equations results in the following formulas to
% calculate the midpoint x- and y-values.
%
% Formel: x = (P3x^2 + P3y^2 - P1x^2 - P1y^2 + 2*b*(P1y -P3y)) /
%               2*[P3x - P1x + m*(P3y - P1y)]
% Formel: y = m * x + b

        % Locate midpoint of circle
        mpxCircle = (uP3(1,1)^2 + uP3(1,2)^2 - uP1(1,1)^2 - uP1(1,2)^2+ ...
            2 * b_P * (uP1(1,2) - uP3(1,2))) / ...
            (2 * (uP3(1,1) - uP1(1,1) + m_P * (uP3(1,2) - uP1(1,2))));

        mpyCircle = m_P * mpxCircle + b_P;


        % Calculate radius with the distance of any point to midpoint
        rCircle = sqrt((mpxCircle - uP1(1,1))^2 +(mpyCircle - uP1(1,2))^2);

% Calculate the distance of a pixel k from the dataset to the midpoint of
% the circle. If the absolute difference between this distance and the
% radius is smaller than the threshold the point is detected as an inlier.
        for k = 1 : size(dataSet,1) 
            dist = sqrt((mpxCircle - dataSet(k,1))^2 + ...
                (mpyCircle - dataSet(k,2))^2);

            h = abs(rCircle - dist);

            if (h < threshold)
                inlierDataSet = [inlierDataSet; dataSet(k,:)];
            end
        end

% After each iteration the current inlierdataset is checked against the 
% best one yet detected and is swapped if better.
        if size(bInDataSet,1) < size(inlierDataSet,1)
           bInDataSet = inlierDataSet;
           bestR = rCircle;     % Save new best radius
           bestX = mpxCircle;   % Save new best midpoint x-value
           bestY = mpyCircle;   % Save new best midpoint y-value
        end
    end

% If method 1 is selected the best detected inlierset will be used.
    if method == 1
        
        % Save circle midpoint x-/y-values and the radius
        rCircleDataSet = [rCircleDataSet ; bestX bestY bestR];
        
% If method 2 the best set will also be checked against a minimum number of
% necessary inliers.        
    elseif method == 2
        % Min. num. of inliers has to be larger than the scope of the
        % square with the radius bestR (which is smaller than the scope of
        % the circle with this radius but a good value to compare to)
        minNumInlier = 4 * sqrt(2 * (bestR-1)^2);
        size(bInDataSet,1);

        if size(bInDataSet,1) > minNumInlier            
                        
            % Save circle midpoint x-/y-values and the radius
            rCircleDataSet = [rCircleDataSet ; bestX bestY bestR];
            
            % Remove all inliers from the dataset (for multiple detects)
            [ia,~] = ismember(dataSet, bInDataSet,'rows');
            dataSet(ia,:) = [];
        end
    end
end