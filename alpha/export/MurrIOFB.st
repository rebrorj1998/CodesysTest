

FUNCTION_BLOCK MurrIOFB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
	headNodeEnabled : BOOL;
	guardNodeEnabled : BOOL;
	printerNodeEnabled : BOOL;
	dischargeNodeEnabled : BOOL;
	auxIONodeEnabled : BOOL;
	configVersion : CONFIG_VERSIONS;
	MachineOptionsManagementOutputs : POINTER TO BYTE;
	SystemStatusInputs : POINTER TO BYTE;
END_VAR
VAR_OUTPUT
	

END_VAR
VAR
	systemStatusINT : INT;
	systemStatusState : MURR_SYSTEM_STATES;
	toggleConfig : OSCAT_BASIC.GEN_SQ;
	MOMConfigLast : BYTE;
	restartBusnodePulse : MonostableMultivibratorFB;
END_VAR
	
VAR_IN_OUT

END_VAR

//    Function Block: MurrIOFB
//    Description: Alarms, faults, configuration of the Murr Cube67+ Bus Node
//    Created by: Ben Hess
//    Created Date: October 16th, 2019
SUPER^();
toggleConfig(PT := T#20MS);
restartBusnodePulse.DwellSetting := 1000;
restartBusnodePulse(Q => MachineOptionsManagementOutputs[4].1);

IF MachineOptionsManagementOutputs = 0 OR SystemStatusInputs = 0 THEN
	RETURN;
END_IF

// MOM config - MOM bits are counted from Slot 001 to 4xx and are counted based on the "Maximium" configuration hard coded in the bus master
// Here we can select which verison of code we have in order to utilize MOM correctly if we add additional modules in the future.
CASE configVersion OF
	CONFIG_VERSIONS.V_1_1 :		//
									MachineOptionsManagementOutputs[0].0 := NOT headNodeEnabled;
									MachineOptionsManagementOutputs[0].1 := NOT guardNodeEnabled;
									MachineOptionsManagementOutputs[0].2 := NOT dischargeNodeEnabled;
									MachineOptionsManagementOutputs[0].3 := NOT printerNodeEnabled;
									MachineOptionsManagementOutputs[0].4 := FALSE;
									
								

	CONFIG_VERSIONS.V_1_2 : 		// Added aux IO to this version
									MachineOptionsManagementOutputs[0].0 := NOT headNodeEnabled;
									MachineOptionsManagementOutputs[0].1 := NOT guardNodeEnabled;
									MachineOptionsManagementOutputs[0].2 := NOT auxIONodeEnabled;
									MachineOptionsManagementOutputs[0].3 := NOT dischargeNodeEnabled;
									MachineOptionsManagementOutputs[0].4 := NOT printerNodeEnabled;
END_CASE


// Run config if IO bus node is waiting on config
systemStatusINT := SystemStatusInputs^;
systemStatusState := systemStatusINT;
IF Globals.firstScan THEN
	MOMConfigLast := MachineOptionsManagementOutputs[0];
END_IF
CASE systemStatusState OF
	//MURR_SYSTEM_STATES.Internal_Comm_OK:			// If config changes here, send it down
// 													IF MachineOptionsManagementOutputs[0] <> MOMConfigLast THEN
// 														MachineOptionsManagementOutputs[4].0 := TRUE;
// 														MOMConfigLast := MachineOptionsManagementOutputs[0];
// 													END_IF
	
	MURR_SYSTEM_STATES.Waiting_For_MOM: 			// Bit 32 is Configure Node
													MachineOptionsManagementOutputs[4].0 := TRUE;
													MachineOptionsManagementOutputs[4].1 := FALSE;		
	
	MURR_SYSTEM_STATES.Configuring_MOM : 			//
													MachineOptionsManagementOutputs[4].0 := FALSE;
											

														
											
ELSE
													MachineOptionsManagementOutputs[4].0 := FALSE;
													//IF config changes here, send it down after restarting
													IF MachineOptionsManagementOutputs[0] <> MOMConfigLast THEN
														restartBusnodePulse.Trigger();
														MOMConfigLast := MachineOptionsManagementOutputs[0];
													END_IF
END_CASE												

PROPERTY Mode : DEVICE_MODES


PROPERTY Ready : BOOL
