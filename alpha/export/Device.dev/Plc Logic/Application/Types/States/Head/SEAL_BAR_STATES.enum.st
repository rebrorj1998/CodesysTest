(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE SEAL_BAR_STATES :
(
	Idle := 0,
	ExtendSealBar := 10,
	ExtendingSealBar := 11,
	SealBarExtened := 12,
	RetractSealBar := 20,
	RetractingSealBar := 21,
	RetractedSealBar := 22,
	Fault := 99
);
END_TYPE
