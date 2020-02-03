(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE OPCODE_MODBUS_COMMAND_STATES :
(
	Idle := 0,
	SendOpcodeAndParameters := 10,
	WaitAfterOpcodeAndParametersSent := 11,
	Fault := 99
);
END_TYPE
