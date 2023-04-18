(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM00_InfeedCM
VAR_INPUT
END_VAR
VAR_OUTPUT
	//
	filler : FB_Filler(name := 'Filler Manager');
	
	//
	funnelActuator : FB_DoubleSolenoidOpenCenterActuator(name := 'Funnel Actuator');
	funnel : FB_Funnel(name := 'Funnel Manager');
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
filler(
	baggerInhibited := ,
	fillerTrigger := ,
	fillerOK := ,
	dropTime := ,
	faultActive := ,
	state => ,
	fillerModeActive => ,
	waitingForFiller => ,
	cycleBagRequest => ,
	cycleBaggerToActivateFiller =>  
);
filler.OptionInstalled := FALSE;
filler.OptionEnabled := FALSE;

// funnel(
// 	hasFeedback := ,
// 	delayTime := ,
// 	funnelOpen := ,
// 	funnelClosed := ,
// 	actuator := ,
// 	serviceOpen := FALSE,
// 	serviceClose := FALSE,
// );
// funnel.OptionInstalled := FALSE;
// funnel.OptionEnabled := FALSE;

