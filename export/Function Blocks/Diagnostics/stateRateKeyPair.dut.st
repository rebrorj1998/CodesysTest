(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE stateRateKeyPair :
STRUCT
	stateID:INT:=-1;
	stateName:STRING:='';
	cycleArray:ARRAY[0..20] OF TIME;
END_STRUCT
END_TYPE
