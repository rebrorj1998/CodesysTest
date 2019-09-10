

FUNCTION_BLOCK FINAL FB_Fault IMPLEMENTS IFault, ILoggable, IExecuteAutomatically
VAR_INPUT
	ackCommand : BOOL;
	faultTrigger : BOOL;
END_VAR
VAR_OUTPUT
	acknowledged : BOOL;
	active : BOOL;
END_VAR
VAR
	_active : BOOL;
	_acked : BOOL;
	_ackCommand : BOOL;
	_logger : IMachineLogger;
	ackCommandOSR : R_TRIG;
	faultTriggerONS : FB_ONS;
	activeONS : FB_ONS;
	_instanceName : STRING;
END_VAR
VAR_IN_OUT
	
END_VAR


METHOD Execute

//	Function Block: FB_Fault
//	Description: Faults should be of this FB type.  
//  An associated FaultType variable needs to be declared in the HMIData global variable list in order to be exposed via OPCUA 
//	Implementation should look as follows:
//
//  *** Instantiate the fault with constructor that contains the fault name: ***
//  VAR (*Faults*)
//		exampleFault1 : FB_Fault(name := CONCAT(_prefix,  'Example Fault 1'));
//		exampleFault2 : FB_Fault(name := CONCAT(_prefix,  'Example Fault 2'));
//  END_VAR
//
//  *** In alarm area of FB call the fault(s). refHMIFaults is passed in from above***
//  IF __ISVALIDREF(refHMIFaults) THEN
//		exampleFault1(HMIFault := refHMIFaults.exampleFault1);
//		exampleFault2(HMIFault := refHMIFaults.exampleFault2, faultTrigger := someFaultCondition);
//  END_IF
//
//	*** Either assign faultTrigger in call (as in exampleFault2 above) or set it later in logic
//	exampleFault1.faultTrigger := someFaultCondition;
//
//	Created by: Ben Hess
//	Created Date: Tuesday, May 22, 2018


{warning 'TODO: Add reference to device faulted indicaiton?'}
ackCommandOSR(CLK := _ackCommand);
faultTriggerONS(CLK := faultTrigger);
activeONS(CLK := _active);

IF faultTriggerONS.OSR THEN
	Trigger();
END_IF

IF ackCommandOSR.Q THEN
	_acked := TRUE;
	_ackCommand := FALSE;
END_IF

IF _acked AND NOT faultTrigger THEN
	_active := FALSE;
	_acked := FALSE;
END_IF

IF activeONS.OSF THEN
	GlobalObjects.CollectionOfActiveFaults.RemoveObject(THIS^);
	_logger.AddLogItem(CONCAT(InstanceName, ' Cleared'));
END_IF

// The following is for external communication to HMI etc.
IF ackCommand THEN
	Ack();
	ackCommand := FALSE;
END_IF
active := _active;
acknowledged := _acked;


PROPERTY InstanceName : STRING


METHOD RegisterLogger
VAR_INPUT
	internalLogger : IMachineLogger;
END_VAR

_logger := internalLogger;

METHOD Ack
IF _ackCommand OR _acked THEN
	RETURN;
END_IF
_acked := TRUE;
// Log the ACK.
_logger.AddLogItem(CONCAT(InstanceName,  ' Acked'));

METHOD Trigger

IF _active = TRUE THEN
	RETURN;
END_IF
_active := TRUE;
GlobalObjects.CollectionOfActiveFaults.AddObject(THIS^);
_logger.AddLogItem(CONCAT(InstanceName,  ' Active'));

METHOD FB_Init : BOOL
VAR_INPUT
  bInitRetains : BOOL; // TRUE: the retain variables are initialized (reset warm / reset cold)
  bInCopyCode : BOOL;  // TRUE: the instance will be copied to the copy code afterward (online change)
  name : STRING;
END_VAR

_instanceName := name;
GlobalObjects.CollectionOfAllObjects.AddObject(THIS^);