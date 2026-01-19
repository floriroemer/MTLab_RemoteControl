classdef RotaryPlatformDriver < handle
%ROTARYPLATFORMDRIVER Control interface for HTWD-DT-2025 rotary platform
%
%   For full HTML documentation, run: RotaryPlatformDriver.doc
%
%   ROTARYPLATFORMDRIVER provides a MATLAB interface to control a custom
%   rotary platform via serial communication. The class handles all SCPI
%   commands for position control, limit configuration, and status queries.
%
%   The device communicates at 115200 baud, 8N1, LF terminator and
%   echoes every command sent to it.
%
%   BASIC USAGE:
%       platform = RotaryPlatformDriver('COM13');
%       platform.setAngle(90);
%       pos = platform.getPosition();
%       platform.delete();
%
%   ADVANCED USAGE:
%       % Configure safety limits
%       platform = RotaryPlatformDriver('COM7');
%       upper = platform.getUpperLimit();
%       lower = platform.getLowerLimit();
%       
%       % Move to position and wait
%       platform.setAngle(180);
%       pause(2);
%       reached = platform.isReached();
%       
%       % Check motor status
%       enabled = platform.isMotorEnabled();
%
%   SEE ALSO:
%       serialport, configureTerminator
%
    
    properties(Constant = true)
        RotaryPlatformDriverVersion = '2.0.0';
        RotaryPlatformDriverDate    = '2026-01-19';
    end
    
    properties(Access = private)
        SerialObj       % serialport object
        ComPort char    % COM port name
    end

    methods(Static)
        function doc(className)
            %DOC Open HTML documentation in browser
            %
            %   DOC() opens the RotaryPlatformDriver documentation.
            %   DOC(CLASSNAME) opens documentation for specified class.
            %
            %   This method opens the HTML documentation file using
            %   MATLAB's web browser.
            %
            %   Example:
            %       RotaryPlatformDriver.doc()
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
                error('RotaryPlatformDriver:doc', ...
                    'HTML documentation file not found: %s.html', className);
            end
        end
    end

    methods
        function obj = RotaryPlatformDriver(comPort)
            %ROTARYPLATFORMDRIVER Constructor
            %
            %   OBJ = ROTARYPLATFORMDRIVER(COMPORT) creates a connection
            %   to the rotary platform on the specified COM port.
            %
            %   Connection settings: 115200 baud, 8N1, no flow control,
            %   LF terminator.
            %
            %   Example:
            %       platform = RotaryPlatformDriver('COM13');
            %
            
            if nargin < 1 || isempty(comPort)
                comPort = 'COM13';  % Default
            end
            
            obj.ComPort = comPort;
            
            % Create serial port connection
            obj.SerialObj = serialport(comPort, 115200);
            
            % Configure serial settings - device uses LF terminator
            configureTerminator(obj.SerialObj, "LF");
            obj.SerialObj.Timeout = 5;  % seconds
            
            % Clear any pending data
            flush(obj.SerialObj);
            
            fprintf('RotaryPlatformDriver connected to %s\n', comPort);
            fprintf('Settings: 115200 baud, 8N1, LF terminator, Timeout=%ds\n', obj.SerialObj.Timeout);
            
            % Test connection
            try
                fprintf('Sending *IDN? command...\n');
                id = obj.getID();
                fprintf('Device: %s\n', id);
            catch ME
                warning('RotaryPlatformDriver:connection', ...
                    'Could not communicate with device on %s:\n%s\nCheck: 1) Device is powered on, 2) Correct COM port, 3) No other program is using the port', ...
                    comPort, ME.message);
            end
        end

        function delete(obj)
            %DELETE Destructor - close serial connection
            %
            %   DELETE(OBJ) closes the serial port connection and
            %   cleans up resources.
            %
            if ~isempty(obj.SerialObj) && isvalid(obj.SerialObj)
                flush(obj.SerialObj);
                delete(obj.SerialObj);
                fprintf('RotaryPlatformDriver disconnected from %s\n', obj.ComPort);
            end
        end

        % -----------------------------------------------------------------
        % Methods for device commands
        % -----------------------------------------------------------------
        
        function idString = getID(obj)
            %GETID Get device identification string
            %
            %   ID = GETID(OBJ) queries the device identification.
            %
            %   Returns a string like:
            %   'HTW Dresden,MockDevice,SN12345,FW_V1.0,HW_V1.0'
            %
            idString = obj.queryDevice('*IDN?');
        end
        
        function errorMsg = getError(obj)
            %GETERROR Get error from error queue
            %
            %   MSG = GETERROR(OBJ) queries the device error queue.
            %
            %   Returns: '0,"No error"' or error code with message
            %
            errorMsg = obj.queryDevice('SYSTem:ERRor?');
        end
        
        function lockLocal(obj)
            %LOCKLOCAL Lock local control at device
            %
            %   LOCKLOCAL(OBJ) disables the physical buttons on the
            %   device, forcing remote-only control.
            %
            obj.writeDevice('SYSTem:LOCal:LOCK');
        end
        
        function unlockLocal(obj)
            %UNLOCKLOCAL Unlock local control at device
            %
            %   UNLOCKLOCAL(OBJ) re-enables the physical buttons on
            %   the device.
            %
            obj.writeDevice('SYSTem:LOCal:UNLock');
        end
        
        function locked = isLocked(obj)
            %ISLOCKED Query if local control is locked
            %
            %   LOCKED = ISLOCKED(OBJ) returns true if the device's
            %   physical buttons are locked, false otherwise.
            %
            response = obj.queryDevice('SYSTem:LOCal:LOCK?');
            locked = str2double(response) == 1;
        end
        
        function setAngle(obj, angle)
            %SETANGLE Set target angle in degrees
            %
            %   SETANGLE(OBJ, ANGLE) commands the platform to move to
            %   the specified angle in degrees.
            %
            %   ANGLE: target angle (-360 to 360 degrees)
            %
            %   Example:
            %       platform.setAngle(90);
            %
            obj.writeDevice(['ROTAtion:ANGLE ' num2str(angle)]);
        end
        
        function angle = getTargetAngle(obj)
            %GETTARGETANGLE Query target angle in degrees
            %
            %   ANGLE = GETTARGETANGLE(OBJ) returns the currently
            %   commanded target angle.
            %
            response = obj.queryDevice('ROTAtion:ANGLE?');
            angle = str2double(response);
        end
        
        function angle = getPosition(obj)
            %GETPOSITION Query actual position in degrees
            %
            %   POS = GETPOSITION(OBJ) returns the current actual
            %   position of the platform in degrees.
            %
            response = obj.queryDevice('ROTAtion:POSition?');
            angle = str2double(response);
        end
        
        function reached = isReached(obj)
            %ISREACHED Query if target position is reached and held
            %
            %   REACHED = ISREACHED(OBJ) returns true if the platform
            %   has reached the target position and is holding it,
            %   false otherwise.
            %
            response = obj.queryDevice('ROTAtion:REACHED?');
            reached = str2double(response) == 1;
        end
        
        function setUpperLimit(obj, angle)
            %SETUPPERLIMIT Set upper angle safety limit
            %
            %   SETUPPERLIMIT(OBJ, ANGLE) configures the maximum
            %   allowed angle in degrees.
            %
            %   ANGLE: upper limit (-360 to 360 degrees)
            %
            obj.writeDevice(['ROTAtion:LIMit:UPPer ' num2str(angle)]);
        end
        
        function angle = getUpperLimit(obj)
            %GETUPPERLIMIT Query upper angle safety limit
            %
            %   ANGLE = GETUPPERLIMIT(OBJ) returns the configured
            %   upper angle limit in degrees.
            %
            response = obj.queryDevice('ROTAtion:LIMit:UPPer?');
            angle = str2double(response);
        end
        
        function setLowerLimit(obj, angle)
            %SETLOWERLIMIT Set lower angle safety limit
            %
            %   SETLOWERLIMIT(OBJ, ANGLE) configures the minimum
            %   allowed angle in degrees.
            %
            %   ANGLE: lower limit (-360 to 360 degrees)
            %
            obj.writeDevice(['ROTAtion:LIMit:LOWer ' num2str(angle)]);
        end
        
        function angle = getLowerLimit(obj)
            %GETLOWERLIMIT Query lower angle safety limit
            %
            %   ANGLE = GETLOWERLIMIT(OBJ) returns the configured
            %   lower angle limit in degrees.
            %
            response = obj.queryDevice('ROTAtion:LIMit:LOWer?');
            angle = str2double(response);
        end
        
        function enabled = isMotorEnabled(obj)
            %ISMOTORENABLED Query if motor is currently active
            %
            %   ENABLED = ISMOTORENABLED(OBJ) returns true if the
            %   motor is currently active (AND combination of:
            %   enableLocal, enableRemote, and NOT voltLockout).
            %
            response = obj.queryDevice('MOTOR:ENABLED?');
            enabled = str2double(response) == 1;
        end
        
        function enabled = isMotorEnableLocal(obj)
            %ISMOTORENABLELOCAL Query if green enable button is pressed
            %
            %   ENABLED = ISMOTORENABLELOCAL(OBJ) returns true if the
            %   green motor enable button is currently pressed.
            %
            response = obj.queryDevice('MOTOR:ENABLELOCal?');
            enabled = str2double(response) == 1;
        end
        
        function setMotorEnableLocal(obj, enable)
            %SETMOTORENABLELOCAL Set local motor enable status remotely
            %
            %   SETMOTORENABLELOCAL(OBJ, ENABLE) enables or disables
            %   the motor lock remotely, allowing or preventing manual
            %   movement of the stepper motor.
            %
            %   ENABLE: true/1 to unlock motor (allow manual movement)
            %           false/0 to lock motor (prevent manual movement)
            %
            %   Example:
            %       platform.setMotorEnableLocal(true);  % Unlock motor
            %       platform.setMotorEnableLocal(false); % Lock motor
            %
            value = double(logical(enable));
            obj.writeDevice(['MOTOR:ENABLELOCal ' num2str(value)]);
        end
        
        function enabled = isMotorEnableRemote(obj)
            %ISMOTORENABLEREMOTE Query remote motor enable status
            %
            %   ENABLED = ISMOTORENABLEREMOTE(OBJ) returns true if the
            %   motor is enabled from remote interface, false if remote
            %   lockout is active.
            %
            response = obj.queryDevice('MOTOR:ENABLEREMote?');
            enabled = str2double(response) == 1;
        end
        
        function setMotorEnableRemote(obj, enable)
            %SETMOTORENABLEREMOTE Set remote motor enable status
            %
            %   SETMOTORENABLEREMOTE(OBJ, ENABLE) enables or disables
            %   the motor from remote interface.
            %
            %   ENABLE: true/1 to enable motor, false/0 to lock motor
            %           When locked, a message appears on LCD and the
            %           green button LED turns off.
            %
            %   Example:
            %       platform.setMotorEnableRemote(false); % Lock motor
            %       platform.setMotorEnableRemote(true);  % Unlock motor
            %
            value = double(logical(enable));
            obj.writeDevice(['MOTOR:ENABLEREMote ' num2str(value)]);
        end
        
        function lockout = isMotorVoltLockout(obj)
            %ISMOTORVOLTLOCKOUT Query if under-voltage lockout is active
            %
            %   LOCKOUT = ISMOTORVOLTLOCKOUT(OBJ) returns true if
            %   under-voltage condition exists and motor cannot be
            %   activated. A message appears on LCD when active.
            %
            response = obj.queryDevice('MOTOR:VOLTLOCKout?');
            lockout = str2double(response) == 1;
        end
        
    end

    methods (Access = private)
        function writeDevice(obj, cmd)
            % Write command to device (handles echo if present)
            writeline(obj.SerialObj, cmd);
            pause(0.05);
            
            % Try to read echo (device echoes commands)
            try
                if obj.SerialObj.NumBytesAvailable > 0
                    readline(obj.SerialObj);  % Discard echo
                end
            catch
                % No echo or error - continue
            end
        end
        
        function response = queryDevice(obj, cmd)
            % Query device - try to handle echo if present
            
            % Clear any stale data
            flush(obj.SerialObj);
            
            % Send command
            writeline(obj.SerialObj, cmd);
            
            % Small delay to let device process
            pause(0.1);
            
            % Check if data is available
            if obj.SerialObj.NumBytesAvailable == 0
                error('RotaryPlatformDriver:queryDevice', ...
                    'No response from device for command "%s". Check connection and baud rate.', cmd);
            end
            
            % Read first line - could be echo or response
            try
                firstLine = strtrim(char(readline(obj.SerialObj)));
            catch ME
                error('RotaryPlatformDriver:queryDevice', ...
                    'Failed to read from device for command "%s": %s', cmd, ME.message);
            end
            
            % Check if device echoes: if first line matches command, read next line
            if strcmp(firstLine, cmd)
                % Device echoes - read actual response
                try
                    response = strtrim(char(readline(obj.SerialObj)));
                catch ME
                    error('RotaryPlatformDriver:queryDevice', ...
                        'Failed to read response after echo for command "%s": %s', cmd, ME.message);
                end
            else
                % No echo - first line is the response
                response = firstLine;
            end
        end
    end
end
