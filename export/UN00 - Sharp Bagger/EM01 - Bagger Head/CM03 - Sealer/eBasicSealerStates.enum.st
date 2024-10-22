(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
{attribute 'to_string'}
TYPE eBasicSealerStates :
(
	Idle := 0, 
	SealDwellActive := 10, 
	SealCoolActive := 20,
	Done := 30
);
END_TYPE
