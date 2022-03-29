(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM Faults
VAR
	reverseFault : FB_HMIFault;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
reverseFault(refFault := PRG_Bagger.moabHead.bagDeliverySynchronous.reverseFault);