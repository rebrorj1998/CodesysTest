

FUNCTION_BLOCK FINAL FB_UN00_SharpMachine EXTENDS FB_PackMLStates
VAR_INPUT
	faultActive : BOOL;
END_VAR
VAR_OUTPUT
	currentState : PACK_ML.State;
END_VAR
VAR
	automaticUnitMode	: PACK_ML.UnitMode; // Example unit mode for prodction
	simUnitMode			: PACK_ML.UnitMode; // Example unit mode for semi auto production
	manitUnitMode		: PACK_ML.UnitMode; // Example unit mode for setup
	unitModeManager		: PACK_ML.UnitModeManager; // Unit mode manager to switch between unitmodes
	currentUnitMode		: PACK_ML.IUnitMode;
	xInit				: BOOL := FALSE; // Flag for initialization
	xNextState : BOOL; // Next state from HMI
	sCurrentUnitModeName : STRING;
	baggerManager : EM01_BaggerHead_Manager(name := 'Bagger Head Manager');
	
	startMachine : BOOL;
	abortMachine : BOOL;
	resetONS : FB_ONS;
	resetMachine : BOOL;
	clearTimer : Standard.TON := (PT := T#3S);
	testResetSim : BOOL;
END_VAR

VAR_IN_OUT
	baggerHead : EM01_BaggerHead;
	discharge : EM02_Discharge;
	//baggerManager : EM01_Bagger_Manager;
END_VAR
// Setup of unit modes

IF NOT xInit THEN
	automaticUnitMode(		sName := UN00_Globals.sAutomatic, 
							dwSupportedStates := PACK_ML.State.All - PACK_ML.State.Completing - PACK_ML.State.Complete - PACK_ML.State.Suspended - PACK_ML.State.Suspending - PACK_ML.State.UnSuspending, 
							dwAllowsLeavingFromStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle, 
							dwAllowsEnteringIntoStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle, 
							eInitialState := PACK_ML.State.Stopped,
							xActive := TRUE);

	manitUnitMode(			sName := UN00_Globals.sMaintenance, 
							dwSupportedStates := PACK_ML.State.All - PACK_ML.State.Completing - PACK_ML.State.Complete - PACK_ML.State.Holding - PACK_ML.State.Held - PACK_ML.State.UnHolding - PACK_ML.State.UnSuspending - PACK_ML.State.Suspended - PACK_ML.State.Suspending,
							dwAllowsLeavingFromStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle,   
							dwAllowsEnteringIntoStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle, 
							eInitialState := PACK_ML.State.Stopped, 
							xActive := FALSE);

	// Register the unit modes 
	unitModeManager.Register(automaticUnitMode);
	unitModeManager.Register(manitUnitMode);
	xInit := TRUE;
END_IF

currentUnitMode := unitModeManager.ActiveUnitMode;
sCurrentUnitModeName := currentUnitMode.Name;
currentState := currentUnitMode.CurrentState;
IF xNextState THEN
	currentUnitMode.Enter(currentUnitMode.NextState(currentUnitMode.CurrentState));
	xNextState := FALSE;
END_IF
baggerManager(
	modeManager := unitModeManager, 
	baggerHead := baggerHead, 
	discharge := discharge);
	
clearTimer();
resetONS(CLK := resetMachine);

IF testResetSim THEN
	UN00_Globals.simFaults.FB_Init(TRUE,TRUE);
END_IF


CASE unitModeManager.ActiveUnitMode.CurrentState OF
	
	PACK_ML.State.Stopped: 		IF resetONS.OSR OR _clearingDone THEN
									currentUnitMode.Reset();
								END_IF	
								_clearingDone := FALSE;
								
	PACK_ML.State.Aborted:		IF resetONS.OSR THEN
									GlobalObjects.CollectionOfActiveFaults.AckAll();
									currentUnitMode.Clear();
								END_IF	
	
	PACK_ML.State.Idle:			currentUnitMode.Start();
	
	PACK_ML.State.Held:			currentUnitMode.Unhold();
	//PACK_ML.State.Complete:			
	PACK_ML.State.Resetting:	IF BaggerManager.ResettingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF	
	
	PACK_ML.State.Clearing :	clearTimer.IN := TRUE;
								IF BaggerManager.ClearingDone AND NOT faultActive THEN
									currentUnitMode.ActingStateCompleted();
									clearTimer.IN := FALSE;
									_clearingDone := TRUE;
								ELSIF clearTimer.Q THEN
									currentUnitMode.Abort();
									clearTimer.IN := FALSE;
								END_IF	
	 		
	PACK_ML.State.Starting :	IF BaggerManager.StartingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF
								
	//PACK_ML.State.Execute :
	PACK_ML.State.Holding :		IF BaggerManager.HoldingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF
	//PACK_ML.State.UnHolding :
	//PACK_ML.State.Completing :
	PACK_ML.State.Aborting :	IF BaggerManager.AbortingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF		
								
	PACK_ML.State.Stopping:		
								IF BaggerManager.StoppingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF	
			
END_CASE

IF (faultActive AND unitModeManager.ActiveUnitMode.CurrentState <> PACK_ML.State.Clearing) OR abortMachine THEN
	currentUnitMode.Abort();
	abortMachine := FALSE;
END_IF

startMachine := FALSE;

FUNCTION_BLOCK FINAL FB_UN00_SharpMachine EXTENDS FB_PackMLStates
VAR_INPUT
	faultActive : BOOL;
END_VAR
VAR_OUTPUT
	currentState : PACK_ML.State;
END_VAR
VAR
	automaticUnitMode	: PACK_ML.UnitMode; // Example unit mode for prodction
	simUnitMode			: PACK_ML.UnitMode; // Example unit mode for semi auto production
	manitUnitMode		: PACK_ML.UnitMode; // Example unit mode for setup
	unitModeManager		: PACK_ML.UnitModeManager; // Unit mode manager to switch between unitmodes
	currentUnitMode		: PACK_ML.IUnitMode;
	xInit				: BOOL := FALSE; // Flag for initialization
	xNextState : BOOL; // Next state from HMI
	sCurrentUnitModeName : STRING;
	baggerManager : EM01_BaggerHead_Manager(name := 'Bagger Head Manager');
	
	startMachine : BOOL;
	abortMachine : BOOL;
	resetONS : FB_ONS;
	resetMachine : BOOL;
	clearTimer : Standard.TON := (PT := T#3S);
	testResetSim : BOOL;
END_VAR

VAR_IN_OUT
	baggerHead : EM01_BaggerHead;
	discharge : EM02_Discharge;
	//baggerManager : EM01_Bagger_Manager;
END_VAR
// Setup of unit modes

IF NOT xInit THEN
	automaticUnitMode(		sName := UN00_Globals.sAutomatic, 
							dwSupportedStates := PACK_ML.State.All - PACK_ML.State.Completing - PACK_ML.State.Complete - PACK_ML.State.Suspended - PACK_ML.State.Suspending - PACK_ML.State.UnSuspending, 
							dwAllowsLeavingFromStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle, 
							dwAllowsEnteringIntoStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle, 
							eInitialState := PACK_ML.State.Stopped,
							xActive := TRUE);

	manitUnitMode(			sName := UN00_Globals.sMaintenance, 
							dwSupportedStates := PACK_ML.State.All - PACK_ML.State.Completing - PACK_ML.State.Complete - PACK_ML.State.Holding - PACK_ML.State.Held - PACK_ML.State.UnHolding - PACK_ML.State.UnSuspending - PACK_ML.State.Suspended - PACK_ML.State.Suspending,
							dwAllowsLeavingFromStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle,   
							dwAllowsEnteringIntoStates := PACK_ML.State.Stopped OR PACK_ML.State.Aborted OR PACK_ML.State.Idle, 
							eInitialState := PACK_ML.State.Stopped, 
							xActive := FALSE);

	// Register the unit modes 
	unitModeManager.Register(automaticUnitMode);
	unitModeManager.Register(manitUnitMode);
	xInit := TRUE;
END_IF

currentUnitMode := unitModeManager.ActiveUnitMode;
sCurrentUnitModeName := currentUnitMode.Name;
currentState := currentUnitMode.CurrentState;
IF xNextState THEN
	currentUnitMode.Enter(currentUnitMode.NextState(currentUnitMode.CurrentState));
	xNextState := FALSE;
END_IF
baggerManager(
	modeManager := unitModeManager, 
	baggerHead := baggerHead, 
	discharge := discharge);
	
clearTimer();
resetONS(CLK := resetMachine);

IF testResetSim THEN
	UN00_Globals.simFaults.FB_Init(TRUE,TRUE);
END_IF


CASE unitModeManager.ActiveUnitMode.CurrentState OF
	
	PACK_ML.State.Stopped: 		IF resetONS.OSR OR _clearingDone THEN
									currentUnitMode.Reset();
								END_IF	
								_clearingDone := FALSE;
								
	PACK_ML.State.Aborted:		IF resetONS.OSR THEN
									GlobalObjects.CollectionOfActiveFaults.AckAll();
									currentUnitMode.Clear();
								END_IF	
	
	PACK_ML.State.Idle:			currentUnitMode.Start();
	
	PACK_ML.State.Held:			currentUnitMode.Unhold();
	//PACK_ML.State.Complete:			
	PACK_ML.State.Resetting:	IF BaggerManager.ResettingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF	
	
	PACK_ML.State.Clearing :	clearTimer.IN := TRUE;
								IF BaggerManager.ClearingDone AND NOT faultActive THEN
									currentUnitMode.ActingStateCompleted();
									clearTimer.IN := FALSE;
									_clearingDone := TRUE;
								ELSIF clearTimer.Q THEN
									currentUnitMode.Abort();
									clearTimer.IN := FALSE;
								END_IF	
	 		
	PACK_ML.State.Starting :	IF BaggerManager.StartingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF
								
	//PACK_ML.State.Execute :
	PACK_ML.State.Holding :		IF BaggerManager.HoldingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF
	//PACK_ML.State.UnHolding :
	//PACK_ML.State.Completing :
	PACK_ML.State.Aborting :	IF BaggerManager.AbortingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF		
								
	PACK_ML.State.Stopping:		
								IF BaggerManager.StoppingDone THEN
									currentUnitMode.ActingStateCompleted();
								END_IF	
			
END_CASE

IF (faultActive AND unitModeManager.ActiveUnitMode.CurrentState <> PACK_ML.State.Clearing) OR abortMachine THEN
	currentUnitMode.Abort();
	abortMachine := FALSE;
END_IF

startMachine := FALSE;