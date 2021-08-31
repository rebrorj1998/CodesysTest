(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
LoadPlateToLoad := _manualOff OR ((_triggerActiveONS.OSF OR _shakeActiveONS.OSR OR _loadPlateInUseONS.OSR) AND inUse) OR ((_estopOK.OSR OR _disabledPositionHasUpdated OR _loadPlateInUseONS.OSF) AND disabledPosition = PackageEjectionDisabledPosition.LoadingPosition AND NOT inUse);
IF LoadPlateToLoad THEN
	RETURN;
END_IF