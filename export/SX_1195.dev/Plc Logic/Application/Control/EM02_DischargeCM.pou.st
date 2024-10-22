(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM02_DischargeCM
VAR_INPUT
	loadPlateInterlocks : DINT;
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
	lowerVelo := AxisData.loadPlateLowerMotionProfile.velocity, 
	lowerAccel := AxisData.loadPlateLowerMotionProfile.acceleration, 
	lowerDecel := AxisData.loadPlateLowerMotionProfile.deceleration, 
	raiseVelo := AxisData.loadPlateRaiseMotionProfile.velocity,    
	raiseAccel := AxisData.loadPlateRaiseMotionProfile.acceleration,  
	raiseDecel := AxisData.loadPlateRaiseMotionProfile.deceleration, 
	raisedSetting := HMIData.loadPlateRaisedPositionSetting, 
	loweredSetting := HMIData.loadPlateLoweredPositionSetting, 
	dwellSetting := HMIData.loadPlateDwell, 
	raiseShelfPB := HMIData.loadPlateService.extendCommand, 
	lowerShelfPB := HMIData.loadPlateService.retractCommand, 
	loadPlateMotor := loadPlateMotor,
	interlocks := loadPlateInterlocks
);
loadPlate.OptionInstalled := HMIData.loadPlateInstalled;
loadPlate.OptionEnabled := HMIData.loadPlateInUse AND HMIData.loadPlateInstalled;