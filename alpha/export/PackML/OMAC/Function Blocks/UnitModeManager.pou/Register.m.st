(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Registers an unit mode
METHOD Register : BOOL
VAR_INPUT
	pum: IUnitMode;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF usiNumberOfUMs < gc_usiMaxModes THEN
	usiNumberOfUMs := usiNumberOfUMs + 1;
	apum[usiNumberOfUMs] := pum;
	IF usiActualUM = 0 THEN
		usiActualUM := 1;
		apum[usiNumberOfUMs].Active := TRUE;
	ELSE
		apum[usiNumberOfUMs].Active := FALSE;
	END_IF
	Register := TRUE;
END_IF
