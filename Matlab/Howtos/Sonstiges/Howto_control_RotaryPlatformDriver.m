%% Howto control the rotary platform using RotaryPlatformDriver class
% 2026-01-18
% HTW Dresden - Prof. Florian Römer
%
% Requirements: RotaryPlatformDriver, VisaIF, HTWD-DT-2025 connected to COM13

%% Clean workspace

clear;
close all;
clc;

%% Connect and get device ID

% Create object and connect to COM13 (115200 baud, 8N1, CR/LF)
% Change 'COM13' to 'COM7' if needed
myPlatform = RotaryPlatformDriver('COM13');

% Get and display device ID
deviceID = myPlatform.getDeviceID();
disp(['Connected to device: ' deviceID]);

%% Move to specific angle
targetAngle = 90; % degrees
disp(['Moving to angle: ' num2str(targetAngle) ' degrees...']);
myPlatform.moveToAngle(targetAngle, 'speed', 30, 'wait', 'on');

% wait for a moment to ensure movement is complete
pause(8);

% Get and display current angle
currentAngle = myPlatform.getCurrentAngle();
disp(['Current angle: ' num2str(currentAngle) ' degrees']);


%% Check motor and error status

motorEnabled = myPlatform.isMotorEnabled();
fprintf('Motor enabled: %d\n', motorEnabled);

error = myPlatform.getError();
disp(['Error status: ' error]);


%% End
myPlatform.delete();
disp('Done.');
