(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE AuxIOType :
(
	None := 0,
	Physical := 1,
	OPC_UA := 2, 
	Modbus := 3 
) DINT;
END_TYPE
