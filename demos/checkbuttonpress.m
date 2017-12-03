classdef checkbuttonpress < handle
    
    properties
        press = false;
    end
    
    methods
        function cb = checkbuttonpress
            set(gcf, 'WindowButtonDownFcn', @(src, event) button_callback(src, event, cb));
        end
        
        
    end
end

function button_callback(src, event, cb)
    cb.press = true;
end