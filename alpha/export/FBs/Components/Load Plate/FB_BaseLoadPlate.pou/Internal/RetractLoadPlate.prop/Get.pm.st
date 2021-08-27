(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
RetractLoadPlate := _manualOn OR ((_triggerActiveONS.OSR OR _shakeActiveONS.OSF) AND inUse) OR ((_estopOK.OSR OR _disabledPositionHasUpdated OR _loadPlateInUseONS.OSF) AND disabledPosition = PackageEjectionDisabledPosition.DischargePosition AND NOT inUse);
