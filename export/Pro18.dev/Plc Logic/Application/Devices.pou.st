(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM Devices
VAR
	
END_VAR
VAR_IN_OUT

END_VAR

VAR_OUTPUT
	
	IOMaster : FB_MurrMaster(name := 'IO Master') := 	(ptrEIPInputs := ADR(IOEIPInputs), 
														 ptrEIPOutputs := ADR(IOEIPOutputs));
	
														 
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

	valveManifold : FB_SolenoidValveManifold(name := 'Valve Manifold') := (ptrEIPOutputs := ADR(Valve_Manifold_Outputs));
	

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)


// Valve manifold station selection
FOR i := 1 TO Globals.MAX_VALVE_MANIFOLD_STATIONS DO
	CASE HMI.data.stationValveSelection[i] OF
		
		ValveSelection.PressureBar : 						valveManifold.station[i] := pressureBarSolenoidValve;
		
		ValveSelection.SealBar : 							valveManifold.station[i] := sealBarSolenoidValve;
		
		ValveSelection.HPA_LPA : 							valveManifold.station[i] := HPA_LPA_SolenoidValve;
		
		ValveSelection.LoadPlate : 							valveManifold.station[i] := loadPlateSolenoidValve;
		
		ValveSelection.BagOpenFingers : 					valveManifold.station[i] := bagOpenFingersSolenoidValve;
		
		ValveSelection.PrintHead : 							valveManifold.station[i] := printHeadSolenoidValve;
		
		ValveSelection.Vacuum : 							valveManifold.station[i] := vacuumSolenoidValve;
		
		ValveSelection.SealFlattenersVerticalAxis : 		valveManifold.station[i] := sealFlattenersVertAxisSolenoidValve;
		
		ValveSelection.LoadShelf : 							valveManifold.station[i] := loadShelfSolenoidValve;
		
		ValveSelection.Blank : 								valveManifold.station[i] := blankSolenoidValve;
		
	ELSE 
		valveManifold.station[i] := blankSolenoidValve;
	END_CASE
END_FOR


// Run all configured valves and then the manifold
pressureBarSolenoidValve();
sealBarSolenoidValve();
HPA_LPA_SolenoidValve();
loadPlateSolenoidValve();
bagOpenFingersSolenoidValve();
printHeadSolenoidValve();
vacuumSolenoidValve();
sealFlattenersVertAxisSolenoidValve();
loadShelfSolenoidValve();
blankSolenoidValve();
valveManifold();

IOMaster();