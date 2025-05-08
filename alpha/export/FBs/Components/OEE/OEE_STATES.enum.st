(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE OEE_STATES :
(
	Idle := 0,
	Faulted := 10, 
	Running := 20,
	ExemptFault := 30,
	QualityFault := 40
);
END_TYPE
