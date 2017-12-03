function [out,resid] = linefit(xy)
    
    if isstruct(xy)
        out = ransac_driver(xy);
        return;
    end
    
    % data is passed with points in columns
    x = xy(1,:)'; y = xy(2,:)';
    
    out = [x ones(size(x))] \ y;
    resid = max(abs(y - [x ones(size(x))]*out));
    
end

function out = ransac_driver(R)
    switch R.cmd
        case 'size'
            out.s = 2;  % we need 2 points to estimate a line
            
        case 'condition'
            out.X = R.X;  % data doesnt need conditioning
            out.misc = [];
            
        case 'decondition'
            out.theta = R.theta;  % parameters don't need unconditioning
            
        case 'valid'
            out.valid = true;   % assume always valid
            
        case 'estimate'
            % estimate line from 2 passed points
            out.theta = [R.X(1,:)' ones(size(R.X(1,:)'))] \ R.X(2,:)';
            out.resid = 0;
            
        case 'error'
            x = R.X(1,:); y = R.X(2,:);   % test for model conformance
            m = R.theta(1); c = R.theta(2);
            resid = abs(y - m*x - c);
            out.inliers = find(resid < R.t);
            out.theta = R.theta;
    end
end