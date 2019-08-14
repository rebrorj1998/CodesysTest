

FUNCTION_BLOCK FINAL FB_MachineCounter EXTENDS FB_BaseObject IMPLEMENTS ICounter
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR PERSISTENT RETAIN
    count : UDINT;
END_VAR



METHOD Clear
VAR_INPUT
END_VAR

count := 0;

METHOD Increment
VAR_INPUT
END_VAR

count := count + 1;

METHOD SetCount
VAR_INPUT
	countSetting : UDINT;
END_VAR

count := countSetting;

METHOD AddToCount
VAR_INPUT
	amountToAdd : UDINT;
END_VAR

count := count + amountToAdd;