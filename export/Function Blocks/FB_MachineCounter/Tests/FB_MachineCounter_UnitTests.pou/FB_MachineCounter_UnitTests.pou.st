(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Machine Counter'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='5000'}
FUNCTION_BLOCK FB_MachineCounter_UnitTests EXTENDS TM.Testcase_Base
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
    eError : FB_MachineCounter_Test_Errors;
    sError : STRING;
    eFailureMode : TM.FAILUREMODE;
END_VAR
VAR
	machineCounter : FB_MachineCounter(name := 'FB_MachineCounter Under Test');
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();