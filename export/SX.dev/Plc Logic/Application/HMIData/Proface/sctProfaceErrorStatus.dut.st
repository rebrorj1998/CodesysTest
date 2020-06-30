(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctProfaceErrorStatus :
STRUCT
	backupDataError : BOOL; // Backup Data Error
	smChecksum : BOOL;		// Screen Memory Checksum
	sioFraming : BOOL;		// SIO Framing
	sioParity : BOOL;		// SIO Parity
	sioOverrun : BOOL;		// SIO Overrun
	battRep	:	BOOL;		// Replace Backup Battery
	battFail : BOOL;		// Backup battery has run out
	plcComm : BOOL;			// PLC Communication Error
END_STRUCT
	
END_TYPE
