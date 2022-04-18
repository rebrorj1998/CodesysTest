(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD INTERNAL ClearSegments : BOOL
VAR_INPUT
END_VAR
VAR
	i : INT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Set all segments to OFF
FOR i := TL50Segments.Top TO TL50Segments.Bottom BY -1 DO
	_segments[i] := _segmentOffProfile;
END_FOR