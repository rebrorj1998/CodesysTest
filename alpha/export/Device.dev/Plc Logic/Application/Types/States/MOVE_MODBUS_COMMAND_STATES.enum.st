(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE MOVE_MODBUS_COMMAND_STATES :
(
	Idle := 0,
	SendParameters := 10,
	WaitAfterParametersSent := 11,
	SendOpcode := 20,
	WaitAfterOpcodeSent := 21,
	SendCommand := 31,
	WaitAfterCommandSent := 32,
	SendClearCommand := 40,
	WaitAfterSendClearCommand := 41,
	Fault := 99
);
END_TYPE
