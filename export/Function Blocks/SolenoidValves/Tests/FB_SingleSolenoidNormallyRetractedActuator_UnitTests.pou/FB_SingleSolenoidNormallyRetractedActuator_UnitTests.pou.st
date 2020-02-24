(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
(*
*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Single Solenoid Normally Retracted'}
{attribute 'testcategory':='Solenoids'}
{attribute 'testcasetimeout':='15000'}
FUNCTION_BLOCK FB_SingleSolenoidNormallyRetractedActuator_UnitTests EXTENDS CBM.EtrigA
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
	testee : FB_SingleSolenoidNormallyRetractedActuator(name := 'Unit Test Actuator');
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();