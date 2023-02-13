%==========================================================================
%                           IMAGEPREPROCESSING
%==========================================================================
% The purpose of this function is to select and preprocess the image, so
% that it can be used in the following functions. For that reason the
% selected image is being tested for correct format and is then transformed
% into a grayscale image. Both color and grayscale image are being
% returned.
%==========================================================================
%                           OUTPUT ARGUMENTS
% RGB   - MxNx3 matrix (color image (3 channels))
% GRAY  - MxNx1 matrix (grayscale image (1 channel))
% check - logical scalar (check whether image has been loaded or not)
%==========================================================================
% author: Alexander Avercenko  5070284
%==========================================================================

function [RGB,GRAY,check] = odImagePreprocessing()

% Image formats can be specified here. Function is being used to load an
% image based on its name and path in the next step. Filter is being used
% as a check, whether user selected an image or pressed "cancel" or "x".
[FileName,FilePath,Filter] = uigetfile(...
    {'*.jpg;*.png;*.bmp;*.gif;*.tif', ...
     'Image Files (*.jpg;*.png;*.bmp;*.gif;*.tif)'}, ...
     'Select a color or grayscale image.');

if (Filter == 1)
    % Load in image and check whether it has 1 or 3 channel/s.
    RGB = imread(fullfile(FilePath,FileName));
    if size(RGB,3) == 3
        % Funktion um aus einem Farbbild ein Grauwertbild zu machen.
        GRAY = rgb2gray(RGB);   % Transform color to grayscale image
        check = true;
    elseif size(RGB,3) == 1     % If image has 1 channel it already is a 
        GRAY = RGB;             % grayscale image.
        check = true;           
    end
else
    % In case user clicked "cancel" or "x" image variables stay empty and
    % false is being returned.
    RGB = [];
    GRAY = [];
    check = false;
end