(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
(*
*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Double Solenoid Closed Center'}
{attribute 'testcategory':='Solenoids'}
{attribute 'testcasetimeout':='15000'}
FUNCTION_BLOCK FB_DoubleSolenoidClosedCenterActuator_UnitTests EXTENDS CBM.EtrigA
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
	testee : FB_DoubleSolenoidClosedCenterActuator(name := 'Unit Test Actuator');
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();