(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE EnableAxisOps : BOOL
VAR_INPUT
END_VAR
VAR
	_driveEnabledONS : FB_ONS;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// 250MS wait period from when the status operational bit goes high, until a command can be processed.
_motorExcitationDelayTimer();
_motorExcitationDelayTimer.IN := _startupState = eAZDPowerupState.Operational;
EnableAxisOps := _motorExcitationDelayTimer.Q;

// If E-Stopped, or Comm Failure clear state machine
IF NOT driveEnable OR operational AND (NOT _statusword.voltageEnabled OR NOT _statusword.switchedOn) THEN
	_startupState := eAZDPowerupState.Idle;
END_IF
_driveEnabledONS(CLK := driveEnable);

// Startup state machine
CASE _startupState OF 
	eAZDPowerupState.Idle:
		_controlword.Clear();
		IF _statusword.switchOnDisabled THEN
			IF driveEnable THEN
				_startupState := eAZDPowerupState.Shutdown; // Doesnt mean shutdown
			END_IF
// 		ELSIF _driveEnabledONS.OSR AND _statusword.readyToSwitchOn AND NOT _statusword.switchedOn AND NOT _statusword.operationEnabled  THEN
// 			_startupState := eAZDPowerupState.Shutdown; // Doesnt mean shutdown
		END_IF
	
	eAZDPowerupState.Shutdown:
		_controlword.Shutdown();
		IF _statusword.readyToSwitchOn  THEN
			_startupState := eAZDPowerupState.SwitchOn;
		END_IF
	
	eAZDPowerupState.SwitchOn:
		_controlword.SwitchOn();
		IF _statusword.switchedOn THEN
			_startupState := eAZDPowerupState.SwitchOnEnableOp;
		END_IF
		
	eAZDPowerupState.SwitchOnEnableOp:
		_controlword.SwitchOnEnableOp();
		IF _statusword.operationEnabled THEN
			_startupState := eAZDPowerupState.Operational;
		END_IF
	
END_CASE