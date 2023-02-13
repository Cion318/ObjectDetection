%==========================================================================
%                           TEMPLATE MATCHING
%==========================================================================
% The purpose of this function is to locate a template in a passed image in
% terms of accordance and location.
% 
% This function uses the normalized cross-correlation to identify the best
% consensus. To identify the template in rotated images this function uses
% a second function to to identify the biggest possible crop inside the
% rotated template to remove the black corners.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: GRAY - unsigned integer MxN matrix (grayscale image)
% Optional: All of the following arguments are Name-Value-Pairs.
%
% 'angle'     - positive integer between 1 and 360
%==========================================================================
%                           OUTPUT ARGUMENTS
% tmDataSet - Mx6 matrix with the following data stored:
% 1./2. columns: x-/y-value for the top left corner the template starts at
% 3./4. columns: width (right direction) and heigth (bottom direction) of
%                the template from top left corner
% 5. column    : the best angle the image has been detected at
% 6. column    : the best consensus found between template and image
%
% The first row always lists the found template location.
% The second row (in case necessary) lists the location of the cropped
% version of the rotated image.
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [tmDataSet,tempGRAY] = odTemplateMatching (GRAY,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defAngle = 45;      % Default angle to rotate template in each iteration

p = inputParser;
addRequired(p,'GRAY');
addParameter(p,'angle',defAngle,@(x) mod(x,1)==0 && (x>0) && (x<=360));

parse(p,GRAY,varargin{:});

% Assign name-value arguments to used variables
angle = p.Results.angle;


tmDataSet = [];   % Outputparameter with template matching data
%==========================================================================

% Shortcuts used in upcoming variables:
% C: Cropped  R: Rotated  T: Template  G: Gray

% Select template and check if input is correct.
check = false;
while (check == false)
    [~,tempGRAY,check] = odImagePreprocessing();
    if check ~= 1
        prompt = ('Cancel template matching? (Y=Cancel, Else=Continue)');
        str = input(prompt,'s');
        if ( str == 'Y')    % Cancel function if input = Y
            return
        end
    end
end
        

TGRAY = tempGRAY;   % Keep an unchanged version of the template
RTGRAY = tempGRAY;  % Second save in case rotation is being used
highestCorr = 0;    % Save the highest correlation


% Loop to find the best fit. Number of iterations depends on chosen angle
% to fulfill a 360 degree scan of template and image.
for i = 0 : round((360/angle))
    C = normxcorr2(TGRAY,GRAY); % Normalized cross-correlation
        
    % Save the new highest correlation after every iteration                            
    if (max(C(:)) > max(highestCorr(:)))
        highestCorr = C;    % Save the consensus
        RTG    = RTGRAY;    % Save the best rotated variant of the template
        CRTG   = TGRAY;     % Save the cropped version of the rot. template
        bAngle = (i-1)*angle;   % Save the angle for best consensus
    end

    RTGRAY = imrotate(tempGRAY,i*angle);    % Rotate the original template

    % Check whether rotation is a multiple of 90° to skip cropping if not
    % necessary.
    if (mod(round(i*angle),90) ~= 0)
        % Using the findMaxAreaCrop function to locate the max. crop area
        [TGRAY] = odFindMaxAreaCrop(size(tempGRAY,2), size(tempGRAY,1), ...
            i*angle, RTGRAY);
    else  % Skip crop process
        TGRAY = RTGRAY;
    end
end

% Find coordinates of best consensus after all iterations
[ypeak, xpeak] = find(highestCorr==max(highestCorr(:)));

% Only the template will be plotted n case CRTG and RTG are the same (90° 
% rotations)
if (size(CRTG) == size(RTG))
    wRC = size(CRTG,2);     % Width of the template
    hRC = size(CRTG,1);     % Highth of the template
    
    tmDataSet = [xpeak-wRC ypeak-hRC wRC hRC bAngle max(highestCorr(:))];
  
% In case CRTG and RTG are not equal both the template and cropped template
% location woll be plotted.
else          
    wRC = size(CRTG,2);
    hRC = size(CRTG,1);    
    
    % Calculating the offset for the non-cropped template plot.
    wR = size(RTG,2);
    hR = size(RTG,1);
    offsetX = xpeak-wRC/2 - wR/2;
    offsetY = ypeak-hRC/2 - hR/2;
    
    tmDataSet = [offsetX, offsetY, wR, hR bAngle, max(highestCorr(:)); ...
        xpeak-wRC ypeak-hRC wRC hRC bAngle max(highestCorr(:))];
end
figure
imshow(CRTG);