(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL
	modbusRTUCom : sctModbusRTUCom := (sctSettings := (sPort := SysCom.SYS_COM_PORTS.SYS_COMPORT2, ulBaudrate := 115200, byParity := 2,byStopBits := 1));
	SystemLog : FB_InternalLogger;
	
END_VAR

VAR_GLOBAL CONSTANT
	MAX_LOGGED_ITEMS : UINT := 500;	// Max items to be logged
	STEPS_PER_INCH_IBD : DINT := 1250;
	STEPS_PER_INCH_JAW : DINT := 1250;
	STEPS_PER_INCH_LOAD_PLATE : DINT := 931;
	STEPS_PER_INCH_FILM : DINT := 1000;
	SERIAL_BUFFER_SIZE : BYTE := 50;
END_VAR