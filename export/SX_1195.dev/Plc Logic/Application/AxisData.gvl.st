(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
//{attribute 'global_init_slot' := '49994'}
VAR_GLOBAL PERSISTENT
	
	(* Jaw *)	
	
	jawConfig : sctAxisConfig := (
		stepsPerInch := 2410, 
		rotationsPerInch := 0.241,
		zeroOffset := 0,
		defaultCurrent := 100.0 
	);

	jawOpenMotionProfile : sctMotionProfile := (
		acceleration := 100, 
		deceleration := 100,
		velocity := 30.0,
		current := 100.0,
		position := 5.5 
	);
	
	jawCloseMotionProfile : sctMotionProfile := (
		acceleration := 100,
		deceleration := 100,
		velocity := 30.0,
		current := 100.0,
		position := 0 
	);

	jawPushMotionProfile : sctMotionProfile := (
		acceleration := 100,
		deceleration := 100,
		velocity := 4,
		current := 100.0,
		position := -1
	);
	
	jaw : sctAxisData := (
		config := jawConfig,
		openProfile := jawOpenMotionProfile,
		closeProfile := jawCloseMotionProfile
	);

	(* Load Plate *)
	
	loadPlateConfig : sctAxisConfig := (
		stepsPerInch := 9310, 
		rotationsPerInch := 0.931,
		zeroOffset := 0.0
	);
	
	loadPlateRaiseMotionProfile : sctMotionProfile := (
		acceleration := 300000.0, 
		deceleration := 300000.0, 
		velocity := 10.0, 
		current := 100.0
	);
	
	loadPlateLowerMotionProfile : sctMotionProfile := (
		acceleration := 300000.0, 
		deceleration := 300000.0, 
		velocity := 10000.0, 
		current := 100.0
	);

	loadPlate : sctAxisData := (
		config := loadPlateConfig, 
		raiseProfile := loadPlateRaiseMotionProfile, 
		lowerProfile := loadPlateLowerMotionProfile
	);		

	(* IBD *)
	
	IBDConfig : sctAxisConfig := (
		stepsPerInch := 12500, 
		rotationsPerInch := 1.25,
		zeroOffset := 2.0 
	);
	
	IBDJogMotionProfile : sctMotionProfile := (
		acceleration := 0,
		deceleration := 0,
		velocity := 0,
	 	minPosition := 0,
		maxPosition := 0
	);
	
	IBDOpenMotionProfile : sctMotionProfile := (
		acceleration := 300000.0,
 		deceleration := 300000.0,
		velocity := 10000.0,
		current := 100.0 
	);
	
	IBDCloseMotionProfile : sctMotionProfile := (
		acceleration := 300000.0,
 		deceleration := 300000.0,
		velocity := 10.0,
		current := 50.0
	);
	
	IBD : sctAxisData := (
		config := IBDConfig, 
		openProfile := IBDOpenMotionProfile,
		closeProfile := IBDCloseMotionProfile,
		jogProfile := IBDJogMotionProfile,
		jogType := eDiscreteMotionType.Absolute
	);
	
	(* Film Feed *)
	
	FilmFeedConfig : sctAxisConfig := (
		stepsPerInch := 4900, 
		rotationsPerInch := 0.490,
		zeroOffset := 2.0,
		defaultCurrent := 100.0 
	);
	
	FilmFeedJogMotionProfile : sctMotionProfile := (
		acceleration := 10,
		deceleration := 10,
		velocity := 100,
	 	minPosition := 0,
		maxPosition := 0
	);
	
	FilmFeedForwardMotionProfile : sctMotionProfile := (
		acceleration := 200,
 		deceleration := 200,
		velocity := 60,
		position := 17.5,
		current := 100.0 
	);
	
	FilmFeedReverseMotionProfile : sctMotionProfile := (
		acceleration := 50,
 		deceleration := 50,
		velocity := 12,
		position := -1,
		current := 100.0 
	);
	
	FilmFeed : sctAxisData := (
		config := FilmFeedConfig, 
		openProfile := FilmFeedForwardMotionProfile,
		closeProfile := FilmFeedReverseMotionProfile,
		jogProfile := FilmFeedJogMotionProfile,
		jogType := eDiscreteMotionType.Absolute
	);
	
END_VAR