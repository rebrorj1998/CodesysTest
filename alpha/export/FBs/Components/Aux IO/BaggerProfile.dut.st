(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE BaggerProfile :
(
	Standard := 0,
	EQMFT   := 00001, // MFT Automation
	EQ59126 := 59126, // ExpressScripts
	EQ22085 := 22085  // Brazeway 
) DINT;
END_TYPE
