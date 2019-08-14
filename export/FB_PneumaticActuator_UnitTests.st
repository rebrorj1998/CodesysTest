

(*
*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Base Pneumatic Actuator/Valve'}
{attribute 'testcategory':='Solenoids'}
{attribute 'testcasetimeout':='15000'}
FUNCTION_BLOCK FB_PneumaticActuator_UnitTests EXTENDS CBM.EtrigA
VAR_INPUT
	xGetTestInfo : BOOL;
    diTestCaseIndex : DINT;
END_VAR
VAR_OUTPUT
    sTestCaseName : STRING;
	sTestCaseCategories : STRING;
    diTestCaseCount : DINT;
    diTestCaseTimeout : DINT;
    sInfo : STRING;
	eError : UnitTestErrors;
    sError : STRING;
    eFailureMode : TM.FAILUREMODE;
END_VAR
VAR
	testee : FB_PneumaticActuator(name := 'Unit Test Actuator');
END_VAR
SUPER^();

{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();
THIS^.diTestCaseCount := 3;

CASE diTestCaseIndex OF
    0: // Test Case #0
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Test Initialzed No State';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			IF NOT testee.ExtendAsserted 
				AND NOT testee.RetractAsserted 
				AND NOT testee.IsExtended
				AND NOT testee.IsRetracted
				THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Initialzed with state (Extended or Retracted)';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: // Test Case #1
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Extend Cylinder';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			testee.Extend();
			testee.IsExtended := TRUE;
			IF testee.ExtendAsserted
				AND testee.IsExtended
				AND NOT testee.RetractAsserted
				AND NOT testee.IsRetracted 
				THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Failed to extend';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 2;
			END_IF
       END_IF
	   
	2:	//
		IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: Retract Cylinder';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			testee.Retract();
			testee.IsRetracted := TRUE;
			testee.IsExtended := FALSE;
			IF NOT testee.ExtendAsserted
				AND NOT testee.IsExtended
				AND testee.RetractAsserted
				AND testee.IsRetracted 
				THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Failed to retract';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 3;
			END_IF
       END_IF
    ELSE
        IF THIS^.diTestCaseIndex < 0 THEN
            THIS^.diTestCaseCount := 3;
            xDone := TRUE;
        ELSE
            THIS^.sInfo := 'Invalid test case index';
            eError := UnitTestErrors.Failure;
			xError := TRUE;
        END_IF
END_CASE


{attribute 'hide'}
METHOD prvResetOutputs : BOOL

SUPER^.prvResetOutputs();

sTestCaseName := '';
sTestCaseCategories := '';
diTestCaseCount := 0;
diTestCaseTimeout := 0;
sInfo := '';
sError := '';
eFailureMode := TM.FAILUREMODE.AbortTestCase;

{attribute 'hide'}
METHOD prvStart : BOOL

SUPER^.prvStart();