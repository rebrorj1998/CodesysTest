(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctModbusRTUCom :
STRUCT
	hComPort : SysCom.RTS_IEC_HANDLE;
	sctSettings : SysCom.COM_Settings;
   	pResult : SysCom.RTS_IEC_RESULT;
	xInit: BOOL;
END_STRUCT
END_TYPE