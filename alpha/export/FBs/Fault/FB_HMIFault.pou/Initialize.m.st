(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Initialize
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
active REF= refFault.active;
acknowledged REF= refFault.acknowledged;
ackCommand  REF= refFault.ackCommand;
_instanceName := CONCAT('HMI Fault - ', refFault.InstanceName);