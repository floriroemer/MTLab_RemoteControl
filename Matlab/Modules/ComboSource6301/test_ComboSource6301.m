%% Test Script for ComboSource6301 Class
% This script tests all methods of the ComboSource6301 class
% Run this after configuring your device to verify functionality
%
% HTW Dresden - Faculty of Electrical Engineering
% Date: 2026-01-19
%
% NOTE: This script will NOT actually enable the laser for safety.
%       Uncomment laser enable sections if you want full testing.

clear;
clc;

fprintf('ComboSource6301 Class Test Script\n');
fprintf('==================================\n\n');

%% Test 1: Class Construction
fprintf('Test 1: Class Construction\n');
fprintf('--------------------------\n');

try
    % Attempt to list available devices
    fprintf('Listing configured devices...\n');
    VisaIF.listContentOfConfigFiles;
    
    % Create object (replace 'combosource' with your device name)
    fprintf('\nAttempting to connect to device...\n');
    myLaser = ComboSource6301('combosource');
    
    fprintf('✓ Successfully created ComboSource6301 object\n');
    fprintf('  Version: %s\n', myLaser.ComboSourceVersion);
    fprintf('  Date: %s\n\n', myLaser.ComboSourceDate);
    
catch ME
    fprintf('✗ Failed to create object: %s\n', ME.message);
    fprintf('  Make sure device is configured in VisaIF config files\n');
    fprintf('  See Configuration_Guide.txt for details\n\n');
    return;
end

%% Test 2: Device Identification
fprintf('Test 2: Device Identification\n');
fprintf('-----------------------------\n');

try
    idString = myLaser.getID();
    fprintf('✓ Device ID: %s\n\n', idString);
catch ME
    fprintf('✗ getID failed: %s\n\n', ME.message);
end

%% Test 3: Clear Status
fprintf('Test 3: Clear Device Status\n');
fprintf('---------------------------\n');

try
    status = myLaser.clear();
    if status == 0
        fprintf('✓ Device status cleared successfully\n\n');
    else
        fprintf('✗ Clear failed with status: %d\n\n', status);
    end
catch ME
    fprintf('✗ clear() failed: %s\n\n', ME.message);
end

%% Test 4: Safety Checks
fprintf('Test 4: Safety Status\n');
fprintf('---------------------\n');

try
    % Check interlock
    interlockClosed = myLaser.isInterlockClosed();
    fprintf('Interlock Status: %s\n', ...
        char(string(interlockClosed).replace("1", "Closed (Safe)").replace("0", "Open (Unsafe)")));
    
    % Check over-temperature
    isOverTemp = myLaser.isOverTemp();
    fprintf('Over-Temperature: %s\n', ...
        char(string(isOverTemp).replace("1", "Fault Detected").replace("0", "Normal")));
    
    fprintf('✓ Safety checks completed\n\n');
catch ME
    fprintf('✗ Safety checks failed: %s\n\n', ME.message);
end

%% Test 5: Operating Mode
fprintf('Test 5: Operating Mode\n');
fprintf('----------------------\n');

try
    % Set to constant current mode
    myLaser.setModeConstantCurrent();
    mode = myLaser.getMode();
    fprintf('Mode set to: %s\n', mode);
    
    % Switch to constant power mode
    myLaser.setModeConstantPower();
    mode = myLaser.getMode();
    fprintf('Mode set to: %s\n', mode);
    
    % Return to constant current
    myLaser.setModeConstantCurrent();
    fprintf('✓ Operating mode control working\n\n');
catch ME
    fprintf('✗ Mode control failed: %s\n\n', ME.message);
end

%% Test 6: Current Settings
fprintf('Test 6: Current Control\n');
fprintf('-----------------------\n');

try
    % Set current limit
    myLaser.setCurrentLimit(150);
    limit = myLaser.getCurrentLimit();
    fprintf('Current Limit: %.2f mA\n', limit);
    
    % Set current setpoint
    myLaser.setCurrent(100);
    setpoint = myLaser.getCurrent();
    fprintf('Current Setpoint: %.2f mA\n', setpoint);
    
    fprintf('✓ Current control working\n\n');
catch ME
    fprintf('✗ Current control failed: %s\n\n', ME.message);
end

%% Test 7: Power Settings
fprintf('Test 7: Power Control\n');
fprintf('---------------------\n');

try
    % Set power limit
    myLaser.setPowerLimit(50);
    limit = myLaser.getPowerLimit();
    fprintf('Power Limit: %.2f mW\n', limit);
    
    % Set power setpoint
    myLaser.setPower(30);
    setpoint = myLaser.getPower();
    fprintf('Power Setpoint: %.2f mW\n', setpoint);
    
    fprintf('✓ Power control working\n\n');
catch ME
    fprintf('✗ Power control failed: %s\n\n', ME.message);
end

%% Test 8: Temperature Limits
fprintf('Test 8: Temperature Limits\n');
fprintf('--------------------------\n');

try
    % Set temperature limits
    myLaser.setTempLimitLow(15);
    myLaser.setTempLimitHigh(35);
    
    lowLimit = myLaser.getTempLimitLow();
    highLimit = myLaser.getTempLimitHigh();
    
    fprintf('Temperature Limits: %.1f°C to %.1f°C\n', lowLimit, highLimit);
    fprintf('✓ Temperature limit control working\n\n');
catch ME
    fprintf('✗ Temperature limit control failed: %s\n\n', ME.message);
end

%% Test 9: Temperature Monitoring (No Laser Required)
fprintf('Test 9: Temperature Monitoring\n');
fprintf('------------------------------\n');

try
    temp = myLaser.getTemperature();
    tecCurrent = myLaser.getTECCurrent();
    
    fprintf('Current Temperature: %.2f °C\n', temp);
    fprintf('TEC Current: %.3f A\n', tecCurrent);
    fprintf('✓ Temperature monitoring working\n\n');
catch ME
    fprintf('✗ Temperature monitoring failed: %s\n\n', ME.message);
end

%% Test 10: Front Panel Lock
fprintf('Test 10: Front Panel Lock\n');
fprintf('-------------------------\n');

try
    myLaser.lock();
    fprintf('✓ Front panel locked\n');
    
    pause(1);
    
    myLaser.unlock();
    fprintf('✓ Front panel unlocked\n\n');
catch ME
    fprintf('✗ Lock/unlock failed: %s\n\n', ME.message);
end

%% Test 11: Laser Enable Status (Without Enabling)
fprintf('Test 11: Laser Status Query\n');
fprintf('---------------------------\n');

try
    isEnabled = myLaser.isLaserEnabled();
    fprintf('Laser Output: %s\n', ...
        char(string(isEnabled).replace("1", "ON").replace("0", "OFF")));
    fprintf('✓ Laser status query working\n\n');
catch ME
    fprintf('✗ Laser status query failed: %s\n\n', ME.message);
end

%% Test 12: Measurements (Laser Off)
fprintf('Test 12: Measurements (Laser OFF)\n');
fprintf('----------------------------------\n');

try
    current = myLaser.getMeasuredCurrent();
    power = myLaser.getMeasuredPower();
    
    fprintf('Measured Current: %.2f mA\n', current);
    fprintf('Measured Power: %.2f mW\n', power);
    fprintf('✓ Measurement queries working\n\n');
catch ME
    fprintf('✗ Measurement queries failed: %s\n\n', ME.message);
end

%% Test 13: Status Byte
fprintf('Test 13: Status Byte\n');
fprintf('--------------------\n');

try
    statusByte = myLaser.getStatus();
    fprintf('Status Byte: %d (0x%X)\n', statusByte, statusByte);
    fprintf('✓ Status byte query working\n\n');
catch ME
    fprintf('✗ Status byte query failed: %s\n\n', ME.message);
end

%% Test 14: Error Messages
fprintf('Test 14: Error Messages\n');
fprintf('-----------------------\n');

try
    errors = myLaser.ErrorMessages;
    fprintf('Error Queue:\n');
    for i = 1:length(errors)
        fprintf('  %d: %s\n', i, errors{i});
    end
    fprintf('✓ Error message query working\n\n');
catch ME
    fprintf('✗ Error message query failed: %s\n\n', ME.message);
end

%% Test 15: Low-Level SCPI Commands (Inherited from VisaIF)
fprintf('Test 15: Low-Level SCPI Commands\n');
fprintf('--------------------------------\n');

try
    % Test direct write
    status = myLaser.write('*CLS');
    fprintf('✓ Direct write command successful (status=%d)\n', status);
    
    % Test direct query
    [status, response] = myLaser.query('*IDN?');
    fprintf('✓ Direct query successful\n');
    fprintf('  Response: %s\n', strtrim(response));
    fprintf('  Status: %d\n\n', status);
catch ME
    fprintf('✗ Low-level commands failed: %s\n\n', ME.message);
end

%% OPTIONAL Test 16: Full Laser Operation (COMMENTED OUT FOR SAFETY)
fprintf('Test 16: Full Laser Operation\n');
fprintf('------------------------------\n');
fprintf('⚠ SKIPPED FOR SAFETY - Uncomment to test laser enable/disable\n');
fprintf('  To test, uncomment the following section:\n\n');

% UNCOMMENT BELOW TO TEST LASER ENABLE/DISABLE
% WARNING: ONLY DO THIS IF YOU HAVE PROPER SAFETY EQUIPMENT!
%{
try
    % Check interlock
    if ~myLaser.isInterlockClosed()
        fprintf('✗ Cannot enable - interlock is open!\n\n');
    else
        % Configure
        myLaser.setModeConstantCurrent();
        myLaser.setCurrentLimit(150);
        myLaser.setCurrent(50);  % Low current for testing
        
        % Enable laser
        fprintf('Enabling laser...\n');
        myLaser.enableLaser();
        
        if myLaser.isLaserEnabled()
            fprintf('✓ Laser enabled successfully\n');
            
            % Monitor for 5 seconds
            fprintf('Monitoring for 5 seconds...\n');
            for i = 1:5
                current = myLaser.getMeasuredCurrent();
                power = myLaser.getMeasuredPower();
                temp = myLaser.getTemperature();
                
                fprintf('  %ds: %.2f mA, %.2f mW, %.2f°C\n', ...
                    i, current, power, temp);
                pause(1);
            end
            
            % Disable laser
            fprintf('Disabling laser...\n');
            myLaser.disableLaser();
            
            if ~myLaser.isLaserEnabled()
                fprintf('✓ Laser disabled successfully\n\n');
            else
                fprintf('✗ Laser failed to disable!\n\n');
            end
        else
            fprintf('✗ Laser failed to enable!\n\n');
        end
    end
catch ME
    fprintf('✗ Laser operation failed: %s\n\n', ME.message);
    try
        myLaser.disableLaser();
    catch
    end
end
%}

%% Test Summary
fprintf('\n');
fprintf('Test Summary\n');
fprintf('============\n');
fprintf('All critical tests completed!\n');
fprintf('See results above for any failures.\n\n');

fprintf('Next Steps:\n');
fprintf('1. If all tests passed, the class is working correctly\n');
fprintf('2. Review Configuration_Guide.txt for setup details\n');
fprintf('3. See ComboSource6301.doc for full documentation\n');
fprintf('4. Run Howto_control_ComboSource6301.m for examples\n');
fprintf('5. Uncomment Test 16 ONLY if you have proper safety equipment\n\n');

%% Cleanup
fprintf('Closing connection...\n');
myLaser.delete;
fprintf('✓ Test complete - connection closed\n');
