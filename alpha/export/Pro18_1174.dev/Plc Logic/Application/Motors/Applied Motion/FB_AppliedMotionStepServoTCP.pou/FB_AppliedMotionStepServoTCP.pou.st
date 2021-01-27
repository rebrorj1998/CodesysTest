(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionStepServoTCP EXTENDS FB_AppliedMotionStepServoMBBase IMPLEMENTS IPositionableMotor
VAR_INPUT
END_VAR
VAR_IN_OUT
    slave : IoDrvModbusTCP.ModbusTCPSlave;                    //Slave ModbusTCP Object
END_VAR
VAR_OUTPUT
END_VAR
VAR
    sendMoveCommand : FB_SendMoveCommandAppliedMotionTCP();
    sendOpcodeCommand :  FB_SendOpcodeCommandAppliedMotionTCP();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sendMoveCommand(Slave := slave);
sendOpcodeCommand(Slave := slave);

commandSuccessful S= (sendMoveCommand.xDone OR sendOpcodeCommand.xDone) AND NOT status.inPosition;