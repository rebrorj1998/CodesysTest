(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctAppliedMotionPars :
STRUCT
	Position : uModbusDWORD;
	Speed : WORD;
	Accel : WORD;
	Decel : WORD;
END_STRUCT
END_TYPE
