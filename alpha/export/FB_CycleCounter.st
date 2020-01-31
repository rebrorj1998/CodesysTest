

FUNCTION_BLOCK FB_CycleCounter
VAR_INPUT
	reset : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
    count : UDINT;
END_VAR

IF reset THEN
	THIS^.Clear();
	reset := FALSE;
END_IF

METHOD Increment
VAR_INPUT
END_VAR

count := count + 1;

METHOD Clear
VAR_INPUT
END_VAR

count := 0;

METHOD SetCount
VAR_INPUT
	countSetting : UDINT;
END_VAR

count := countSetting;