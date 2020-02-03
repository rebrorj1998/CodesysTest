(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD CheckIfParSendSuccessful : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//Check to make sure we have a valid reference.  Disable complier warning since we're doing the check
{warning disable C0371}
IF NOT __ISVALIDREF(parameterSettingsBuffer) THEN
     RETURN;
END_IF

//Check if parameters from drive match the ones we sent

CheckIfParSendSuccessful := (parameterSettingsBuffer[0] = INT_TO_WORD(accelerationFromMotor) AND parameterSettingsBuffer[1] = INT_TO_WORD(decelerationFromMotor) AND parameterSettingsBuffer[2] = INT_TO_WORD(velocityFromMotor) AND parameterSettingsBuffer[3] = distanceHighWordFromMotor AND parameterSettingsBuffer[4] = distanceLowWordFromMotor);
{warning restore C0371}