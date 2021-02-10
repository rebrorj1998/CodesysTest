(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MovePassthrough
VAR_INPUT
    PassthroughSetting : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
passthroughSetpoint := PassthroughSetting;
mustMovePassthroughOut := (passthroughSetpoint > passthroughPosition);
_movePassthrough := TRUE;