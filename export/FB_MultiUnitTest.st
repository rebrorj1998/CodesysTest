

(*
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}
*)
FUNCTION_BLOCK FB_MultiUnitTest EXTENDS CBM.EtrigA
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
	
END_VAR


{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();

CASE diTestCaseIndex OF
    0: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: ';
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
    1: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: ';
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
	   
	2: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) THEN
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
            THIS^.diTestCaseCount := 7;
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



(*
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}
*)
FUNCTION_BLOCK FB_MultiUnitTest EXTENDS CBM.EtrigA
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
	
END_VAR


{attribute 'hide'}
METHOD prvAbort : BOOL


SUPER^.prvAbort();

xAbortInProgress := FALSE;

{attribute 'hide'}
METHOD prvCyclicAction : BOOL

SUPER^.prvCyclicAction();

CASE diTestCaseIndex OF
    0: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: ';
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
    1: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: ';
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
	   
	2: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: ';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			(*TEST SOMETHING HERE*)
			IF (*CONNDITION*) THEN
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
            THIS^.diTestCaseCount := 7;
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

