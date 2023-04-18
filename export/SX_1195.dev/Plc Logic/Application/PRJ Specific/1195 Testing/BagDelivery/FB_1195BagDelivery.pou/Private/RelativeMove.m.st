(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE RelativeMove
VAR_INPUT
	timeOut : TIME;
	velocity : REAL;
	distance : REAL;
	description : STRING;
	state : eBagDeliveryStates;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
MC_BagDeliveryRelativeMove.Deceleration := MC_BagDeliveryRelativeMove.Acceleration := (velocity / trapezoidalPercent);
MC_BagDeliveryRelativeMove.Velocity := velocity;
MC_BagDeliveryRelativeMove.Distance := distance;
MC_BagDeliveryRelativeMove.currentLimit := 100.0;
MC_BagDeliveryRelativeMove.Execute := TRUE;
moveBagDeliveryTimeout.IN := TRUE;
moveBagDeliveryTimeout.PT := timeOut;
_logger.AddLogItem(CONCAT(_prefix, description));
THIS^.state := state;