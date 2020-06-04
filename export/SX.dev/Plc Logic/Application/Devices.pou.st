(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM Devices
VAR
	
END_VAR
VAR_IN_OUT

END_VAR

VAR_OUTPUT
	
	
														 
	pressureBarSolenoidValve : FB_DoubleSolenoidOpenCenterActuator(name := 'Pressure Bar SV');
	sealBarSolenoidValve : FB_SingleSolenoidNormallyRetractedActuator(name := 'Seal Bar SV');
	HPA_LPA_SolenoidValve : FB_DoubleSolenoidClosedCenterActuator(name := 'HPA/LPA SV');
	loadPlateSolenoidValve : FB_DoubleSolenoidOpenCenterActuator(name := 'Load Plate SV');
	bagOpenFingersSolenoidValve : FB_DoubleSolenoidOpenCenterActuator(name := 'BOF SV');
	printHeadSolenoidValve : FB_SingleSolenoidNormallyRetractedActuator(name := 'Print Head SV');
	vacuumSolenoidValve : FB_VacuumGenerator(name := 'Vacuum SV');
	sealFlattenersVertAxisSolenoidValve : FB_DoubleSolenoidOpenCenterActuator(name := 'Seal Flattener Vert SV');
	loadShelfSolenoidValve : FB_DoubleSolenoidOpenCenterActuator(name := 'Load Shelf SV');
	blankSolenoidValve : FB_SolenoidValve(name := 'Blank SV');
	i : UINT;

	

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)


