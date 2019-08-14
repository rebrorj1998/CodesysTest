

FUNCTION_BLOCK FB_BaseObject IMPLEMENTS IAllObjects, ILoggable
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_instanceName : STRING;			// Instance Name
	_prefix : STRING;
	_logger : IMachineLogger;
END_VAR



METHOD FB_Init : BOOL
VAR_INPUT
  bInitRetains : BOOL; // TRUE: the retain variables are initialized (reset warm / reset cold)
  bInCopyCode : BOOL;  // TRUE: the instance will be copied to the copy code afterward (online change)
  name : STRING;
END_VAR

_instanceName := name;
_prefix := CONCAT(name, ' ');
GlobalObjects.CollectionOfAllObjects.AddObject(THIS^);

{attribute 'monitoring' := 'variable'}
PROPERTY InstanceName : STRING

METHOD RegisterLogger
VAR_INPUT
	internalLogger : IMachineLogger;
END_VAR

_logger := internalLogger;