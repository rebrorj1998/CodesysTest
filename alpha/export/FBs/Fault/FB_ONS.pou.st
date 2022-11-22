(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ONS
VAR_INPUT
	CLK : BOOL;
END_VAR
VAR_OUTPUT
	OSR : BOOL;
	OSF : BOOL;
END_VAR
VAR
	CLK_OSR : R_TRIG;
	CLK_OSF : F_TRIG;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CLK_OSR(CLK := CLK, Q=> OSR);
CLK_OSF(CLK := CLK, Q=> OSF);