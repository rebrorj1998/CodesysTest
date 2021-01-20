(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE IOMasterFaultsType :
STRUCT
	commFail : FB_Fault(name := 'Communication Fail');	// IO Master to Controller Communication Failure
END_STRUCT
END_TYPE
