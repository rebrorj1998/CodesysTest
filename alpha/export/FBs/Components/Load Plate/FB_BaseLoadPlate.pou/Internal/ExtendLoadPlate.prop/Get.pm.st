(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ExtendLoadPlate := (_triggerActiveONS.OSF OR _shakeActiveONS.OSR OR _manualOff AND inUse) OR (disabledPosition = PackageEjectionDisabledPosition.LoadingPosition AND NOT inUse);