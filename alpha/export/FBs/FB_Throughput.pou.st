(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_Throughput
VAR_INPUT
	inCycle : BOOL;
	runtimeTimeout : REAL := 5.0;
	reset : BOOL;
END_VAR
VAR_OUTPUT
	BPM : REAL;
	BPMCycles : UDINT;
	BPMSeconds : UDINT;
	BPMIndication : STRING;
END_VAR
VAR
	resetRuntime : BOOL;
	resetRuntimeTimer : TON := (PT := T#0S);
	runtimeTimeoutTimer : Standard.TON;
	runtimeTimer : Standard.TON;
	actualRuntimeTimer : Standard.TON;
	timeoutONS : FB_ONS;
	inCycleONS : FB_ONS;
	runtimeSeconds : UDINT;
	runtimeMinutes : UDINT;
	runtimeHours : UDINT;
	runtimeDays : UDINT;
	runtimeSubtractedToGetFiveSeconds : UDINT;
	cycleStarted : BOOL;
	totalTempH : UDINT;
	totalTempM : UDINT;
	totalTempS : UDINT;	
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Runtime calculation. The goal is to capture actual runtime of the machine (i.e being used, including loading time)
inCycleONS(CLK := inCycle);
// Reset timeout time 
IF inCycleONS.OSR THEN
	resetRuntime := TRUE;
	cycleStarted := TRUE;
	BPMCycles := BPMCycles + 1;
END_IF;

// After timeout, assume machine in unmanned
runtimeTimeoutTimer(IN := NOT resetRuntime, PT := TO_TIME(runtimeTimeout * 1000.0));
resetRuntime := FALSE;
timeoutONS(CLK := runtimeTimeoutTimer.Q);

// 1 second ticker while being used.
actualRuntimeTimer(IN := cycleStarted AND NOT actualRuntimeTimer.Q AND NOT runtimeTimeoutTimer.Q, PT := T#1S);

IF actualRuntimeTimer.Q THEN
	BPMSeconds := BPMSeconds + 1;
END_IF;

// Subtract 5 seconds after machine is abandoned
runtimeSubtractedToGetFiveSeconds := ANY_TO_UDINT(ABS(5.0 - runtimeTimeout));

IF timeoutONS.OSR THEN
	IF BPMSeconds > runtimeSubtractedToGetFiveSeconds THEN
		BPMSeconds := BPMSeconds - runtimeSubtractedToGetFiveSeconds;
	END_IF;
	cycleStarted := FALSE;
END_IF;

IF reset THEN
	BPMSeconds := 0;
	BPMCycles := 0;
END_IF;


// Concat to string for display
runtimeHours := BPMSeconds / 3600;
runtimeMinutes := (BPMSeconds MOD 3600) / 60;
runtimeSeconds := BPMSeconds MOD 60;

IF BPMSeconds <> 0 THEN
	BPM := ANY_TO_REAL(BPMCycles) / (ANY_TO_REAL(BPMSeconds) / 60.0);
ELSE
	BPM := 0.0;
END_IF;
BPMIndication := '';
BPMIndication := ANY_TO_STRING(runtimeHours);
BPMIndication := INSERT(BPMIndication, 'H  ', LEN(BPMIndication) + 2);
BPMIndication := INSERT(BPMIndication, ANY_TO_STRING(runtimeMinutes), LEN(BPMIndication));
BPMIndication := INSERT(BPMIndication, 'M ', LEN(BPMIndication));
BPMIndication := INSERT(BPMIndication, ANY_TO_STRING(runtimeSeconds), LEN(BPMIndication));
BPMIndication := INSERT(BPMIndication, 'S', LEN(BPMIndication));
