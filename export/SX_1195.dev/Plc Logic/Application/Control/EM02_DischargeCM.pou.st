(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM02_DischargeCM
VAR_INPUT
END_VAR
VAR_OUTPUT
	loadPlateMotor : FB_AZDKAxis := (defaultCurrent := 100);
	loadPlate : FB_MotorizedLoadPlate(name := 'Motorized Load Plate');
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
loadPlateMotor(
	axisData := AxisData.loadPlate,
	commStatus := TRUE,
	iActualPosition := ,
	iActualVelocity := ,
	iModeOfOperation := ,
	iStatusword := ,
	oControlword => ,
	oModeOfOperation => ,
	oTargetPosition => ,
	oProfileAcceleration => ,
	oProfileDeceleration => ,
	oProfileVelocity => 
);
	
//
loadPlate(
	lowerVelo := AxisData.loadPlate.lowerProfile.velocity, 
	lowerAccel := AxisData.loadPlate.lowerProfile.acceleration, 
	lowerDecel := AxisData.loadPlate.lowerProfile.deceleration, 
	raiseVelo := AxisData.loadPlate.raiseProfile.velocity,    
	raiseAccel := AxisData.loadPlate.raiseProfile.acceleration,  
	raiseDecel := AxisData.loadPlate.raiseProfile.deceleration, 
	raisedSetting := HMIData.loadPlateRaisedPositionSetting, 
	loweredSetting := HMIData.loadPlateLoweredPositionSetting, 
	dwellSetting := HMIData.loadPlateDwell, 
	raiseShelfPB := HMIData.loadPlateService.extendCommand, 
	lowerShelfPB := HMIData.loadPlateService.retractCommand, 
	loadPlateMotor := loadPlateMotor
);
loadPlate.OptionInstalled := HMIData.loadPlateInstalled;
loadPlate.OptionEnabled := HMIData.loadPlateInUse;