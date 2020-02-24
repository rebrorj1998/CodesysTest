(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvResetOutputs : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.prvResetOutputs();

sTestCaseName := '';
sTestCaseCategories := '';
diTestCaseCount := 0;
diTestCaseTimeout := 0;
sInfo := '';
sError := '';
eFailureMode := TM.FAILUREMODE.AbortTestCase;
eError := FB_MachineCounter_Test_Errors.Increment_Failure;