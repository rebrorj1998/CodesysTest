(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvCyclicAction : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.prvCyclicAction();
THIS^.diTestCaseCount := 6;

CASE diTestCaseIndex OF
    0: // Test Case #0
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Test All Solonoids Off';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			IF testDWORD = 0 THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Solenoids not initalized off';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: // Test Case #1
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Extend Cylinder in Station 0';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			valves[1].Extend();
			testee();
			
			IF testDWORD = 1 THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := Standard.CONCAT('Incorrect bit set; value should be 1 was: ', TO_STRING(testDWORD));
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 2;
			END_IF
       END_IF
	   
	2:	//
		IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 3: Retract Cylinder in Station 0';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			valves[1].Retract();
			testee();
			IF testDWORD = 2 THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := Standard.CONCAT('Incorrect bit set; value should be 2 was: ', TO_STRING(testDWORD));
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 3;
			END_IF
       END_IF

   	3:	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 4: Extend Low Pressure Cylinder in Station 0';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
            xDone := TRUE;
		ELSE
			valves[1].ExtendLowPressure();
			testee();
			IF testDWORD = 3 THEN
				 xDone := TRUE;
			ELSE 
				THIS^.sError := Standard.CONCAT('Incorrect bit set; value should be 2 was: ', TO_STRING(testDWORD));
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 3;
			END_IF
       END_IF
	   
	4: // Test Case #4
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 5: Test Copy of Valve to 2nd position';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			testee.station[2] := valves[1];
			testee();
			IF testDWORD = 15 THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := Standard.CONCAT('Incorrect bits set; value should be 15 was: ', TO_STRING(testDWORD));
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
		
		5: // Test Case #5
        IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 6: Exhaust Valves';
            THIS^.sTestCaseCategories := 'Solenoids';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			valves[1].Exhaust();
			testee();
			IF testDWORD = 0 THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := Standard.CONCAT('Incorrect bits set; value should be 0 was: ', TO_STRING(testDWORD));
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
		
    ELSE
        IF THIS^.diTestCaseIndex < 0 THEN
            THIS^.diTestCaseCount := 6;
            xDone := TRUE;
        ELSE
            THIS^.sInfo := 'Invalid test case index';
            eError := UnitTestErrors.Failure;
			xError := TRUE;
        END_IF
END_CASE
