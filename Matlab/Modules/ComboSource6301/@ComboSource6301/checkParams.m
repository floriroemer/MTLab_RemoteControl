function outVars = checkParams(inVars, command, showmsg)
% check input parameters ==> always pairs
% 'parameterName', 'parameterValue'
% outVars = cell array with all set parameters
% all unset parameter names are ignored
% parameter values are coerced, converted or (silently) ignored
% report warnings when
%   - odd number of input variables
%   - unknown parameter names
%   - invalid types of parameter values
%
% accepted inputs are: (for all parameters)
% text is not case sensitive    ==> changed to upper case
% 'text', "text", {'text'}      ==> 'TEXT'    (without spaces)
% number, [number], true/false  ==> 'number'
%

narginchk(1,3);
% -------------------------------------------------------------------------
% check type of input
if isempty(inVars)
    inVars = {};
elseif ~iscell(inVars) || ~isvector(inVars)
    error('ComboSource6301: invalid state.');
elseif mod(length(inVars), 2) ~= 0
    disp(['ComboSource6301: Warning - Odd number of parameters. ' ...
        'Ignore last input.']);
end

if nargin < 3
    showmsg = false;
end

if nargin < 2 || isempty(command)
    command = '';
end

% -------------------------------------------------------------------------
% initialize all parameter values (empty)
current      = '';   % setCurrent, setCurrentLimit
power        = '';   % setPower, setPowerLimit
temperature  = '';   % setTempLimitLow, setTempLimitHigh
mode         = '';   % operating mode (CC or CP)
enable       = '';   % laser enable/disable
limit        = '';   % limit values

% -------------------------------------------------------------------------
% assign parameter values
for nArgsIn = 2:2:length(inVars)
    paramName  = inVars{nArgsIn-1};
    paramValue = inVars{nArgsIn};
    % convert even cell arrays or strings to char: {'m' 'ode'} is okay
    if iscellstr(paramName) || isstring(paramName)
        paramName = char(strjoin(paramName, ''));
    end
    if ischar(paramName) || isStringScalar(paramName)
        % coerce parameter value (array) to comma separated char array
        % '1', {'1'}, "1", 1, true                           ==> '1'
        % {'0', '1'} ["0", "1"], '0, 1', [0 1] [false true ] ==> '0, 1'
        if ~isvector(paramValue)
            paramValue = '';
            disp(['ComboSource6301: Invalid type of ''' paramName '''. ' ...
                'Ignore input.']);
        elseif ischar(paramValue)
            paramValue = upper(paramValue);
        elseif iscellstr(paramValue) || isstring(paramValue)
            paramValue = upper(char(strjoin(paramValue, ', ')));
        elseif islogical(paramValue)
            paramValue = regexprep(num2str(paramValue), '\s+', ', ');
        elseif isa(paramValue, 'double')
            paramValue = upper(regexprep( ...
                num2str(paramValue, 10), '\s+', ', '));
        else
            paramValue = '';
        end
        % copy coerced parameter value to the right variable
        switch lower(char(paramName))
            % list of supported parameters
            case {'current', 'curr', 'i'}
                if ~isempty(regexp(paramValue, '^[\w\.\+\-]+$', 'once'))
                    current = paramValue;
                end
            case {'power', 'pow', 'p'}
                if ~isempty(regexp(paramValue, '^[\w\.\+\-]+$', 'once'))
                    power = paramValue;
                end
            case {'temperature', 'temp', 't'}
                if ~isempty(regexp(paramValue, '^[\w\.\+\-]+$', 'once'))
                    temperature = paramValue;
                end
            case {'mode', 'opmode'}
                if ~isempty(regexp(paramValue, '^\w+$', 'once'))
                    mode = paramValue;
                end
            case {'enable', 'output'}
                if ~isempty(regexp(paramValue, '^\w+$', 'once'))
                    enable = paramValue;
                end
            case {'limit', 'lim'}
                if ~isempty(regexp(paramValue, '^[\w\.\+\-]+$', 'once'))
                    limit = paramValue;
                end
            otherwise
                disp(['ComboSource6301: Warning - Parameter name ''' ...
                    paramName ''' is unknown. ' ...
                    'Ignore parameter.']);
        end
    else
        disp(['ComboSource6301: Parameter names have to be ' ...
            'character arrays. Ignore input.']);
    end
end

% -------------------------------------------------------------------------
% copy only command relevant parameters
switch command
    case 'setCurrent'
        outVars = { ...
            'current'   , current    };
    case 'setPower'
        outVars = { ...
            'power'     , power      };
    case 'setCurrentLimit'
        outVars = { ...
            'limit'     , limit      };
    case 'setPowerLimit'
        outVars = { ...
            'limit'     , limit      };
    case 'setTempLimit'
        outVars = { ...
            'temperature', temperature };
    case 'setMode'
        outVars = { ...
            'mode'      , mode       };
    case 'enableLaser'
        outVars = { ...
            'enable'    , enable     };
    otherwise
        % create full list of parameter name+value pairs
        allVars = { ...
            'current'    , current     , ...
            'power'      , power       , ...
            'temperature', temperature , ...
            'mode'       , mode        , ...
            'enable'     , enable      , ...
            'limit'      , limit       };
        % copy only non-empty parameter name+value pairs to output
        outVars = cell(0);
        idx     = 1;
        for cnt = 1 : 2 : length(allVars)
            if ~isempty(allVars{cnt+1})
                outVars{idx}   = allVars{cnt};
                outVars{idx+1} = allVars{cnt+1};
                idx            = idx+2;
            end
        end
end

if showmsg
    for cnt = 1 : 2 : length(outVars)
        if ~isempty(outVars{cnt+1})
            % preprocess parameterValue
            paramValueText = outVars{cnt+1};
            % convert non character arrays
            if ~ischar(paramValueText)
                paramValueText = num2str(paramValueText);
            end
            % limit length of text
            if length(paramValueText) > 44
                paramValueText = [paramValueText(1:40) ' ...'];
            end
            disp(['  - ' pad(outVars{cnt}, 13) ': ' ...
                paramValueText]);
        end
    end
end
end
