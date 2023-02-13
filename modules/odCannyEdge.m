%==========================================================================
%                          CANNY-EDGE-DETECTION
%==========================================================================
% The purpose of this function is to locate transform the given grayscale
% image into an edge detected binary image. To accomplish this the canny-
% edge-detection algorithm is being used.
%==========================================================================
%                           INPUT ARGUMENTS
% Required: GRAY - MxN matrix with one channel (grayscale image)
% Optional: All of the following arguments are Name-Value-Pairs.
%
% 'automatic' - positive integer with the value 0 or 1
% 'threshold' - positive value between 0 and 1
%==========================================================================
%                           OUTPUT ARGUMENTS
% BW - logical MxN matrix (binary image)
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [BW] = odCannyEdge(GRAY,varargin)
%==========================================================================
% Default values for necessary variables (def) and inputparser to determine
% used function parameters.
%==========================================================================
defAutomatic = 1;     % Default mode is automatic threshold calculation
defThreshold = 0.5;   % Default threshold if not automatic

p = inputParser;
addRequired(p,'GRAY');
addParameter(p,'automatic',defAutomatic,@(x) mod(x,1)==0 &&(x>=0) &&(x<2));
addParameter(p,'threshold',defThreshold,@(x) (x>=0) && (x<=1));

parse(p,GRAY,varargin{:});

% Assign name-value arguments to used variables
automatic = p.Results.automatic;
threshold = p.Results.threshold;

%==========================================================================

% Checking whether automatic threshold calculation or not and transforming
% grayscale image according to that method.
if (automatic == 1)
    [BW] = edge (GRAY,'Canny');
else
    BW = edge(GRAY,'Canny',threshold);
end