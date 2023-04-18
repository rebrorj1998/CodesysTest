(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Stop : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_activeKeepJawCycling := FALSE;
_axis1ABSPush.execute := FALSE;
_axis1ABS_in.execute := FALSE;
_axis1Reset.execute := FALSE;
_jawState := 0;