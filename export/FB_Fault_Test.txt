

{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Fault FB'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='5000'}
FUNCTION_BLOCK FB_Fault_Test EXTENDS TM.Testcase_Base
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
    eError : FB_Fault_Test_Errors;
    sError : STRING;
    eFailureMode : TM.FAILUREMODE;
END_VAR
VAR
	faultToTest : FB_Fault(name := 'Test Fault');
END_VAR

SUPER^();


{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();
faultToTest.Execute();
THIS^.diTestCaseCount := 3;
CASE diTestCaseIndex OF
    0: // Test Case #0
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Check Fault is not active';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			IF NOT faultToTest.FaultActive THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Fault Active before Trigger';
				xError := TRUE;
				eError := FB_Fault_Test_Errors.Fault_Active;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: // Test Case #1
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Trigger Fault';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			faultToTest.Trigger();
			IF faultToTest.FaultActive THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Fault Failed to Trigger';
				xError := TRUE;
				eError := FB_Fault_Test_Errors.Fault_Not_Triggered;
				eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 2;
			END_IF
       END_IF
	   
	2:	//
		IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: Reset Fault';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			faultToTest.Ack();
			faultToTest.Execute();
			IF NOT faultToTest.FaultActive THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Fault did not reset';
				xError := TRUE;
				eError := FB_Fault_Test_Errors.Fault_Not_Reset;
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
            eError := FB_Fault_Test_Errors.Fault_Not_Reset;
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
eError := FB_Fault_Test_Errors.No_Error;

{attribute 'hide'}
{warning 'Add method implementation '}
METHOD prvStart : BOOL

