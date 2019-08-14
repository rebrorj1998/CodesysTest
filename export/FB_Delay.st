

FUNCTION_BLOCK FB_Delay IMPLEMENTS IExecuteAutomatically
VAR_INPUT
	in : BOOL;
	delay : TIME;
END_VAR
VAR_OUTPUT
	Q : BOOL;
END_VAR
VAR
	delayTimer : TON;
END_VAR



METHOD Execute

delayTimer(IN := in, PT := delay, Q => Q);