(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE uModbusDWORD :
UNION
	wWord : ARRAY[0..1] OF WORD;
	dDword : DWORD;
	diDint : DINT;
END_UNION
END_TYPE
