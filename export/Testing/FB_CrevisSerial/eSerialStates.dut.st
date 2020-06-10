(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eSerialStates :
(
	Idle := 0,
	writeOutBuffer := 10,
	writingOutBuffer := 11,
	waitForResponse := 12,
	getResponse := 13,
	gettingResponse := 14, 
	Done := 100
);
END_TYPE
