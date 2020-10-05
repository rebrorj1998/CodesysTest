(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mSetFeedToLength
VAR_INPUT
	position:DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
modbusDwordBuffer.diDint := position;
filmFeedDriveOutputs[3] := modbusDwordBuffer.wWord[1];
filmFeedDriveOutputs[4] := modbusDwordBuffer.wWord[0];
triggerFilmDriveOutputUpdate := TRUE;