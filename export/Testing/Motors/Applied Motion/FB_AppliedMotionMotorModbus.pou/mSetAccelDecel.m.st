(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mSetAccelDecel
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF modbusDataFromDrive[27] <> ACCEL_DECEL_RATE_IN_RPM THEN // filmFeedDriveInputs[27] = Drives Current Accel Rate, 1 = 10RPM/S
	modbusRIODataToDrive[0] := modbusRIODataToDrive[1] := ACCEL_DECEL_RATE_IN_RPM;
END_IF