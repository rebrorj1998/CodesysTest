

{attribute 'io_function_block'}
FUNCTION_BLOCK FB_PhysicalDigitalInput EXTENDS FB_BaseObject IMPLEMENTS IExecuteAutomatically
VAR_INPUT
	in : REFERENCE TO BOOL;
	simulate : BOOL;
	simValue : BOOL;
	debounceEnable : BOOL;	// 
	debounceTime : REAL := 50.0;		// Debounce time in MS
END_VAR
VAR_OUTPUT
	Active : BOOL;
	OSR : BOOL;
	OSF : BOOL;
END_VAR
VAR
	debounceTimer : TON;
	inputONS : FB_ONS();
END_VAR



METHOD Execute
VAR_INPUT
END_VAR

IF NOT __ISVALIDREF(in) THEN
	RETURN;
END_IF

debounceTimer(IN := (in AND NOT simulate) OR (simulate AND simValue) AND debounceEnable, PT := REAL_TO_TIME(debounceTime * 1000));
inputONS();

IF debounceEnable THEN
	Active := debounceTimer.Q;
ELSE
	IF simulate THEN
		Active := simValue;
		inputONS.CLK := simValue;
	ELSE
		Active := in;
		inputONS.CLK := in;
		
	END_IF
END_IF


IF inputONS.OSR THEN
    _logger.AddLogItem(CONCAT(_prefix, 'On'));
END_IF

IF inputONS.OSF THEN
    _logger.AddLogItem(CONCAT(_prefix, 'Off'));
END_IF

{attribute 'monitoring' := 'variable'}
PROPERTY IsOn : BOOL

{attribute 'monitoring' := 'variable'}
PROPERTY IsOff : BOOL