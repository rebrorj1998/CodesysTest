(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE TRAFFIC_ENGINE_STATE :
(
	Idle := 0,
	TrafficDetected := 1,
	TrafficActive := 2,
	TrafficEnded := 3
);
END_TYPE
