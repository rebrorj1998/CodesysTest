(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_old EXTENDS FB_AppliedMotionStepServoTCP
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    sendParameters : FB_SendUserRegistersAppliedMotionTCP();
    sendBagMoveCommand : FB_SendBagMoveAppliedMotionTCP();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sendMoveCommand(Slave := slave);
sendBagMoveCommand(Slave := slave);
sendOpcodeCommand(Slave := slave);
sendParameters(Slave := slave);

commandSuccessful S= ((sendMoveCommand.xDone OR sendOpcodeCommand.xDone OR sendBagMoveCommand.xDone) AND NOT status.inPosition) OR sendParameters.xDone;