(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FB_Init : BOOL
VAR_INPUT
  bInitRetains : BOOL; // TRUE: the retain variables are initialized (reset warm / reset cold)
  bInCopyCode : BOOL;  // TRUE: the instance will be copied to the copy code afterward (online change)
  name : STRING;
END_VAR
VAR
	_j : DINT;
	_totalOEEExempt : DINT := GlobalObjects.OEE_EXEMPT_LIST_LENGTH;
	_totalPassiveExempt : DINT := GlobalObjects.PASSIVE_EXEMPT_LIST_LENGTH;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_instanceName := name;
GlobalObjects.CollectionOfAllObjects.AddObject(THIS^);
FOR _j := 1 TO _totalOEEExempt DO
	IF GlobalObjects.OEEExemptList[_j] = name THEN
		_isOEEExempt := TRUE;
	END_IF
END_FOR

FOR _j := 1 TO _totalPassiveExempt DO
	IF GlobalObjects.passiveList[_j] = name THEN
		_isPassiveExempt := TRUE;
	END_IF
END_FOR
