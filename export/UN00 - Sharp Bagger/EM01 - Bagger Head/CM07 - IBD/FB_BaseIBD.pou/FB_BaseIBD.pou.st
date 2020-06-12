(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseIBD EXTENDS FB_BaseComponent IMPLEMENTS I_IBD
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_MoveInToDeflate : BOOL;
	_MoveOut : BOOL;
	_RemovePower : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();