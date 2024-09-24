(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE OPC_Inputs :
STRUCT
	fillerTrigger : BOOL; // Filler Trigger - set high to trigger cycle in filler mode
	baggerInhibit : BOOL; // Bagger Inhibit - set high to prevent a bagger cycle
	collisionDetection : BOOL; // Collision Detection - set high to indicate potential trunk line package collision
	fillerOK : BOOL;
//	EnableBagger : BOOL;  //Unused
	reverseConveyor : BOOL;  // Reverse Exit Conveyor - set high to reverse direction of rear exit conveyor
	bagGrabbed : BOOL; // Bag Grabbed - Set high to indicate bag grabbed by automation
	heartbeat : BOOL; // Heartbeat - set and reset based on heartbeatResponse.
END_STRUCT
END_TYPE
