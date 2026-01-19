%% Howto: Control ComboSource 6301 Laser Controller
% This script demonstrates how to control the ComboSource 6301 laser
% controller using the ComboSource6301 MATLAB class
%
% HTW Dresden - Faculty of Electrical Engineering
% Date: 2026-01-19

%% 1. Create Object and Connect to Device
% Replace 'combosource' with the device name from your config file
myLaser = ComboSource6301('combosource');

% Display class version
fprintf('ComboSource6301 Class Version: %s (%s)\n', ...
    myLaser.ComboSourceVersion, myLaser.ComboSourceDate);

%% 2. Get Device Identification
idString = myLaser.getID();
fprintf('Device ID: %s\n', idString);

%% 3. Clear any previous errors
myLaser.clear();

%% 4. Check Safety: Interlock Status
interlockClosed = myLaser.isInterlockClosed();
if interlockClosed
    disp('✓ Interlock is closed - safe to proceed');
else
    warning('✗ Interlock is open - cannot enable laser!');
    return;
end

%% 5. Set Operating Mode to Constant Current
myLaser.setModeConstantCurrent();
mode = myLaser.getMode();
fprintf('Operating mode: %s\n', mode);

%% 6. Configure Current Settings
% Set maximum current limit (safety)
myLaser.setCurrentLimit(150);  % 150 mA maximum
currentLimit = myLaser.getCurrentLimit();
fprintf('Current limit set to: %.2f mA\n', currentLimit);

% Set desired operating current
myLaser.setCurrent(100);  % 100 mA setpoint
currentSetpoint = myLaser.getCurrent();
fprintf('Current setpoint: %.2f mA\n', currentSetpoint);

%% 7. Configure Temperature Limits
myLaser.setTempLimitLow(15);   % Minimum temperature 15°C
myLaser.setTempLimitHigh(35);  % Maximum temperature 35°C

tempLimitLow = myLaser.getTempLimitLow();
tempLimitHigh = myLaser.getTempLimitHigh();
fprintf('Temperature limits: %.1f°C to %.1f°C\n', tempLimitLow, tempLimitHigh);

%% 8. Lock Front Panel (optional)
% Prevents accidental changes during remote operation
myLaser.lock();
disp('Front panel locked');

%% 9. Enable Laser Output
disp(' ');
disp('--- Enabling Laser ---');
myLaser.enableLaser();

% Verify laser is enabled
if myLaser.isLaserEnabled()
    disp('✓ Laser output is ON');
else
    warning('✗ Laser failed to enable');
    return;
end

%% 10. Monitor Laser Parameters
disp(' ');
disp('Monitoring laser parameters for 10 seconds...');
disp('Time(s)  Current(mA)  Power(mW)  Temp(°C)  TEC(A)');
disp('-------  -----------  ---------  --------  ------');

for t = 1:10
    current = myLaser.getMeasuredCurrent();
    power = myLaser.getMeasuredPower();
    temp = myLaser.getTemperature();
    tecCurrent = myLaser.getTECCurrent();
    
    fprintf('%4d     %8.2f     %7.2f    %6.2f   %6.3f\n', ...
        t, current, power, temp, tecCurrent);
    
    % Check for over-temperature
    if myLaser.isOverTemp()
        warning('Over-temperature detected!');
        break;
    end
    
    pause(1);
end

%% 11. Demonstrate Mode Switching
disp(' ');
disp('--- Switching to Constant Power Mode ---');

% Switch to constant power mode
myLaser.setModeConstantPower();

% Set power limit and setpoint
myLaser.setPowerLimit(50);  % 50 mW maximum
myLaser.setPower(30);       % 30 mW setpoint

fprintf('Power limit: %.2f mW\n', myLaser.getPowerLimit());
fprintf('Power setpoint: %.2f mW\n', myLaser.getPower());

% Monitor for a few seconds
pause(3);
measuredPower = myLaser.getMeasuredPower();
fprintf('Measured power: %.2f mW\n', measuredPower);

%% 12. Disable Laser Output
disp(' ');
disp('--- Disabling Laser ---');
myLaser.disableLaser();

% Verify laser is disabled
if ~myLaser.isLaserEnabled()
    disp('✓ Laser output is OFF');
else
    warning('✗ Laser failed to disable');
end

%% 13. Unlock Front Panel
myLaser.unlock();
disp('Front panel unlocked');

%% 14. Check for Device Errors
errors = myLaser.ErrorMessages;
if strcmp(errors{1}, 'No errors')
    disp('✓ No device errors');
else
    disp('Device errors:');
    for i = 1:length(errors)
        fprintf('  %s\n', errors{i});
    end
end

%% 15. Close Connection
myLaser.delete;
disp(' ');
disp('Connection closed');

%% Additional Examples

%% Example: Using Low-Level SCPI Commands
% You can also use inherited VisaIF methods for custom commands
%
% myLaser.write('OUTP ON');        % Enable output
% response = myLaser.query('MEAS:CURR?');  % Query current
% fprintf('Current: %s\n', response);

%% Example: Error Handling with Try-Catch
% try
%     myLaser = ComboSource6301('combosource');
%     myLaser.enableLaser();
%     % ... your code here ...
%     myLaser.disableLaser();
%     myLaser.delete;
% catch ME
%     fprintf('Error: %s\n', ME.message);
%     if exist('myLaser', 'var')
%         try
%             myLaser.disableLaser();
%             myLaser.delete;
%         catch
%         end
%     end
% end
