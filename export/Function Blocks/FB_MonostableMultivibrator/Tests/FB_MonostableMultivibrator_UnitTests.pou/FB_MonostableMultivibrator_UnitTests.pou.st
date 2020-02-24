(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}
FUNCTION_BLOCK FB_MonostableMultivibrator_UnitTests EXTENDS CBM.ETrigA
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
	monoMulti : FB_MonostableMultivibrator(name := 'FB_MonostableMultovibrotor Under Test');
	testDwellTimer : Standard.TON;
	testPostDwellTimer : Standard.TON;
	testDelayTimer : Standard.TON;
	triggered : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
testDwellTimer();
testPostDwellTimer();
testDelayTimer();
monoMulti();
