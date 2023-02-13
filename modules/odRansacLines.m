%==========================================================================
%                       LINEDETECTION USING RANSAC
%==========================================================================
% The purpose of this function is to identify lines in a binary image and
% extract the start- and endlocation of each line by their x/y-coordinates.
% 
% This function includes two methods to accomplish that task.
% The first method uses predefined information about the minimal length a
% line should have proportional to the exact number of datapoints the image
% has to determine whether a line has been found. In this case there is
% maximum total number of iterations to locate all lines and once a good 
% fit has been detected this fit will be taken as a line.
%
% The second method doesnt involve knowledge about the lines to be found
% but instead does a set number of iterations per line and accepts the line
% that has been detected as the best fit. To detect multiple lines the 
% method needs to be called multiple times.
%
% In terms of speed the first method is way faster but requires knowledge
% about minimal line length.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: BW - logical MxN matrix (binary image)
% Optional: All of the following arguments are Name-Value-Pairs. The number
% in parenthesis describes the method in which it is being used.
%
% 'runs'      - positive integer (number of runs) (2)
% 'iterations'- positive integer (number of iterations) (1/2)
% 'threshold' - positive value greater or equal 0
%               determines if pixel is an inlier (1/2)
% 'ratio'     - positive value between 0 and 1
%               ratio line length to number of white pixels (1)
% 'gap'       - positive integer
%               max. gap between pixels to determine outliers (1)
% 'method'    - 1 or 2 for method selection (1/2)
%==========================================================================
%                           OUTPUT ARGUMENTS
% rLineDataSet - 1xN struct
%
% Each N represents a line and has values for Point 1 and Point 2
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [rLineDataSet] = odRansacLines (BW,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defMaxRuns       = 20;     % Max. number of runs (method 2)
defMaxIterations = 1000;   % Max. number of iterations
defThreshold     = 1.0;    % Threshold for "Inlier"/"Outlier" detection
defNumPtsOnLine  = 0.03;   % Ratio number of pixels on line / all pixels
defMaxPxlGap     = 5;      % Max. gap between pixels on a line
defMethod        = 2;      % Selected method to be used

p = inputParser;
addRequired(p,'BW',@islogical);
addParameter(p,'runs',defMaxRuns,@(x) mod(x,1)==0 && (x>0));
addParameter(p,'iterations',defMaxIterations,@(x) mod(x,1)==0 && (x>0));
addParameter(p,'threshold',defThreshold,@(x) (x>=0));
addParameter(p,'ratio',defNumPtsOnLine,@(x) (x<=1) && (x>=0));
addParameter(p,'gap',defMaxPxlGap,@(x) mod(x,1)==0 && (x>0));
addParameter(p,'method',defMethod,@(x) mod(x,1)==0 && (x<3) && (x>0));

parse(p,BW,varargin{:});

% Assign name-value arguments to used variables
maxRuns       = p.Results.runs;
maxIterations = p.Results.iterations;
threshold     = p.Results.threshold;
numPtsOnLine  = p.Results.ratio;
maxPxlGap     = p.Results.gap;
method        = p.Results.method;

% Outputparameter with lineinformation as a struct object
rLineDataSet = struct('point1',{}, 'point2', {}); 
dataSet = [];           % x/y/z-Koordinaten jedes weiﬂen Pixels aus BW
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

dataSetSave = dataSet;  % Keep an unchanged version of dataset


%==========================================================================
%                           Start of method 1
%==========================================================================
if method == 1

% For each iteration in method 1, 2 random pixels from the dataset are
% chosen which will be used to calculate the RANSAC.
    for itCount = 1 : maxIterations

        inlierDataSet = [];                 % Empty inlierdata
        samplePts = datasample(dataSet,2);  % Select 2 random pixels


% Calculating the RANSAC with the following formula:
% Formula: h = ((DP-SP1) * (SP1-SP2)) / |(SP1-SP2)|
% with:   DP = Datapoint; SP1 = Samplepoint 1; SP2 = Samplepoint 2
%
% distSamPts     = Distance between samplepoints 1 & 2 (SP1-SP2) (Vector)
% normDistSamPts = Distance between samplepoints 1 % 2 (Scalar)
% dist           = Distance between datapoint (k) and SP1 (Vector)
% normDist       = Distance between datapoint (k) and SP1 (Scalar)

        distSamPts     = samplePts(1,:)-samplePts(2,:);
        normDistSamPts = sqrt(distSamPts(1,1)^2 + distSamPts(1,2)^2);

        for k = 1 : size(dataSet,1) 
            dist       = cross((dataSet(k,:)-samplePts(1,:)), distSamPts);
            normDist   = sqrt(dist(1,1)^2 + dist(1,2)^2 + dist(1,3)^2);

            h = normDist / normDistSamPts;

            if (h < threshold)
                inlierDataSet = [inlierDataSet; dataSet(k,:)];
            end
        end



% Checking wether ratio of inliers and unchanged dataset is larger then the
% minimal line length. If true procedure to determine if the detected
% inliers are indeed a line will start.
        if ((size(inlierDataSet,1) / size(dataSetSave,1)) > numPtsOnLine)


% Sorting the inlierdata in ascending order (x-value). The added value 
% 0 0 0 is being used to make the folowing loop run accordingly and will
% not be displayed in the completed dataset.
            sortX = [sortrows(inlierDataSet,1); 0 0 0];
            sortY = [];             % Empty sortY
            sInDataSet = [];        % Sorted inlierdataset
            xValCount = 0;          % Counter for same x-values

            cutStr = 0; % Startposition (values before will be cut out)
            cutEnd = 0; % Endposition   (values after will be cut out)

            % Check whether sorted inlierdataset has ascending or
            % descending y-value. Based on this data will be sorted.
            if sortX(1,2) < sortX(end-1,2)
                sortType = 2;       % +2 = second column ascending
            else
                sortType = -2;      % -2 = second column descending
            end

% Loop to find equal x-values and sort their corresponding y-values in
% previously determined order.
            for i = 1 : size(sortX,1)-1
                if sortX(i,1) == sortX((i+1),1)
                    xValCount = xValCount + 1;
                elseif xValCount > 0
                    sortY = sortrows(sortX((i-xValCount):i,:),sortType);                
                    sInDataSet = [sInDataSet; sortY];
                    xValCount = 0;
                else
                    sInDataSet = [sInDataSet; sortX(i,:)];
                end
            end

% Detecting the distance of pixels to their following ones from start- and
% endposition of the dataset. In case the distance is larger then the 'gap'
% value the located position is being saved.
% Values before cutStr and values after cutEnd will be cut out.
            for i = 1 : (size(sInDataSet,1)/2 -1)
                ptsStr = [sInDataSet(i,:);sInDataSet(i+1,:)];
                ptsEnd = [sInDataSet(end-i,:);sInDataSet(end+1-i,:)];
                distFromStr = pdist(ptsStr,'euclidean');
                distFromEnd = pdist(ptsEnd,'euclidean');

                if distFromStr > maxPxlGap
                    cutStr = i;
                end
                if distFromEnd > maxPxlGap
                    cutEnd = size(sInDataSet,1)+1-i;
                end
            end

            if (cutEnd ~= 0)
                sInDataSet(cutEnd:end,:) = [];
            end
            if (cutStr ~= 0)
                sInDataSet(1:cutStr  ,:) = [];
            end


% Checking whether the now cut and sorted inlierdataset is still true in 
% terms of 'ratio'. In case it is true the start- and endpoints of the de-
% tected line will be saved in the rLineDataSet. At the same time the values
% of the cut and sorted inlierdataset will be removed from the dataset.
            if((size(sInDataSet,1) / size(dataSetSave,1)) > numPtsOnLine)
                % Identify start- and endpoint
                sPeP = [sInDataSet(1,:) ; sInDataSet(end,:)];

                % Remove all inliers from the dataset
                [ia,~] = ismember(dataSet, sInDataSet,'rows');
                dataSet(ia,:) = [];

                % Save SP and EP coordinates into rLineDataSet struct
                rLineDataSet(end+1) = struct('point1',...
                    [sPeP(1,1) sPeP(1,2)], 'point2',[sPeP(2,1) sPeP(2,2)]);
            end

% In case there is less then 5% of the original pixels remaining the loop 
% shall terminate early.
        elseif ((size(dataSet,1) / size(dataSetSave,1)) < 0.05)
            break
        end
    end

%==========================================================================
%                           End of method 1
%==========================================================================



%==========================================================================
%                           Start of method 2
%==========================================================================
elseif method == 2
    
% Execute the whole method 2 until either less than 5% of the original 
% pixels remain or maxRuns is reached.    
    count = 0; % Counter for the number of runs
    while (size(dataSet,1) / size(dataSetSave,1)) > 0.05 && count < maxRuns
        count = count + 1;
        bInDataSet = [];                        % Empty best inlierdataset        
        
        
        for itCount = 1 : maxIterations
            inlierDataSet = [];                 % Empty inlierdataset
            samplePts = datasample(dataSet,2);  % Select 2 random pixels


% Calculating the RANSAC with the following formula:
% Formula: h = ((DP-SP1) * (SP1-SP2)) / |(SP1-SP2)|
% with:   DP = Datapoint; SP1 = Samplepoint 1; SP2 = Samplepoint 2
%
% distSamPts     = Distance between samplepoints 1 & 2 (SP1-SP2) (Vector)
% normDistSamPts = Distance between samplepoints 1 % 2 (Scalar)
% dist           = Distance between datapoint (k) and SP1 (Vector)
% normDist       = Distance between datapoint (k) and SP1 (Scalar)

            distSamPts     = samplePts(1,:)-samplePts(2,:);
            normDistSamPts = sqrt(distSamPts(1,1)^2 + distSamPts(1,2)^2);

            for k = 1 : size(dataSet,1) 
                dist    = cross((dataSet(k,:)-samplePts(1,:)), distSamPts);
                normDist = sqrt(dist(1,1)^2 + dist(1,2)^2 + dist(1,3)^2);

                h = normDist / normDistSamPts;

                if (h < threshold)
                    inlierDataSet = [inlierDataSet; dataSet(k,:)];
                end
            end

% If the inlierdataset in this iteration is better than the ones before 
% save it as the new best inlierdataser.
            if size(bInDataSet,1) < size(inlierDataSet,1)
               bInDataSet = inlierDataSet;
            end
        end
        
% Sorting the best inlierdata in ascending order (x-value). The added value 
% 0 0 0 is being used to make the folowing loop run accordingly and will
% not be displayed in the completed dataset
        sortX = [sortrows(bInDataSet,1); 0 0 0];
        sortY = [];             % Empty sortY
        sInDataSet = [];        % Sorted inlierdataset
        xValCount = 0;          % Counter for same x-values

        cutStr = 0; % Startposition (values before will be cut out)
        cutEnd = 0; % Endposition   (values after will be cut out)

        % Check whether sorted inlierdataset has ascending or
        % descending y-value. Based on this data will be sorted.
        if sortX(1,2) < sortX(end-1,2)
            sortType = 2;       % +2 = second column ascending
        else
            sortType = -2;      % -2 = second column descending
        end

% Loop to find equal x-values and sort their corresponding y-values in
% previously determined order.
        for i = 1 : size(sortX,1)-1
            if sortX(i,1) == sortX((i+1),1)
                xValCount = xValCount + 1;
            elseif xValCount > 0
                sortY = sortrows(sortX((i-xValCount):i,:),sortType);                
                sInDataSet = [sInDataSet; sortY];
                xValCount = 0;
            else
                sInDataSet = [sInDataSet; sortX(i,:)];
            end
        end

        
        % Identify start- and endpoint
        sPeP = [sInDataSet(1,:) ; sInDataSet(end,:)];

        % Remove all inliers from the dataset
        [ia,~] = ismember(dataSet, sInDataSet,'rows');
        dataSet(ia,:) = [];

        % Save SP and EP coordinates into rLineDataSet struct
        rLineDataSet(end+1) = struct('point1',...
                    [sPeP(1,1) sPeP(1,2)], 'point2',[sPeP(2,1) sPeP(2,2)]);
    end
%==========================================================================
%                           End of method 2
%==========================================================================    
end