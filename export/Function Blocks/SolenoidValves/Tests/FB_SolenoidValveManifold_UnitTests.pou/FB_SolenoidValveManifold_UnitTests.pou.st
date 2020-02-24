(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Solenoid Valve Manifold Test'}
{attribute 'testcategory':='Solenoids'}
{attribute 'testcasetimeout':='15000'}
FUNCTION_BLOCK FB_SolenoidValveManifold_UnitTests EXTENDS CBM.EtrigA
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
	valves : ARRAY[1..16] OF FB_DoubleSolenoidOpenCenterActuator(name := 'Unit Test Valve');
	testee : FB_SolenoidValveManifold(name := 'Unit Test Valve Manifold');
	testDWORD : DWORD;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
testee(ptrEIPOutputs := ADR(testDWORD));