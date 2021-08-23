(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE COLLISION_DETECTION_STATE :
(
	Idle := 0,
	CollisionDetected := 1,
	CollisionActive := 2,
	CollisionEnded := 3
);
END_TYPE
