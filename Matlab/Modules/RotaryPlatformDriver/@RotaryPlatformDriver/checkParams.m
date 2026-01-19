function outVars = checkParams(inVars, command, showmsg)
% Simple parameter checking for RotaryPlatformDriver

if isempty(inVars), inVars = {}; end
if mod(length(inVars), 2) ~= 0
    disp('RotaryPlatformDriver: Warning - Odd number of parameters.');
end

angle = ''; speed = ''; wait = '';

for n = 2:2:length(inVars)
    name = lower(char(inVars{n-1}));
    value = inVars{n};
    if isnumeric(value), value = num2str(value); end
    
    switch name
        case {'angle', 'position'}
            angle = value;
        case {'speed', 'velocity'}
            speed = value;
        case 'wait'
            wait = value;
    end
end

outVars = {'angle', angle, 'speed', speed, 'wait', wait};
end
