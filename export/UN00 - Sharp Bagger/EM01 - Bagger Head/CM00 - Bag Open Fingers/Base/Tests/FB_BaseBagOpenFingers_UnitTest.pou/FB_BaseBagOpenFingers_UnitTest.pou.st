(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Base Bag Open Fingers'}
{attribute 'testcategory':='Machine Components'}
{attribute 'testcasetimeout':='5000'}

FUNCTION_BLOCK FB_BaseBagOpenFingers_UnitTest EXTENDS CBM.EtrigA
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
	testee : FB_BaseBagOpenFingers(name := 'Test Base Bag Open Fingers');
	checkGrabTimer : Standard.TON;
	checkNotGrabTimer : Standard.TON;
	grabRequested : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
