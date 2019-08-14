

{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}
FUNCTION_BLOCK FB_MonostableMultivibrator_UnitTests EXTENDS CBM.ETrigA
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
	monoMulti : FB_MonostableMultivibrator(name := 'FB_MonostableMultovibrotor Under Test');
	testDwellTimer : Standard.TON;
	testPostDwellTimer : Standard.TON;
	testDelayTimer : Standard.TON;
	triggered : BOOL;
END_VAR

SUPER^();
testDwellTimer();
testPostDwellTimer();
testDelayTimer();
monoMulti();


{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();
THIS^.diTestCaseCount := 5;

CASE diTestCaseIndex OF
    0: // Test Case #0
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Test Manual On';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
			xDone := TRUE;
		ELSE
			monoMulti.ManualOn();
			monoMulti();
			IF monoMulti.Q THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Output should be on';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: // Test Case #1
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Test Manual Off';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			monoMulti.ManualOff();
			monoMulti();
			IF NOT monoMulti.Q THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Output should be off';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 2;
			END_IF
       END_IF
	   
	2:	//
		IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: Start Trigger, Test Delay';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			xBusy := TRUE;
			monoMulti.DwellSetting := 2000;
			monoMulti.DelaySetting := 500;
			IF NOT triggered THEN
				monoMulti.Trigger();
				triggered := TRUE;
			END_IF
			
			testDelayTimer.PT := T#450MS;
			testDelayTimer.IN := TRUE;
			testDwellTimer.PT := T#1700MS; 
			testDwellTimer.IN := TRUE;
			testPostDwellTimer.PT := T#2550MS;
			testPostDwellTimer.IN := TRUE;
			IF testDelayTimer.Q THEN
				IF NOT monoMulti.Q THEN
					xBusy := FALSE;
				 	xDone := TRUE;
				ELSE 
					THIS^.sError := 'Output set before delay expired';
					xBusy := FALSE;
					xError := TRUE;
					eError := UnitTestErrors.Failure2;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 3;
				END_IF
				testDelayTimer.IN := FALSE;
				triggered := FALSE;
			END_IF
			
       END_IF

   	3:	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 4: Test Output after delay';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			xBusy := TRUE;
			IF testDwellTimer.Q THEN
				IF monoMulti.Q THEN
				 	xDone := TRUE;
				ELSE 
					THIS^.sError := 'Output not set during dwell time';
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 3;
				END_IF
				testDwellTimer.IN := FALSE;
			END_IF
			
       END_IF
	   
	4:	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 5: Output off after dwell';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			xBusy := TRUE;
			IF testPostDwellTimer.Q THEN
				IF NOT monoMulti.Q THEN
				 	xDone := TRUE;
				ELSE 
					THIS^.sError := Standard.CONCAT('Output still set after dwell time', TO_STRING(monoMulti.dwellTimer.ET));
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 3;
				END_IF
				testPostDwellTimer.IN := FALSE;
			END_IF
       END_IF
    ELSE
        IF THIS^.diTestCaseIndex < 0 THEN
            THIS^.diTestCaseCount := 5;
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
{warning 'Add method implementation '}
METHOD prvStart : BOOL



{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}
FUNCTION_BLOCK FB_MonostableMultivibrator_UnitTests EXTENDS CBM.ETrigA
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
	monoMulti : FB_MonostableMultivibrator(name := 'FB_MonostableMultovibrotor Under Test');
	testDwellTimer : Standard.TON;
	testPostDwellTimer : Standard.TON;
	testDelayTimer : Standard.TON;
	triggered : BOOL;
END_VAR

SUPER^();
testDwellTimer();
testPostDwellTimer();
testDelayTimer();
monoMulti();


{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();
THIS^.diTestCaseCount := 5;

CASE diTestCaseIndex OF
    0: // Test Case #0
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Test Manual On';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
			xDone := TRUE;
		ELSE
			monoMulti.ManualOn();
			monoMulti();
			IF monoMulti.Q THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Output should be on';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: // Test Case #1
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Test Manual Off';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			monoMulti.ManualOff();
			monoMulti();
			IF NOT monoMulti.Q THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Output should be off';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 2;
			END_IF
       END_IF
	   
	2:	//
		IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: Start Trigger, Test Delay';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			xBusy := TRUE;
			monoMulti.DwellSetting := 2000;
			monoMulti.DelaySetting := 500;
			IF NOT triggered THEN
				monoMulti.Trigger();
				triggered := TRUE;
			END_IF
			
			testDelayTimer.PT := T#450MS;
			testDelayTimer.IN := TRUE;
			testDwellTimer.PT := T#1700MS; 
			testDwellTimer.IN := TRUE;
			testPostDwellTimer.PT := T#2550MS;
			testPostDwellTimer.IN := TRUE;
			IF testDelayTimer.Q THEN
				IF NOT monoMulti.Q THEN
					xBusy := FALSE;
				 	xDone := TRUE;
				ELSE 
					THIS^.sError := 'Output set before delay expired';
					xBusy := FALSE;
					xError := TRUE;
					eError := UnitTestErrors.Failure2;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 3;
				END_IF
				testDelayTimer.IN := FALSE;
				triggered := FALSE;
			END_IF
			
       END_IF

   	3:	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 4: Test Output after delay';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			xBusy := TRUE;
			IF testDwellTimer.Q THEN
				IF monoMulti.Q THEN
				 	xDone := TRUE;
				ELSE 
					THIS^.sError := 'Output not set during dwell time';
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 3;
				END_IF
				testDwellTimer.IN := FALSE;
			END_IF
			
       END_IF
	   
	4:	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 5: Output off after dwell';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 360000;
            xDone := TRUE;
		ELSE
			xBusy := TRUE;
			IF testPostDwellTimer.Q THEN
				IF NOT monoMulti.Q THEN
				 	xDone := TRUE;
				ELSE 
					THIS^.sError := Standard.CONCAT('Output still set after dwell time', TO_STRING(monoMulti.dwellTimer.ET));
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 3;
				END_IF
				testPostDwellTimer.IN := FALSE;
			END_IF
       END_IF
    ELSE
        IF THIS^.diTestCaseIndex < 0 THEN
            THIS^.diTestCaseCount := 5;
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
{warning 'Add method implementation '}
METHOD prvStart : BOOL

