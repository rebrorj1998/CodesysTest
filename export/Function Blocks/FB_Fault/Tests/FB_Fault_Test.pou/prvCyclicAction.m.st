(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvCyclicAction : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
