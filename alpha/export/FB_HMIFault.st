

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



PROPERTY InstanceName : STRING


METHOD FB_Init : BOOL
VAR_INPUT
  bInitRetains : BOOL; // TRUE: the retain variables are initialized (reset warm / reset cold)
  bInCopyCode : BOOL;  // TRUE: the instance will be copied to the copy code afterward (online change)
END_VAR

GlobalObjects.CollectionOfAllObjects.AddObject(THIS^);

METHOD FB_Reinit : BOOL
VAR_INPUT
END_VAR

THIS^.Initialize();

METHOD Initialize
VAR_INPUT
END_VAR

active REF= refFault.active;
acknowledged REF= refFault.acknowledged;
ackCommand  REF= refFault.ackCommand;
_instanceName := CONCAT('HMI Fault - ', refFault.InstanceName);

METHOD Execute
VAR 
	
END_VAR
