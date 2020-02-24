(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvCyclicAction : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.prvCyclicAction();
checkGrabTimer();
checkNotGrabTimer();
testee(
	delayToGrabSetting:= , 
	delayToCheckBagPresentSetting:= , 
	delayToClearSetting:= , 
	grabCounter=> , 
	releaseCounter=> , 
	missedCounter=> );
CASE diTestCaseIndex OF
    0: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 1: Check all statuses are clear on initialization';
            THIS^.sTestCaseCategories := 'Machine Components';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			IF NOT testee.BagCleared 
				AND NOT testee.BagGrabbed 
				AND NOT testee.BagMissed 
			THEN
				 xDone := TRUE;
			ELSE
				THIS^.sError := 'Status should be all false';
				xError := TRUE;
				eError := UnitTestErrors.Failure;
            	eFailureMode := TM.FAILUREMODE.AbortTestCase;
                iError := 1;
			END_IF
        END_IF
    1: 	IF THIS^.xGetTestInfo THEN
            THIS^.sTestCaseName := 'Step 2: Grab Bag and watch for BagGrabbed status';
            THIS^.sTestCaseCategories := 'Machine Components';
            THIS^.diTestCaseTimeout := 3000;
			xDone := TRUE;
		ELSE
			testee.delayToGrabSetting := 1.0;
			checkGrabTimer.IN := TRUE;
			checkGrabTimer.PT := T#1050MS;
			
			checkNotGrabTimer.IN := TRUE;
			checkNotGrabTimer.PT := T#900MS;
			
			IF NOT grabRequested THEN
				testee.GrabBag();
				grabRequested := TRUE;
			END_IF
			
			IF checkNotGrabTimer.Q THEN
				IF testee.delayToGrab.Q THEN
					THIS^.sError := 'Bag Grab Request occured too soon';
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 1;
				END_IF
				checkNotGrabTimer.IN := FALSE;
			ELSIF checkGrabTimer.Q THEN
				IF testee.delayToGrab.Q THEN
					xDone := TRUE;
				ELSE
					THIS^.sError := 'Bag Grab Timer not timed out';
					xError := TRUE;
					eError := UnitTestErrors.Failure;
					eFailureMode := TM.FAILUREMODE.AbortTestCase;
					iError := 1;
				END_IF
				checkGrabTimer.IN := FALSE;
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
