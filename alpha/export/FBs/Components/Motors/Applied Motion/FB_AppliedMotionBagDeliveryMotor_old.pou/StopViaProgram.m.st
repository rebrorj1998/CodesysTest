(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD StopViaProgram
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Load program segment 12 into buffer and execute.  This program contains nothing but a SM command.
// We must do it this way because the normal "stop command" opcode we have access to over modbus 
// also kills the program buffer which is bad.
commandSuccessful := FALSE;
SendOpcodeCommand.opcode := STEP_SERVO_OPCODES.QUEUE_LOAD_AND_EXECUTE;
SendOpcodeCommand.Parameter1 := INT_TO_WORD(12);    //program 12 is just a SM command
SendOpcodeCommand.Execute();