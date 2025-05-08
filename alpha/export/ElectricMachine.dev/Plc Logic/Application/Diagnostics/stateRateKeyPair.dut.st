(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE stateRateKeyPair :
STRUCT
	stateID:INT:=-1;
	stateName:STRING:='';
	cycleArray:ARRAY[0..20] OF TIME;
	t_stampArray:ARRAY[0..20] OF ULINT;
	uidArray:ARRAY[0..20] OF STRING(10);
END_STRUCT
END_TYPE
