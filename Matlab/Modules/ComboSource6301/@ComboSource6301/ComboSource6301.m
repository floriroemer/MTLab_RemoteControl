classdef ComboSource6301 < VisaIF
    % documentation for class 'ComboSource6301'
    % ---------------------------------------------------------------------
    % This class defines methods for controlling the ComboSource 6301 laser
    % controller via RS-232/USB interface. This class is a subclass of the
    % superclass 'VisaIF'. For full HTML documentation, use 'ComboSource6301.doc'.
    %
    % Type in command window:
    % 'ComboSource6301' - to get a list of accessible devices
    % 'ComboSource6301.doc' - to open comprehensive HTML documentation
    %
    % All public properties and methods from superclass 'VisaIF' can also
    % be used. See 'VisaIF.doc' for details (min. VisaIFVersion 3.0.0).
    %
    % CONSTRUCTOR:
    %   myLaser = ComboSource6301(device)
    %   myLaser = ComboSource6301(device, interface)
    %   myLaser = ComboSource6301(device, interface, showmsg)
    %
    % NOTES:
    %     * The output parameter 'status' has the same meaning for all methods
    %           status   : == 0 when okay
    %                      != 0 when something went wrong
    %     * All parameter names and values are NOT case sensitive
    %     * Check for warnings and errors
    %
    % MAIN METHODS:
    %   Device Information:
    %     - getID()             : Get device identification string
    %     - getError()          : Get last error from device
    %     - clear()             : Clear device status
    %     - reset()             : Reset device to factory defaults
    %
    %   Laser Enable/Disable:
    %     - enableLaser()       : Enable laser output
    %     - disableLaser()      : Disable laser output
    %     - isLaserEnabled()    : Query laser output state
    %
    %   Current Control:
    %     - setCurrent(mA)      : Set laser drive current in mA
    %     - getCurrent()        : Get current setpoint in mA
    %     - getMeasuredCurrent(): Get measured current in mA
    %
    %   Current Limits:
    %     - setCurrentLimit(mA) : Set maximum current limit in mA
    %     - getCurrentLimit()   : Get current limit in mA
    %
    %   Power Control:
    %     - setPower(mW)        : Set laser output power in mW
    %     - getPower()          : Get power setpoint in mW
    %     - getMeasuredPower()  : Get measured power in mW
    %
    %   Power Limits:
    %     - setPowerLimit(mW)   : Set maximum power limit in mW
    %     - getPowerLimit()     : Get power limit in mW
    %
    %   Temperature Monitoring:
    %     - getTemperature()    : Get laser diode temperature in °C
    %     - getTECCurrent()     : Get TEC (thermoelectric cooler) current in A
    %
    %   Temperature Limits:
    %     - setTempLimitLow(C)  : Set minimum temperature limit in °C
    %     - getTempLimitLow()   : Get minimum temperature limit in °C
    %     - setTempLimitHigh(C) : Set maximum temperature limit in °C
    %     - getTempLimitHigh()  : Get maximum temperature limit in °C
    %
    %   Operating Mode:
    %     - setModeConstantCurrent() : Set to constant current mode
    %     - setModeConstantPower()   : Set to constant power mode
    %     - getMode()                : Get current operating mode
    %
    %   Status and Safety:
    %     - getStatus()         : Get comprehensive device status
    %     - isInterlockClosed() : Check interlock status
    %     - isOverTemp()        : Check over-temperature condition
    %     - lock()              : Lock front panel buttons
    %     - unlock()            : Unlock front panel buttons
    %
    % PROPERTIES:
    %   Read-only:
    %     - ComboSourceVersion : Version of this class file
    %     - ComboSourceDate    : Release date of this class file
    %     - ErrorMessages      : Error list from device error buffer
    %
    % ---------------------------------------------------------------------
    % EXAMPLE USAGE:
    %
    %   % Create object and connect
    %   myLaser = ComboSource6301('combosource');
    %
    %   % Get device info
    %   disp(myLaser.getID());
    %
    %   % Configure current limit and setpoint
    %   myLaser.setCurrentLimit(150);  % Set limit to 150 mA
    %   myLaser.setCurrent(100);       % Set current to 100 mA
    %
    %   % Enable laser
    %   myLaser.enableLaser();
    %
    %   % Monitor status
    %   fprintf('Current: %.2f mA\n', myLaser.getMeasuredCurrent());
    %   fprintf('Power: %.2f mW\n', myLaser.getMeasuredPower());
    %   fprintf('Temperature: %.2f °C\n', myLaser.getTemperature());
    %
    %   % Disable laser
    %   myLaser.disableLaser();
    %
    %   % Close connection
    %   myLaser.delete;
    %
    % ---------------------------------------------------------------------
    % HTW Dresden, faculty of electrical engineering
    %   for version and release date see properties 'ComboSourceVersion' and
    %   'ComboSourceDate'
    %
    % tested with
    %   - Matlab (version 24.1 = 2024a update 6) and
    %   - Instrument Control Toolbox (version 24.1)
    %   - NI-VISA 21.5 (download from NI, separate installation)
    %
    % known issues and planned extensions / fixes
    %   - none reported yet
    %
    % development, support and contact:
    %   - Matthias Henker   (professor)
    % ---------------------------------------------------------------------

    properties(Constant = true)
        ComboSourceVersion = '1.0.0';      % release version (= class version)
        ComboSourceDate    = '2026-01-19'; % release date
    end

    properties(Dependent, SetAccess = private, GetAccess = public)
        ErrorMessages
    end

    % ---------------------------------------------------------------------
    methods(Static)
        
        function doc(className)
            %DOC Open HTML documentation in browser
            %
            %   DOC() opens the ComboSource6301 documentation.
            %   DOC(CLASSNAME) opens documentation for specified class.
            %
            %   This method opens the HTML documentation file using
            %   MATLAB's web browser.
            %
            %   Example:
            %       ComboSource6301.doc()
            %
            
            if nargin == 0
                className = mfilename('class');
            end

            htmlFile = which([className '.html']);
            if isempty(htmlFile)
                % Try to construct path manually
                classFile = which(className);
                if ~isempty(classFile)
                    [classPath, ~, ~] = fileparts(classFile);
                    htmlFile = fullfile(classPath, [className '.html']);
                end
            end
            
            if isfile(htmlFile)
                web(htmlFile, '-new', '-notoolbar');
            else
                error('ComboSource6301:doc', ...
                    'HTML documentation file not found: %s.html', className);
            end
        end
    end

    % ---------------------------------------------------------------------
    methods

        function obj = ComboSource6301(device, interface, showmsg)
            % Constructor for ComboSource6301 object
            %
            % Usage:
            %   myLaser = ComboSource6301(device)
            %   myLaser = ComboSource6301(device, interface)
            %   myLaser = ComboSource6301(device, interface, showmsg)
            %
            % Parameters:
            %   device    - device name from config file
            %   interface - 'visa-serial', 'visa-usb', or 'visa-tcpip'
            %   showmsg   - 'none', 'few', or 'all'

            % Check number of input arguments
            narginchk(0, 3);

            % Set default values when no input is given
            if nargin < 3 || isempty(showmsg)
                showmsg = 'few';
            end

            if nargin < 2 || isempty(interface)
                interface = '';
            end

            if nargin < 1 || isempty(device)
                device = '';
            end

            % Get class name
            className = mfilename('class');

            % Call superclass constructor
            instrument = className;
            obj = obj@VisaIF(device, interface, showmsg, instrument);

            if isempty(obj.Device)
                error('Initialization failed.');
            end

            % Display connection message
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  ComboSource6301 initialized successfully');
            end
        end

        function delete(obj)
            % Destructor - cleanup before closing connection
            
            % Display closing message
            if ~strcmpi(obj.ShowMessages, 'none') && ~isempty(obj.DeviceName)
                disp([obj.DeviceName ':']);
                disp('  Closing ComboSource6301 connection');
            end
        end

        % -----------------------------------------------------------------
        % Extend methods from super class (VisaIF)
        % -----------------------------------------------------------------

        function status = reset(obj)
            % Reset device to factory defaults
            %
            % Usage:
            %   status = myLaser.reset()
            
            status = NaN;
            
            % Clear buffers
            obj.clrdevice;

            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Resetting device to factory defaults');
            end

            % Send reset command
            status = obj.write('*RST');
            pause(0.5); % Allow time for reset
            
            if isnan(status)
                status = 0;
            end

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Reset failed');
            end
        end

        function status = clear(obj)
            % Clear device status and error queue
            %
            % Usage:
            %   status = myLaser.clear()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Clearing device status');
            end

            status = obj.write('*CLS');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Clear failed');
            end
        end

        function status = lock(obj)
            % Lock front panel buttons
            %
            % Usage:
            %   status = myLaser.lock()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Locking front panel');
            end

            status = obj.write('SYST:LOCK ON');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Lock failed');
            end
        end

        function status = unlock(obj)
            % Unlock front panel buttons
            %
            % Usage:
            %   status = myLaser.unlock()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Unlocking front panel');
            end

            status = obj.write('SYST:LOCK OFF');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Unlock failed');
            end
        end

        % -----------------------------------------------------------------
        % Device Information Methods
        % -----------------------------------------------------------------

        function [status, idString] = getID(obj)
            % Get device identification string
            %
            % Usage:
            %   idString = myLaser.getID()
            %   [status, idString] = myLaser.getID()
            %
            % Returns:
            %   idString - Identification string (manufacturer, model, serial, firmware)
            
            [status, idString] = obj.query('*IDN?');
            
            if nargout < 2
                status = idString;
            end
        end

        function [status, errorMsg] = getError(obj)
            % Get last error from device error queue
            %
            % Usage:
            %   errorMsg = myLaser.getError()
            %   [status, errorMsg] = myLaser.getError()
            %
            % Returns:
            %   errorMsg - Error message string
            
            [status, errorMsg] = obj.query('SYST:ERR?');
            
            if nargout < 2
                status = errorMsg;
            end
        end

        % -----------------------------------------------------------------
        % Laser Enable/Disable Methods
        % -----------------------------------------------------------------

        function status = enableLaser(obj)
            % Enable laser output
            %
            % Usage:
            %   status = myLaser.enableLaser()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Enabling laser output');
            end

            status = obj.write('OUTP ON');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Enable laser failed');
            end
        end

        function status = disableLaser(obj)
            % Disable laser output
            %
            % Usage:
            %   status = myLaser.disableLaser()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Disabling laser output');
            end

            status = obj.write('OUTP OFF');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Disable laser failed');
            end
        end

        function [status, isEnabled] = isLaserEnabled(obj)
            % Query laser output state
            %
            % Usage:
            %   isEnabled = myLaser.isLaserEnabled()
            %   [status, isEnabled] = myLaser.isLaserEnabled()
            %
            % Returns:
            %   isEnabled - true if laser is on, false if off
            
            [status, response] = obj.query('OUTP?');
            
            if status == 0
                isEnabled = strcmpi(strtrim(response), '1') || ...
                           strcmpi(strtrim(response), 'ON');
            else
                isEnabled = false;
            end
            
            if nargout < 2
                status = isEnabled;
            end
        end

        % -----------------------------------------------------------------
        % Current Control Methods
        % -----------------------------------------------------------------

        function status = setCurrent(obj, currentMA)
            % Set laser drive current in mA
            %
            % Usage:
            %   status = myLaser.setCurrent(currentMA)
            %
            % Parameters:
            %   currentMA - Current setpoint in milliamperes
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                fprintf('  Setting current to %.3f mA\n', currentMA);
            end

            % Convert mA to A for SCPI command
            currentA = currentMA / 1000;
            status = obj.write(sprintf('SOUR:CURR %.6f', currentA));

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set current failed');
            end
        end

        function [status, currentMA] = getCurrent(obj)
            % Get current setpoint in mA
            %
            % Usage:
            %   currentMA = myLaser.getCurrent()
            %   [status, currentMA] = myLaser.getCurrent()
            %
            % Returns:
            %   currentMA - Current setpoint in milliamperes
            
            [status, response] = obj.query('SOUR:CURR?');
            
            if status == 0
                currentA = str2double(response);
                currentMA = currentA * 1000; % Convert A to mA
            else
                currentMA = NaN;
            end
            
            if nargout < 2
                status = currentMA;
            end
        end

        function [status, currentMA] = getMeasuredCurrent(obj)
            % Get measured laser current in mA
            %
            % Usage:
            %   currentMA = myLaser.getMeasuredCurrent()
            %   [status, currentMA] = myLaser.getMeasuredCurrent()
            %
            % Returns:
            %   currentMA - Measured current in milliamperes
            
            [status, response] = obj.query('MEAS:CURR?');
            
            if status == 0
                currentA = str2double(response);
                currentMA = currentA * 1000; % Convert A to mA
            else
                currentMA = NaN;
            end
            
            if nargout < 2
                status = currentMA;
            end
        end

        % -----------------------------------------------------------------
        % Current Limit Methods
        % -----------------------------------------------------------------

        function status = setCurrentLimit(obj, limitMA)
            % Set maximum current limit in mA
            %
            % Usage:
            %   status = myLaser.setCurrentLimit(limitMA)
            %
            % Parameters:
            %   limitMA - Maximum current limit in milliamperes
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                fprintf('  Setting current limit to %.3f mA\n', limitMA);
            end

            % Convert mA to A for SCPI command
            limitA = limitMA / 1000;
            status = obj.write(sprintf('SOUR:CURR:LIM %.6f', limitA));

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set current limit failed');
            end
        end

        function [status, limitMA] = getCurrentLimit(obj)
            % Get maximum current limit in mA
            %
            % Usage:
            %   limitMA = myLaser.getCurrentLimit()
            %   [status, limitMA] = myLaser.getCurrentLimit()
            %
            % Returns:
            %   limitMA - Maximum current limit in milliamperes
            
            [status, response] = obj.query('SOUR:CURR:LIM?');
            
            if status == 0
                limitA = str2double(response);
                limitMA = limitA * 1000; % Convert A to mA
            else
                limitMA = NaN;
            end
            
            if nargout < 2
                status = limitMA;
            end
        end

        % -----------------------------------------------------------------
        % Power Control Methods
        % -----------------------------------------------------------------

        function status = setPower(obj, powerMW)
            % Set laser output power in mW
            %
            % Usage:
            %   status = myLaser.setPower(powerMW)
            %
            % Parameters:
            %   powerMW - Power setpoint in milliwatts
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                fprintf('  Setting power to %.3f mW\n', powerMW);
            end

            % Convert mW to W for SCPI command
            powerW = powerMW / 1000;
            status = obj.write(sprintf('SOUR:POW %.6f', powerW));

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set power failed');
            end
        end

        function [status, powerMW] = getPower(obj)
            % Get power setpoint in mW
            %
            % Usage:
            %   powerMW = myLaser.getPower()
            %   [status, powerMW] = myLaser.getPower()
            %
            % Returns:
            %   powerMW - Power setpoint in milliwatts
            
            [status, response] = obj.query('SOUR:POW?');
            
            if status == 0
                powerW = str2double(response);
                powerMW = powerW * 1000; % Convert W to mW
            else
                powerMW = NaN;
            end
            
            if nargout < 2
                status = powerMW;
            end
        end

        function [status, powerMW] = getMeasuredPower(obj)
            % Get measured laser output power in mW
            %
            % Usage:
            %   powerMW = myLaser.getMeasuredPower()
            %   [status, powerMW] = myLaser.getMeasuredPower()
            %
            % Returns:
            %   powerMW - Measured power in milliwatts
            
            [status, response] = obj.query('MEAS:POW?');
            
            if status == 0
                powerW = str2double(response);
                powerMW = powerW * 1000; % Convert W to mW
            else
                powerMW = NaN;
            end
            
            if nargout < 2
                status = powerMW;
            end
        end

        % -----------------------------------------------------------------
        % Power Limit Methods
        % -----------------------------------------------------------------

        function status = setPowerLimit(obj, limitMW)
            % Set maximum power limit in mW
            %
            % Usage:
            %   status = myLaser.setPowerLimit(limitMW)
            %
            % Parameters:
            %   limitMW - Maximum power limit in milliwatts
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                fprintf('  Setting power limit to %.3f mW\n', limitMW);
            end

            % Convert mW to W for SCPI command
            limitW = limitMW / 1000;
            status = obj.write(sprintf('SOUR:POW:LIM %.6f', limitW));

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set power limit failed');
            end
        end

        function [status, limitMW] = getPowerLimit(obj)
            % Get maximum power limit in mW
            %
            % Usage:
            %   limitMW = myLaser.getPowerLimit()
            %   [status, limitMW] = myLaser.getPowerLimit()
            %
            % Returns:
            %   limitMW - Maximum power limit in milliwatts
            
            [status, response] = obj.query('SOUR:POW:LIM?');
            
            if status == 0
                limitW = str2double(response);
                limitMW = limitW * 1000; % Convert W to mW
            else
                limitMW = NaN;
            end
            
            if nargout < 2
                status = limitMW;
            end
        end

        % -----------------------------------------------------------------
        % Temperature Monitoring Methods
        % -----------------------------------------------------------------

        function [status, tempC] = getTemperature(obj)
            % Get laser diode temperature in °C
            %
            % Usage:
            %   tempC = myLaser.getTemperature()
            %   [status, tempC] = myLaser.getTemperature()
            %
            % Returns:
            %   tempC - Temperature in degrees Celsius
            
            [status, response] = obj.query('MEAS:TEMP?');
            
            if status == 0
                tempC = str2double(response);
            else
                tempC = NaN;
            end
            
            if nargout < 2
                status = tempC;
            end
        end

        function [status, tecCurrentA] = getTECCurrent(obj)
            % Get TEC (thermoelectric cooler) current in A
            %
            % Usage:
            %   tecCurrentA = myLaser.getTECCurrent()
            %   [status, tecCurrentA] = myLaser.getTECCurrent()
            %
            % Returns:
            %   tecCurrentA - TEC current in amperes
            
            [status, response] = obj.query('MEAS:TEC:CURR?');
            
            if status == 0
                tecCurrentA = str2double(response);
            else
                tecCurrentA = NaN;
            end
            
            if nargout < 2
                status = tecCurrentA;
            end
        end

        % -----------------------------------------------------------------
        % Temperature Limit Methods
        % -----------------------------------------------------------------

        function status = setTempLimitLow(obj, tempC)
            % Set minimum temperature limit in °C
            %
            % Usage:
            %   status = myLaser.setTempLimitLow(tempC)
            %
            % Parameters:
            %   tempC - Minimum temperature limit in degrees Celsius
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                fprintf('  Setting minimum temperature limit to %.2f °C\n', tempC);
            end

            status = obj.write(sprintf('SOUR:TEMP:LIM:LOW %.3f', tempC));

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set minimum temperature limit failed');
            end
        end

        function [status, tempC] = getTempLimitLow(obj)
            % Get minimum temperature limit in °C
            %
            % Usage:
            %   tempC = myLaser.getTempLimitLow()
            %   [status, tempC] = myLaser.getTempLimitLow()
            %
            % Returns:
            %   tempC - Minimum temperature limit in degrees Celsius
            
            [status, response] = obj.query('SOUR:TEMP:LIM:LOW?');
            
            if status == 0
                tempC = str2double(response);
            else
                tempC = NaN;
            end
            
            if nargout < 2
                status = tempC;
            end
        end

        function status = setTempLimitHigh(obj, tempC)
            % Set maximum temperature limit in °C
            %
            % Usage:
            %   status = myLaser.setTempLimitHigh(tempC)
            %
            % Parameters:
            %   tempC - Maximum temperature limit in degrees Celsius
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                fprintf('  Setting maximum temperature limit to %.2f °C\n', tempC);
            end

            status = obj.write(sprintf('SOUR:TEMP:LIM:HIGH %.3f', tempC));

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set maximum temperature limit failed');
            end
        end

        function [status, tempC] = getTempLimitHigh(obj)
            % Get maximum temperature limit in °C
            %
            % Usage:
            %   tempC = myLaser.getTempLimitHigh()
            %   [status, tempC] = myLaser.getTempLimitHigh()
            %
            % Returns:
            %   tempC - Maximum temperature limit in degrees Celsius
            
            [status, response] = obj.query('SOUR:TEMP:LIM:HIGH?');
            
            if status == 0
                tempC = str2double(response);
            else
                tempC = NaN;
            end
            
            if nargout < 2
                status = tempC;
            end
        end

        % -----------------------------------------------------------------
        % Operating Mode Methods
        % -----------------------------------------------------------------

        function status = setModeConstantCurrent(obj)
            % Set operating mode to constant current
            %
            % Usage:
            %   status = myLaser.setModeConstantCurrent()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Setting mode to constant current');
            end

            status = obj.write('SOUR:FUNC:MODE CURR');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set mode failed');
            end
        end

        function status = setModeConstantPower(obj)
            % Set operating mode to constant power
            %
            % Usage:
            %   status = myLaser.setModeConstantPower()
            
            if ~strcmpi(obj.ShowMessages, 'none')
                disp([obj.DeviceName ':']);
                disp('  Setting mode to constant power');
            end

            status = obj.write('SOUR:FUNC:MODE POW');

            if ~strcmpi(obj.ShowMessages, 'none') && status ~= 0
                disp('  Set mode failed');
            end
        end

        function [status, mode] = getMode(obj)
            % Get current operating mode
            %
            % Usage:
            %   mode = myLaser.getMode()
            %   [status, mode] = myLaser.getMode()
            %
            % Returns:
            %   mode - Operating mode ('CURR' or 'POW')
            
            [status, mode] = obj.query('SOUR:FUNC:MODE?');
            
            if status == 0
                mode = strtrim(mode);
            else
                mode = '';
            end
            
            if nargout < 2
                status = mode;
            end
        end

        % -----------------------------------------------------------------
        % Status and Safety Methods
        % -----------------------------------------------------------------

        function [status, statusByte] = getStatus(obj)
            % Get device status byte
            %
            % Usage:
            %   statusByte = myLaser.getStatus()
            %   [status, statusByte] = myLaser.getStatus()
            %
            % Returns:
            %   statusByte - Status byte value
            
            [status, response] = obj.query('*STB?');
            
            if status == 0
                statusByte = str2double(response);
            else
                statusByte = NaN;
            end
            
            if nargout < 2
                status = statusByte;
            end
        end

        function [status, isClosed] = isInterlockClosed(obj)
            % Check interlock status
            %
            % Usage:
            %   isClosed = myLaser.isInterlockClosed()
            %   [status, isClosed] = myLaser.isInterlockClosed()
            %
            % Returns:
            %   isClosed - true if interlock is closed (safe), false if open
            
            [status, response] = obj.query('SYST:INTL?');
            
            if status == 0
                isClosed = strcmpi(strtrim(response), '1') || ...
                          strcmpi(strtrim(response), 'CLOSED');
            else
                isClosed = false;
            end
            
            if nargout < 2
                status = isClosed;
            end
        end

        function [status, isOverTemp] = isOverTemp(obj)
            % Check over-temperature condition
            %
            % Usage:
            %   isOverTemp = myLaser.isOverTemp()
            %   [status, isOverTemp] = myLaser.isOverTemp()
            %
            % Returns:
            %   isOverTemp - true if over-temperature detected, false otherwise
            
            [status, response] = obj.query('SYST:TEMP:PROT?');
            
            if status == 0
                isOverTemp = strcmpi(strtrim(response), '1') || ...
                            strcmpi(strtrim(response), 'ON');
            else
                isOverTemp = false;
            end
            
            if nargout < 2
                status = isOverTemp;
            end
        end

        % -----------------------------------------------------------------
        % Property Accessors
        % -----------------------------------------------------------------

        function errorMsgs = get.ErrorMessages(obj)
            % Get error messages from device
            errorMsgs = {};
            
            % Read all errors from queue
            for i = 1:10 % Max 10 errors
                [~, msg] = obj.query('SYST:ERR?');
                if contains(msg, '0,') || contains(lower(msg), 'no error')
                    break;
                end
                errorMsgs{end+1} = strtrim(msg); %#ok<AGROW>
            end
            
            if isempty(errorMsgs)
                errorMsgs = {'No errors'};
            end
        end

    end
end
