


{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}

FUNCTION_BLOCK FB_SimMotor_UnitTests EXTENDS CBM.EtrigA
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
	testee : FB_SimMotor();
	MC_MoveABSTestee : Sharp_Motion.MC_MoveAbsolute;
	MC_MoveABSTorqueTestee : Sharp_Motion.MC_MoveAbsoluteTorqueLimited;
	MC_MoveRELTestee : Sharp_Motion.MC_MoveRelative;
	MC_PowerTestee : Sharp_Motion.MC_Power;
	MC_HomeTestee : Sharp_Motion.MC_Home;
	delayTimer : Standard.TON;
END_VAR
SUPER^();

delayTimer();

testee();

MC_MoveABSTestee(Axis := testee);
MC_MoveABSTorqueTestee(Axis := testee);
MC_MoveRELTestee(Axis := testee);
MC_PowerTestee(Enable := TRUE, Axis := testee);
MC_HomeTestee(Axis := testee);

{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();
MC_MoveRELTestee.Acceleration := 100;
MC_MoveRELTestee.Deceleration := 100;

CASE diTestCaseIndex OF
    0: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Try to move motor before powering up';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			
			MC_MoveRELTestee.Velocity := 1;
			MC_MoveRELTestee.Distance := 5.6;
			MC_MoveRELTestee.Execute := TRUE;
			THIS^.RunTestFBs();
			
			IF testee.ActualPosition = 0 
				AND MC_MoveRELTestee.Error
				AND MC_MoveRELTestee.ErrorID = Sharp_Motion.MC_ERROR.AXIS_NOT_READY 
				THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := Standard.CONCAT('Axis did not error out ', CONCAT(TO_STRING(testee.ActualPosition),CONCAT(TO_STRING(MC_MoveRELTestee.Error), TO_STRING(MC_MoveRELTestee.ErrorID))));
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Power Up and move';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 15000;
			xDone := TRUE;
		ELSE
			MC_PowerTestee.RegulatorOn := TRUE;
			MC_PowerTestee.DriveStart := TRUE;
			RunTestFBs();
			MC_MoveRELTestee.Distance := 5.6;
			MC_MoveRELTestee.Execute := TRUE;
			delayTimer.PT := T#6S;
			delayTimer.IN := TRUE;
			
			IF delayTimer.Q THEN
				IF TO_DINT(testee.ActualPosition * 10) = 56 THEN
					xDone := TRUE;
				ELSE
					THIS^.sError := Standard.CONCAT('Axis did not move: Expected 5.6 got: ',TO_STRING(testee.ActualPosition));
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 1;
				END_IF
			END_IF
			
        END_IF
	   
	2: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) FALSE THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := '';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF

   	3: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 4: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) FALSE THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := '';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
	   
	4: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 5: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) FALSE THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := '';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
		
	5: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 6: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) FALSE THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := '';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
		
	6: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 7: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) FALSE THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := '';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    ELSE
        IF THIS^.diTestCaseIndex < 0 THEN
            THIS^.diTestCaseCount := 2;
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

MC_MoveRELTestee.Execute := FALSE;

RunTestFBs();

{attribute 'hide'}
METHOD prvStart : BOOL



METHOD RunTestFBs
VAR_INPUT
END_VAR

testee();

MC_MoveABSTestee(Axis := testee);
MC_MoveABSTorqueTestee(Axis := testee);
MC_MoveRELTestee(Axis := testee);
MC_PowerTestee(Enable := TRUE, Axis := testee);
MC_HomeTestee(Axis := testee);