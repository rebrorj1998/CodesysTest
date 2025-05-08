(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eCognexDM374States :
(
	Idle := 0,
	TriggerEnable := 1,	
	Trigger:=2,
	WaitForResults := 3,
	FlushOutBuffer := 4
	
);
END_TYPE
