(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BannerManager
VAR_INPUT
	baggerNotReady : BOOL;
	baggerReady : BOOL;
	baggerInCycle : BOOL;
	noBagCoveringEye : BOOL;
	bagFailedToSeperate : BOOL;
	pbarObstruction : BOOL;
	lightCurtainViolation : BOOL;
	printHeadFTR : BOOL;
	printHeadFTL : BOOL;
	barcodeFault : BOOL;
	tooManyPartsCounted : BOOL;
	jawFailedToClose : BOOL;
	jawFailedToHome : BOOL;
	filmFeedMotionFault : BOOL;
	jawMotionFault : BOOL;
	waitingOnPrinter : BOOL;
	waitingOnFiller : BOOL;
	batchCounterDone : BOOL;
	jawNotHomed : BOOL;
	cycleBaggerTForFiller : BOOL;
	machineNotTested : BOOL;
	loadPlateMotorNotHomed : BOOL;
	loadPlateMotorFaulted : BOOL;
	loadPlateMotorCommF : BOOL;
	topCoverLiftedFault : BOOL;
	topCoverLiftedWarning : BOOL;
	IBDMotorNotHomed : BOOL;
	IBDMotorFaulted : BOOL;
	IBDMotorCommF : BOOL;
	printerRibbonFault : BOOL;
	printerServiceRequired : BOOL;
	jawFailedToOpen : BOOL;
	IBDFailedToClose : BOOL;
	IBDFailedToOpen : BOOL;
END_VAR
VAR_OUTPUT
	messageDisplayIndication : DINT;
END_VAR
VAR
	totalMessages : DINT;
	activeMessages : ARRAY[0..MAX_MESSAGES] OF DINT;
	mappedMessages : ARRAY[0..MAX_MESSAGES] OF BOOL;
	messageDisplayScrollTimer : Standard.TON := (PT := T#2S);
	i : UINT;
	lastMessageFound : UINT;
	atEndOfList : BOOL;
	displayedMessageCleared : BOOL;
END_VAR
VAR CONSTANT
	MAX_MESSAGES : UINT := 64;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Map all messages for Proface banner.  Banner displays certain messages based on INT value.

mappedMessages[0] := baggerNotReady;
mappedMessages[1] := baggerReady;
mappedMessages[2] := baggerInCycle;
mappedMessages[3] := noBagCoveringEye;
mappedMessages[4] := bagFailedToSeperate;
mappedMessages[5] := pbarObstruction;
mappedMessages[6] := lightCurtainViolation;
mappedMessages[7] := printHeadFTR;
mappedMessages[8] := printHeadFTL;
mappedMessages[9] := barcodeFault;
mappedMessages[10] := tooManyPartsCounted;
mappedMessages[11] := jawFailedToClose;
mappedMessages[12] := filmFeedMotionFault;
mappedMessages[13] := jawMotionFault;
mappedMessages[14] := jawFailedToHome;
mappedMessages[15] := waitingOnPrinter;
mappedMessages[16] := waitingOnFiller;
mappedMessages[17] := batchCounterDone;
mappedMessages[18] := jawNotHomed;
mappedMessages[19] := cycleBaggerTForFiller;
mappedMessages[20] := machineNotTested;
mappedMessages[21] := loadPlateMotorNotHomed;
mappedMessages[22] := loadPlateMotorFaulted;
mappedMessages[23] := loadPlateMotorCommF;
mappedMessages[24] := topCoverLiftedFault;
mappedMessages[25] := topCoverLiftedWarning;
mappedMessages[26] := IBDMotorNotHomed;
mappedMessages[27] := IBDMotorFaulted;
mappedMessages[28] := IBDMotorCommF;
mappedMessages[29] := printerRibbonFault;
mappedMessages[30] := printerServiceRequired;
mappedMessages[31] := jawFailedToOpen;
mappedMessages[32] := IBDFailedToClose;
mappedMessages[33] := IBDFailedToOpen;


// Clear out currently displayed message if no longer active
IF NOT mappedMessages[messageDisplayIndication] THEN
	displayedMessageCleared := TRUE;
END_IF

// Self resetting timer to switch between messages
messageDisplayScrollTimer(IN := NOT messageDisplayScrollTimer.q);

// Scroll through active messages in order
IF messageDisplayScrollTimer.Q OR atEndOfList OR displayedMessageCleared THEN
	FOR i:= lastMessageFound  TO MAX_MESSAGES DO
		IF mappedMessages[i] THEN
			messageDisplayIndication := i;
			lastMessageFound := i +1;
			atEndOfList := FALSE;
			displayedMessageCleared := FALSE;
			RETURN;
		END_IF
	END_FOR
	atEndOfList := TRUE;
	lastMessageFound := 0;
END_IF


