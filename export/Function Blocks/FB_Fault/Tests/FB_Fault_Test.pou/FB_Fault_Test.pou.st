(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Fault FB'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='5000'}
FUNCTION_BLOCK FB_Fault_Test EXTENDS TM.Testcase_Base
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
    eError : FB_Fault_Test_Errors;
    sError : STRING;
    eFailureMode : TM.FAILUREMODE;
END_VAR
VAR
	faultToTest : FB_Fault(name := 'Test Fault');
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
