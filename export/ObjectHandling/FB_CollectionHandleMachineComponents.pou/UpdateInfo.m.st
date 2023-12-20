(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD UpdateInfo : BOOL
VAR_INPUT
END_VAR
VAR
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR J:= 0 TO _TotalObj - 1 DO
		ActiveState[J]:= Collection[J].StateString;
		Ready[J] :=  Collection[J].Ready;
		InUse[J] := Collection[J].OptionActive AND Collection[J].OptionEnabled;
END_FOR