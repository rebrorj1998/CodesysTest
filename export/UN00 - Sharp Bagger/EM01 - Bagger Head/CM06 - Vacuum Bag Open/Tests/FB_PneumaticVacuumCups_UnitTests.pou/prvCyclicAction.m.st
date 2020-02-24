(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvCyclicAction : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.prvCyclicAction();

CASE diTestCaseIndex OF
    0: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Check Vacuum Is Off On Initialze';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			IF testee.VacuumOn = FALSE THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Vacuum On, should be off on initialize';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Start Vacuum';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			testee.StartVacuum();
			IF testee.VacuumOn AND testVacGenerator.Solenoid0Asserted THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Vacuum Off, should be on';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
	   
	2: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: Stop Vacuum';
            THIS^.sTestCaseCategories := 'General';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			testee.StopVacuum();
			IF NOT testee.VacuumOn AND NOT testVacGenerator.Solenoid0Asserted THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Vacumm On, should be off';
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
            THIS^.diTestCaseCount := 3;
            xDone := TRUE;
        ELSE
            THIS^.sInfo := 'Invalid test case index';
            eError := UnitTestErrors.Failure;
			xError := TRUE;
        END_IF
END_CASE
