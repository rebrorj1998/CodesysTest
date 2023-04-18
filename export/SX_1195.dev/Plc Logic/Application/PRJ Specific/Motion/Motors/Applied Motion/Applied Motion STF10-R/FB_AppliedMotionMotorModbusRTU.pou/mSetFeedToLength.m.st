(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mSetFeedToLength
VAR_INPUT
	position:DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
modbusDwordBuffer.diDint := position;
modbusRIODataToDrive[3] := modbusDwordBuffer.wWord[1];
modbusRIODataToDrive[4] := modbusDwordBuffer.wWord[0];
modbusRIODataTrigger := TRUE;