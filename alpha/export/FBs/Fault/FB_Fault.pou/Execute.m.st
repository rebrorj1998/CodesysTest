(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
