(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)

{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Monostable Multivibrator'}
{attribute 'testcategory':='Basics'}
{attribute 'testcasetimeout':='360000'}

FUNCTION_BLOCK FB_SimMotor_UnitTests EXTENDS CBM.EtrigA
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
	testee : FB_SimMotor();
	MC_MoveABSTestee : MC_MoveAbsolute;
	MC_MoveABSTorqueTestee : MC_MoveAbsoluteTorqueLimited;
	MC_MoveRELTestee : MC_MoveRelative;
	MC_PowerTestee : MC_Power;
	MC_HomeTestee : MC_Home;
	delayTimer : Standard.TON;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();

delayTimer();

testee();

MC_MoveABSTestee(Axis := testee);
MC_MoveABSTorqueTestee(Axis := testee);
MC_MoveRELTestee(Axis := testee);
MC_PowerTestee(Enable := TRUE, Axis := testee);
MC_HomeTestee(Axis := testee);