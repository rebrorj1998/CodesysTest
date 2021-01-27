(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Stop
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;
SendOpcodeCommand.opcode := STEP_SERVO_OPCODES.STOP_MOVE_KILL_BUFFER;
SendOpcodeCommand.Execute();