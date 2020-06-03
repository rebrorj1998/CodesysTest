(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvCyclicAction : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
