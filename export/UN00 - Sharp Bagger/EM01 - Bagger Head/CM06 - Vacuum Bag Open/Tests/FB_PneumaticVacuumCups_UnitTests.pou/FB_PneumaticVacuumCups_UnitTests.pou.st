(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)

{attribute 'test' := 'multitest'}
{attribute 'testcasename':='Pneumatic Vacuum Cups'}
{attribute 'testcategory':='Machine Components'}
{attribute 'testcasetimeout':='15000'}

FUNCTION_BLOCK FB_PneumaticVacuumCups_UnitTests EXTENDS CBM.EtrigA
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
	testVacGenerator : FB_VacuumGenerator(name := 'Test Vac Generator');
	testee : FB_PneumaticVacuumCups(name := 'Test Pneumatic Vac Cups');
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
testVacGenerator();
testee(vacGenerator := testVacGenerator);