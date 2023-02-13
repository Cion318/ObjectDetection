%==========================================================================
%             FIND AND CROP MAXIMUM AREA IN ROTATED TEMPLATE
%==========================================================================
% When rotating an image with an angle unequal to multiples of 90° there
% arise black corners in the rotated image. Those corners reduce the accu-
% racy of crosscorrelation to another image. For this reason this function
% detects the maximum area inside the rotated image which is free from
% those black corners and crops it.
%==========================================================================
%                           INPUT ARGUMENTS
% w   - scalar (width of the original image)
% h   - scalar (highth of the original image)
% a   - scalar (angle which was used to rotate the original image)
% RTG - MxN matrix (rotated version of the original image)
%==========================================================================
%                           OUTPUT ARGUMENTS
% CRTG - MxN matrix (cropped version of the rotated image RTG)
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [CRTG] = odFindMaxAreaCrop(w, h, a, RTG)

% Identify the longest side
if (w >= h)
    longSide  = w;
    shortSide = h;
else
    longSide  = h;
    shortSide = w;
end

% Calculate values for sine and cosine of a. The calculated values are
% eligible for every case, since the solutions are the same for a and -a
% aswell as for 180° rotations.
sin_a = abs(sin(a*pi/180));
cos_a = abs(cos(a*pi/180));

% 1. Case: two of the corners of the maximum crop are laying on the sides 
% of the rotated image. The maximum internal area spreads from the corner
% which lays on the half of the shorter side.
if (shortSide <= 2*sin_a*cos_a*longSide) || (abs(sin_a-cos_a) < 1*10^-10)
    x  = 0.5*shortSide;
    if (w >= h)
        rw = (x/sin_a);
        rh = (x/cos_a);
    else
        rw = (x/cos_a);
        rh = (x/sin_a);
    end
% 2. Case: in case the above condition would not be valid the cropped area 
% would lay outside of the rotated image. In this case the maximum area
% does not spread at the halfway mark of the shorter side and has to be
% calculated as follows.
else
    cos_2a = cos_a*cos_a - sin_a*sin_a;
    rw = (w*cos_a - h*sin_a)/cos_2a;
    rh = (h*cos_a - w*sin_a)/cos_2a;    
end


wth = size(RTG,2);      % Width of the rotated image
hth = size(RTG,1);      % Highth of the rotated image
mpx = round(wth/2);     % Midpoint coordinate x
mpy = round(hth/2);     % Midpoint coordinate y

% Maximum area of the image without black corners
CRTG = imcrop(RTG,[mpx-rw/2 mpy-rh/2 rw rh]);