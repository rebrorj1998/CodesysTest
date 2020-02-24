(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvCyclicAction : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.prvCyclicAction();
THIS^.diTestCaseCount := 4;

CASE diTestCaseIndex OF
    0: // Test Case #0
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Test Solonoids Off';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			IF NOT testee.Solenoid0Asserted AND NOT testee.Solenoid1Asserted THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Solenoids not off';
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
			IF testee.Solenoid0Asserted AND testee.ExtendAsserted
				AND NOT testee.Solenoid1Asserted AND NOT testee.RetractAsserted THEN
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
			IF testee.Solenoid1Asserted AND testee.RetractAsserted
				AND NOT testee.Solenoid0Asserted AND NOT testee.ExtendAsserted THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Failed to retract';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 3;
			END_IF
       END_IF

   	3:	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 4: Extend Low Pressure';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			testee.ExtendLowPressure();
			IF testee.Solenoid1Asserted AND testee.ExtendLPAsserted
				AND testee.Solenoid0Asserted
				AND NOT testee.RetractAsserted THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := 'Failed to extend low pressure';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 3;
			END_IF
       END_IF
    ELSE
        IF THIS^.diTestCaseIndex < 0 THEN
            THIS^.diTestCaseCount := 4;
            xDone := TRUE;
        ELSE
            THIS^.sInfo := 'Invalid test case index';
            eError := UnitTestErrors.Failure;
			xError := TRUE;
        END_IF
END_CASE
