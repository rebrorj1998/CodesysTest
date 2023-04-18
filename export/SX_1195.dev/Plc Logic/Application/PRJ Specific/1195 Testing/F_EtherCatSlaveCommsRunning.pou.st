(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION F_EtherCatSlaveCommsRunning : BOOL
VAR_INPUT
	state : IoDrvEthercatLib.ETC_SLAVE_STATE;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
F_EtherCatSlaveCommsRunning := NOT (state = IoDrvEthercatLib.ETC_SLAVE_STATE.ETC_SLAVE_INIT);
