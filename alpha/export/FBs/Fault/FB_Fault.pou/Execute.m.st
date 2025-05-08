(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_Fault
//	Description: Faults should be of this FB type.  
//	Implementation should look as follows:
//
//  *** Instantiate the fault with constructor that contains the fault name: ***
//  VAR (*Faults*)
//		exampleFault1 : FB_Fault(name := CONCAT(_prefix,  'Example Fault 1'));
//		exampleFault2 : FB_Fault(name := CONCAT(_prefix,  'Example Fault 2'));
//  END_VAR
//
//	*** Either assign faultTrigger in call or set it later in logic
//	exampleFault1.faultTrigger := someFaultCondition;
//
//	Created by: Ben Hess
//	Created Date: Tuesday, May 22, 2018

//
_passiveOSF(CLK := _passive);

//
_passiveTimeout(IN := _passive, PT := TO_TIME(_timeoutDwell * 1000));
IF _passiveTimeout.Q THEN
	THIS^.Trigger();
	_passive := FALSE;
END_IF

//
_faultTriggerONS(CLK := faultTrigger);
IF _faultTriggerONS.OSR THEN
	Trigger();
END_IF

//
_ackOSR(CLK := _ack);
IF _ackOSR.Q THEN
	_acked := TRUE;
	_ack := FALSE;
END_IF

//
IF _acked THEN
	_acked := FALSE;
	IF NOT faultTrigger THEN
		active := FALSE;
	END_IF
	_passive := FALSE;
END_IF

//
_activeONS(CLK := active);
IF _activeONS.OSF THEN
	GlobalObjects.CollectionOfActiveFaults.RemoveObject(THIS^);
	IF _isOEEExempt THEN
		GlobalObjects.CollectionOfOEEExemptFaults.RemoveObject(THIS^);
	END_IF
	IF _isPassiveExempt THEN
		GlobalObjects.CollectionOfPassiveExemptFaults.RemoveObject(THIS^);
	END_IF
	_logger.AddLogItem(CONCAT(InstanceName, ' Active Cleared'));
ELSIF _activeONS.OSR OR _passiveOSF.Q THEN
	GlobalObjects.CollectionOfPassiveFaults.RemoveObject(THIS^);
	//_logger.AddLogItem(CONCAT(InstanceName, ' Passive Cleared'));
END_IF
