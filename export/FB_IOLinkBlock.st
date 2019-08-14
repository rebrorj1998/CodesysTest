

{attribute 'FBVisuCreator'}
FUNCTION_BLOCK FINAL FB_IOLinkBlock EXTENDS FB_Murr16PointCFGIO
VAR_INPUT
END_VAR
VAR_OUTPUT
	iIOLinkPort4 : WORD;
	iIOLinkPort5 : WORD;
	iIOLinkPort6 : WORD;
	iIOLinkPort7 : WORD;
END_VAR
VAR
END_VAR

SUPER^();

iIOLinkPort4 :=  TO_WORD(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrEIPInputs[3], B1 := ptrEIPInputs[2])); 
iIOLinkPort5 :=  TO_WORD(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrEIPInputs[5], B1 := ptrEIPInputs[4])); 
iIOLinkPort6 :=  TO_WORD(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrEIPInputs[7], B1 := ptrEIPInputs[6])); 
iIOLinkPort7 :=  TO_WORD(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrEIPInputs[9], B1 := ptrEIPInputs[8])); 