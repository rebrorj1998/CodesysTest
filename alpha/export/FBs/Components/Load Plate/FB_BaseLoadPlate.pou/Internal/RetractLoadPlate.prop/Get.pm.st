(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
RetractLoadPlate := (_triggerActiveONS.OSR OR _shakeActiveONS.OSF OR _manualOn AND inUse) OR (disabledPosition = PackageEjectionDisabledPosition.DischargePosition AND NOT inUse);  