(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eProfaceMessageDisplay :
(
	baggerNotReady := 			0,
	baggerReady := 				1,
	baggerInCycle := 			2,
	noBagCoveringEye := 		3,
	bagFailedToSeperate := 		4,
	pbarObstruction := 			5,
	lightCurtainViolation := 	6,
	printHeadFTR := 			7,
	printHeadFTL := 			8,
	barcodeFault := 			9,
	tooManyPartsCounted :=		10,
	jawFailedToClose := 		11,
	filmFeedMotionFault := 		12,
	jawMotionFault := 			13,
	waitingOnPrinter := 		14,
	waitingOnFiller := 			15,
	batchCounterDone := 		16,
	jawNotHomed := 				17,
	cycleBaggerTForFiller :=	18,
	machineNotTested := 		20,
	loadPlateMotorNotHomed := 	21,
	loadPlateMotorFaulted := 	22,
	loadPlateMotorCommF := 		23,
	topCoverLiftedFault := 		24,
	topCoverLiftedWarning := 	25
);
END_TYPE
