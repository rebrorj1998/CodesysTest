(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
//{attribute 'global_init_slot' := '49994'}
VAR_GLOBAL PERSISTENT
	
	(* Jaw *)	
	jawJogMotionProfile : sctMotionProfile := (
		acceleration := 200,
		deceleration := 200,
		velocity := 2,
		minPosition := 0,
		maxPosition := 5.5,
		current := 30.0
	);
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
		position := -0.5 
	);

	jawPushMotionProfile : sctMotionProfile := (
		acceleration := 100,
		deceleration := 100,
		velocity := 4,
		current := 100.0,
		position := -1
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

	
	(* Film Feed *)
	
	FilmFeedConfig : sctAxisConfig := (
		stepsPerInch := 4900, 
		rotationsPerInch := 0.490,
		zeroOffset := 2.0,
		defaultCurrent := 100.0 
	);
	
	FilmFeedJogMotionProfile : sctMotionProfile := (
		acceleration := 200,
		deceleration := 200,
		velocity := 2,
	 	minPosition := -20,
		maxPosition := 20,
		position := 20,
		current := 100
	);
	
	FilmFeedForwardMotionProfile : sctMotionProfile := (
		acceleration := 75,
 		deceleration := 100,
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
	
	FilmFeedPrintMotionProfile : sctMotionProfile := (
		acceleration := 100,
 		deceleration := 100,
		velocity := 12,
		position := -1,
		current := 100.0 
	);
	
	FilmFeedPrintOffsetMotionProfile : sctMotionProfile := (
		acceleration := 75,
 		deceleration := 100,
		velocity := 12,
		position := -1,
		current := 100.0 
	);	

	
END_VAR

VAR_GLOBAL
	jaw : sctAxisData := (
		config := jawConfig,
		jogType := eDiscreteMotionType.Absolute
	);
	
	FilmFeed : sctAxisData := (
		config := FilmFeedConfig, 
		jogType := eDiscreteMotionType.Relative
	);
	
	IBD : sctAxisData := (
		config := IBDConfig, 
		jogType := eDiscreteMotionType.Absolute
	);
	
	loadPlate : sctAxisData := (
		config := loadPlateConfig
	);	
END_VAR