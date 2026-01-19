# ComboSource6301 MATLAB Class

## Overview
The **ComboSource6301** class provides comprehensive control of the ComboSource 6301 laser controller via RS-232/USB interface. This professional MATLAB class inherits from VisaIF and offers high-level functions for:

- Laser enable/disable control
- Constant current and constant power modes
- Current and power measurement and control
- Temperature monitoring and limits
- Safety features (interlock, over-temp)
- Error handling and status monitoring

## Quick Start

```matlab
% Connect to device
myLaser = ComboSource6301('combosource');

% Configure and enable
myLaser.setModeConstantCurrent();
myLaser.setCurrentLimit(150);  % 150 mA max
myLaser.setCurrent(100);       % 100 mA setpoint
myLaser.enableLaser();

% Monitor
fprintf('Current: %.2f mA\n', myLaser.getMeasuredCurrent());
fprintf('Power: %.2f mW\n', myLaser.getMeasuredPower());
fprintf('Temp: %.2f °C\n', myLaser.getTemperature());

% Disable and disconnect
myLaser.disableLaser();
myLaser.delete;
```

## Files

```
ComboSource6301/
├── @ComboSource6301/
│   ├── ComboSource6301.m        - Main class file
│   └── ComboSource6301.html     - HTML documentation
├── ComboSource6301_History.txt  - Version history
├── Configuration_Guide.txt      - Setup instructions
└── README.md                    - This file
```

## Installation

1. **Install Prerequisites:**
   - MATLAB R2024a or newer
   - Instrument Control Toolbox
   - NI-VISA 21.5 (download from National Instruments)

2. **Add to MATLAB Path:**
   The MTLab_RemoteControl folder should already be in your path. If not:
   ```matlab
   addpath('C:\Path\To\MTLab_RemoteControl\Matlab\Modules\ComboSource6301');
   ```

3. **Configure Device:**
   - See `Configuration_Guide.txt` for detailed instructions
   - Add device entry to VisaIF configuration file
   - Example for serial connection (COM3):
   ```
   ComboSource6301,Generic,ComboSource6301,COM3,visa-serial,,combosource
   ```

4. **Verify Installation:**
   ```matlab
   % Check if device is configured
   VisaIF.listContentOfConfigFiles
   
   % Test connection
   myLaser = ComboSource6301('combosource');
   disp(myLaser.getID());
   myLaser.delete;
   ```

## Documentation

- **HTML Documentation:** Open in MATLAB with `ComboSource6301.doc`
- **Example Script:** `Howtos/Sonstiges/Howto_control_ComboSource6301.m`
- **Configuration:** See `Configuration_Guide.txt`

## Main Features

### Laser Control
- `enableLaser()` / `disableLaser()` - Turn laser on/off
- `isLaserEnabled()` - Check laser state

### Current Mode
- `setCurrent(mA)` - Set drive current
- `getCurrent()` - Get setpoint
- `getMeasuredCurrent()` - Measure actual current
- `setCurrentLimit(mA)` / `getCurrentLimit()` - Safety limits

### Power Mode
- `setPower(mW)` - Set output power
- `getPower()` - Get setpoint
- `getMeasuredPower()` - Measure actual power
- `setPowerLimit(mW)` / `getPowerLimit()` - Safety limits

### Temperature
- `getTemperature()` - Laser diode temp (°C)
- `getTECCurrent()` - TEC current (A)
- `setTempLimitLow(C)` / `setTempLimitHigh(C)` - Limits

### Safety
- `isInterlockClosed()` - Check interlock
- `isOverTemp()` - Check over-temperature
- `lock()` / `unlock()` - Front panel lock

### Configuration
- `setModeConstantCurrent()` / `setModeConstantPower()` - Operating mode
- `getMode()` - Query current mode
- `reset()` - Factory defaults
- `clear()` - Clear errors

## Method Summary

**Total: 28 methods**

| Category | Count | Methods |
|----------|-------|---------|
| Constructor | 2 | ComboSource6301, delete |
| Device Info | 4 | getID, getError, clear, reset |
| Laser Control | 3 | enableLaser, disableLaser, isLaserEnabled |
| Current Control | 5 | setCurrent, getCurrent, getMeasuredCurrent, setCurrentLimit, getCurrentLimit |
| Power Control | 5 | setPower, getPower, getMeasuredPower, setPowerLimit, getPowerLimit |
| Temperature | 6 | getTemperature, getTECCurrent, setTempLimitLow/High, getTempLimitLow/High |
| Operating Mode | 3 | setModeConstantCurrent, setModeConstantPower, getMode |
| Safety/Status | 5 | getStatus, isInterlockClosed, isOverTemp, lock, unlock |

## Usage Examples

See `Howtos/Sonstiges/Howto_control_ComboSource6301.m` for complete examples including:

1. Basic connection and identification
2. Constant current operation
3. Constant power operation
4. Temperature monitoring
5. Safety checks and error handling
6. Real-time monitoring with plots

## Safety Warnings

⚠️ **LASER SAFETY:**
- Always check interlock before enabling
- Never operate without proper safety equipment
- Always disable laser before disconnecting
- Monitor temperature to prevent overheating
- Use appropriate current/power limits

## Properties

- `ComboSourceVersion` - Class version (read-only)
- `ComboSourceDate` - Release date (read-only)
- `ErrorMessages` - Device error queue (read-only)

## Inherited from VisaIF

All VisaIF methods are available:
- `write(command)` - Send SCPI command
- `query(command)` - Send query and read response
- `read()` - Read from device
- Plus many more (see `VisaIF.doc`)

## Troubleshooting

**Cannot connect to device:**
1. Check NI-VISA is installed
2. Verify COM port or USB connection
3. Check device power and cable
4. Test with NI MAX (VISA Test Panel)
5. Verify configuration file entry

**Laser won't enable:**
1. Check interlock: `myLaser.isInterlockClosed()`
2. Check temperature: `myLaser.getTemperature()`
3. Check errors: `myLaser.ErrorMessages`
4. Verify limits are set correctly

**Communication errors:**
1. Try `myLaser.clrdevice()` to clear buffers
2. Check VISA resource name in config file
3. Verify baud rate for serial connection
4. Test with low-level commands: `myLaser.query('*IDN?')`

## Version History

**Version 1.0.0 (2026-01-19)**
- Initial release
- Full laser controller support
- 28 methods for comprehensive control
- Complete HTML documentation
- Example scripts and configuration guide

## System Requirements

- **Software:**
  - MATLAB R2024a or newer
  - Instrument Control Toolbox 24.1
  - NI-VISA 21.5
  - VisaIF class version 3.0.0+

- **Hardware:**
  - ComboSource 6301 laser controller
  - RS-232, USB, or TCPIP connection

## Support

For questions, bug reports, or feature requests:
- HTW Dresden, Faculty of Electrical Engineering
- Prof. Matthias Henker

## Related Classes

- `VisaIF` - Base class for VISA communication
- `FGen` - Function generator control
- `Scope` - Oscilloscope control
- `SMU24xx` - Source measure unit control
- `RotaryPlatformDriver` - Rotary platform control

## License

Part of MTLab_RemoteControl toolbox
HTW Dresden - Faculty of Electrical Engineering

---

*Documentation generated: 2026-01-19*
