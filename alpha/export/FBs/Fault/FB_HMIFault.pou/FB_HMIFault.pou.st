(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_HMIFault IMPLEMENTS IExecuteAutomatically, IAllObjects, IInitializable
VAR_INPUT
	refFault : REFERENCE TO FB_Fault;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	active : REFERENCE TO BOOL;
	acknowledged : REFERENCE TO BOOL;
	ackCommand : REFERENCE TO BOOL;
	_instanceName : STRING := 'HMI Fault';
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
