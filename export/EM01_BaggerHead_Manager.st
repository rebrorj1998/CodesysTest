

FUNCTION_BLOCK EM01_BaggerHead_Manager EXTENDS FB_PackMLStates
VAR_INPUT
	discharge : IEM02_Discharge;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	activeBaggerMode : IPackMLStates;
	BaggerAutoMode : EM01_BaggerHead_Automode(name := 'Auto Mode Bagger');
	BaggerMaintMode : EM01_BaggerHead_MaintMode(name := 'Maintenance Mode Bagger');
	xInit : BOOL;
END_VAR
VAR_IN_OUT
	modeManager : PACK_ML.UnitModeManager;
	baggerHead : EM01_BaggerHead;
END_VAR

IF NOT xInit THEN
	BaggerAutoMode(bagger := baggerHead, discharge := discharge);
	BaggerMaintMode(bagger := baggerHead);
	xInit := TRUE;
END_IF


IF modeManager.ActiveUnitMode.Name = UN00_Globals.sAutomatic THEN
	activeBaggerMode := BaggerAutoMode;
ELSIF modeManager.ActiveUnitMode.Name = UN00_Globals.sMaintenance THEN
	activeBaggerMode := BaggerMaintMode;
END_IF

_abortingDone := activeBaggerMode.AbortingDone;
_clearingDone := activeBaggerMode.ClearingDone;
_completingDone := activeBaggerMode.CompletingDone;
_holdingDone := activeBaggerMode.HoldingDone;
_resettingDone := activeBaggerMode.ResettingDone;
_startingDone := activeBaggerMode.StartingDone;
_unholdingDone := activeBaggerMode.UnholdingDone;
_stoppingDone := activeBaggerMode.StoppingDone;

CASE modeManager.ActiveUnitMode.CurrentState OF
	PACK_ML.State.Stopped: 			activeBaggerMode.Stopped();
	PACK_ML.State.Aborted:			activeBaggerMode.Aborted();
	PACK_ML.State.Idle:				activeBaggerMode.Idle();
	PACK_ML.State.Held:				activeBaggerMode.Held();
	PACK_ML.State.Complete:			activeBaggerMode.Complete();
	PACK_ML.State.Resetting:		activeBaggerMode.Resetting();
	PACK_ML.State.Starting :		activeBaggerMode.Starting();
	PACK_ML.State.Execute :			activeBaggerMode.Executing();
	PACK_ML.State.Holding :			activeBaggerMode.Holding();
	PACK_ML.State.UnHolding :		activeBaggerMode.UnHolding();
	PACK_ML.State.Completing :		activeBaggerMode.Completing();
	PACK_ML.State.Aborting :		activeBaggerMode.Aborting();
	PACK_ML.State.Stopping:			activeBaggerMode.Stopping();
	PACK_ML.State.Clearing :		activeBaggerMode.Clearing();
END_CASE