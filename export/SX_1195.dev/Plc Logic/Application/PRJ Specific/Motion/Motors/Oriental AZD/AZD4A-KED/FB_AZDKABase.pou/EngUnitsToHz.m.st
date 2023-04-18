(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD EngUnitsToHz : REAL
VAR_INPUT
	engineeringUnits : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
EngUnitsToHz := ((engineeringUnits * axisData.config.rotationsPerInch) * 10000);