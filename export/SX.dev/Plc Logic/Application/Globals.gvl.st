(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL
	modbusRTUCom : sctModbusRTUCom := (sctSettings := (sPort := SysCom.SYS_COM_PORTS.SYS_COMPORT2, ulBaudrate := 115200, byParity := 2,byStopBits := 1));
END_VAR