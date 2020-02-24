(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FaultUpdateForHMI
VAR_INPUT
END_VAR
VAR
	I : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR I:= 0 TO _TotalObj - 1 DO
	IF NOT _InitFaultList THEN
		faults[I].name := Collection[I].InstanceName;
	END_IF
	faults[I].active := Collection[I].FaultActive;
END_FOR
_InitFaultList := TRUE;