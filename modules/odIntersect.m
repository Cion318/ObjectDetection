%==========================================================================
%                         LINE INTERSECT CHECK
%==========================================================================
% The purpose of this function is to test if any given two lines have an 
% intersection point.
% 
% This function is based on the description of this problem by the users 
% princi singh and princiray1992 on the webside geeksforgeeks.org. This
% code represents the MatLab adaptation of their C++ code for this problem.
%(https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect)
%==========================================================================
%                           INPUT ARGUMENTS
% Required: p1 - 2x1 Matrix with x/y-coordinates of line 1 startpoint
%           q1 - 2x1 Matrix with x/y-coordinates of line 1 endpoint
%           p2 - 2x1 Matrix with x/y-coordinates of line 2 startpoint
%           q2 - 2x1 Matrix with x/y-coordinates of line 2 endpoint
%==========================================================================
%                           OUTPUT ARGUMENTS
%           check - boolean value with true or false depending whether
%                   intersection has been found or not
% 
%==========================================================================
% Original authors : princi singh and princiray1992 (geeksforgeeks.org)
% MatLab adaptation: Alexander Avercenko 5070284
%==========================================================================

function [check] = odIntersect(p1, q1, p2, q2)
        % Using orientation function (defined below) calculate all
        % orientation combinations to use in general and special cases.
        o1 = orientation(p1,q1,p2);
        o2 = orientation(p1,q1,q2);
        o3 = orientation(p2,q2,p1);
        o4 = orientation(p2,q2,q1);
        
        % General Case all points colinear
        if (o1 ~= o2 && o3 ~= o4)
            check = true;
            return
        end
        
        % Special Cases
        % p1, q1 and p2 are colinear and p2 lies on segment p1q1
        if (o1 == 0 && onSegment(p1, p2, q1))
            check = true;            
        % p1, q1 and q2 are colinear and q2 lies on segment p1q1
        elseif (o2 == 0 && onSegment(p1, q2, q1))
            check = true;
        % p2, q2 and p1 are colinear and p1 lies on segment p2q2
        elseif (o3 == 0 && onSegment(p2, p1, q2))
            check = true;            
        % p2, q2 and q1 are colinear and q1 lies on segment p2q2
        elseif (o4 == 0 && onSegment(p2, q1, q2))
            check = true;
        % Doesn't fall in any of the above cases    
        else
            check = false;     
        end
        return
end


    % Check whether point q lies on the line segment pr, in case all
    % points are colinear.
    function [check] = onSegment(p, q, r)
        if (q(1,1) <= max(p(1,1), r(1,1)) && q(1,1) >= min(p(1,1), r(1,1))...
                && q(1,2) <= max(p(1,2), r(1,2)) && q(1,2) >= min(p(1,2), r(1,2)))
            check = true;
        else
            check = false;
        end
    end

    
    % Orientetion function takes in 3 points and finds the orientation of
    % those ordered points.
    function [ori] = orientation(p, q, r)
        % Formula to calculate orientation using equation desribed in
        % https://www.geeksforgeeks.org/orientation-3-ordered-points/
        val = (q(1,2) - p(1,2)) * (r(1,1) - q(1,1)) -...
            (q(1,1) - p(1,1)) * (r(1,2) - q(1,2));
        
        if val == 0         % Points are colinear
            ori = 0;
        elseif val > 0
            ori = 1;        % Points are turning clockwise
        else
            ori = 2;        % Points are turning counter-clockwise
        end
    end