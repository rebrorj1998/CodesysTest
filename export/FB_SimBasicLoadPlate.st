

FUNCTION_BLOCK FB_SimBasicLoadPlate EXTENDS FB_BaseComponent IMPLEMENTS IRetractingLoadPlate, IExecuteAutomatically
VAR_INPUT
	loadPlateDwell : REAL := 2.5;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	beginDischarge : FB_SimulatedFeedback(name := CONCAT(_prefix,'Begin Discharge'));
END_VAR



PROPERTY ReadyToLoad : BOOL


METHOD Execute

SUPER^.Execute();
beginDischarge();

METHOD BeginDischarge

ClearStatus();
beginDischarge.maxDelay := TO_INT(loadPlateDwell * 1000.0 + 600.0);  
beginDischarge.minDelay := TO_INT(loadPlateDwell * 1000.0 + 400.0);   
beginDischarge.in := TRUE;

METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR

beginDischarge.in := FALSE;
THIS^.Execute();

FUNCTION_BLOCK FB_SimBasicLoadPlate EXTENDS FB_BaseComponent IMPLEMENTS IRetractingLoadPlate, IExecuteAutomatically
VAR_INPUT
	loadPlateDwell : REAL := 2.5;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	beginDischarge : FB_SimulatedFeedback(name := CONCAT(_prefix,'Begin Discharge'));
END_VAR



PROPERTY ReadyToLoad : BOOL


METHOD Execute

SUPER^.Execute();
beginDischarge();

METHOD BeginDischarge

ClearStatus();
beginDischarge.maxDelay := TO_INT(loadPlateDwell * 1000.0 + 600.0);  
beginDischarge.minDelay := TO_INT(loadPlateDwell * 1000.0 + 400.0);   
beginDischarge.in := TRUE;

METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR

beginDischarge.in := FALSE;
THIS^.Execute();