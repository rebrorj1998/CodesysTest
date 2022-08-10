(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MurrIO EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	headNodeEnabled : BOOL;
	guardNodeEnabled : BOOL;
	printerNodeEnabled : BOOL;
	dischargeNodeEnabled : BOOL;
	auxIONodeEnabled : BOOL;
	configVersion : CONFIG_VERSIONS;
	ptrMachineOptionsManagementOutputs : POINTER TO BYTE;
	ptrSystemStatusInputs : POINTER TO BYTE;
END_VAR
VAR_OUTPUT
	MOMDataConfigFail : FB_Fault(name := 'Communication Fail - MOM configuration data is inaccurate');
	commFailController : FB_Fault(name := 'Communication Fail - Bus Master to Controller');
	commFailNode : FB_Fault(name := 'Communication Fail - Bus Master to I/O Node');
	configActive : Warning;	// I/O Configuration Active, please wait
	ok : BOOL; 		// I/O Configuration and Communication good
END_VAR
VAR
	i : INT;
	index : INT;
	specificErrorCode : INT;
	MOMFaultPresent : BOOL;
	systemStatusINT : INT;
	systemStatusState : MURR_SYSTEM_STATES;
	MOMConfigLast : BYTE;
	restartBusnodePulse : FB_MonostableMultivibrator;
END_VAR
VAR CONSTANT
	MOM_SPECIFIC_ERROR_CODE : INT := 101;
	MAX_DIAGNOSTICS_COUNT : INT := 8;
	BYTES_PER_DIAGNOSTICS_RESULT : INT := 8;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: MurrIOFB
//    Description: Alarms, faults, configuration of the Murr Cube67+ Bus Node
//    Created by: Ben Hess
//    Created Date: October 16th, 2019
SUPER^();

// Set bit 33 to true for 1 second to reset nodes
restartBusnodePulse.DwellSetting := 1000;
restartBusnodePulse(Q => ptrMachineOptionsManagementOutputs[4].1);

// Exit this FB if invaild pointers set
IF ptrMachineOptionsManagementOutputs = 0 OR ptrSystemStatusInputs = 0 THEN
	RETURN;
END_IF

// MOM config - MOM bits are counted from Slot 001 to 4xx and are counted based on the "Maximium" configuration hard coded in the bus master
// Here we can select which verison of code we have in order to utilize MOM correctly if we add additional modules in the future.
CASE configVersion OF
	CONFIG_VERSIONS.V_1_1 :		
		//
		ptrMachineOptionsManagementOutputs[0].0 := NOT headNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].1 := NOT guardNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].2 := NOT dischargeNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].3 := NOT printerNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].4 := FALSE;
									
	CONFIG_VERSIONS.V_1_2, CONFIG_VERSIONS.V_1_3,CONFIG_VERSIONS.V_1_4 : 		
		// Added aux IO to 1.2 and BCV trigger to 1.3
		ptrMachineOptionsManagementOutputs[0].0 := NOT headNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].1 := NOT guardNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].2 := NOT auxIONodeEnabled;
		ptrMachineOptionsManagementOutputs[0].3 := NOT dischargeNodeEnabled;
		ptrMachineOptionsManagementOutputs[0].4 := NOT printerNodeEnabled;
END_CASE

// init loop index
index := 7;

// init MOM fault present
MOMFaultPresent := FALSE;

// Loop through all 8 possible diagnostics looking for MOM error
FOR i := 0 TO MAX_DIAGNOSTICS_COUNT-1 DO
	specificErrorCode := ptrSystemStatusInputs[index];
	IF specificErrorCode = MOM_SPECIFIC_ERROR_CODE THEN
		MOMFaultPresent := TRUE;
	END_IF
	index := index + BYTES_PER_DIAGNOSTICS_RESULT;
END_FOR
MOMDataConfigFail.faultTrigger := MOMFaultPresent;

// Run config if IO bus node is waiting on config
systemStatusINT := ptrSystemStatusInputs^;
systemStatusState := systemStatusINT;

// Prevent a IO node reset on boot for no reason
IF Globals.firstScan THEN
	MOMConfigLast := ptrMachineOptionsManagementOutputs[0];
END_IF

// Trigger fault for node not present, or node seen where one shouldn't be 
IF systemStatusState = MURR_SYSTEM_STATES.No_Comm_To_Configured_Node THEN
	commFailNode.Trigger();
END_IF

// A 0 at system state indicates comm fail to controller
IF systemStatusState = 0 THEN
	commFailController.Trigger();
END_IF

// Alert user to MOM config active
IF systemStatusState = MURR_SYSTEM_STATES.Waiting_For_MOM OR
   systemStatusState = MURR_SYSTEM_STATES.Configuring_MOM OR
   systemStatusState = MURR_SYSTEM_STATES.Internal_Comm_Disabled THEN
	configActive.active := TRUE;
ELSE
	configActive.active := FALSE;
END_IF

// I/O Block is OK only in this state, otherwise we can't trust any I/O coming back
ok := (systemStatusState = MURR_SYSTEM_STATES.Internal_Comm_OK);

CASE systemStatusState OF
	MURR_SYSTEM_STATES.Waiting_For_MOM: 			
		// Bit 32 is Configure MOM bit
		ptrMachineOptionsManagementOutputs[4].0 := TRUE;
		ptrMachineOptionsManagementOutputs[4].1 := FALSE;
												
	MURR_SYSTEM_STATES.Configuring_MOM : 			
		ptrMachineOptionsManagementOutputs[4].0 := FALSE;															
ELSE
		ptrMachineOptionsManagementOutputs[4].0 := FALSE;
		//IF config changes here, send it down after restarting
		IF ptrMachineOptionsManagementOutputs[0] <> MOMConfigLast THEN
			restartBusnodePulse.Trigger();
			MOMConfigLast := ptrMachineOptionsManagementOutputs[0];
		END_IF
END_CASE												