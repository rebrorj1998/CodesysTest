(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ExecuteStoredProgram
VAR_INPUT
    (*Program number to execute*)
    programNumber    : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//Load program into queue by setting it as parameter 1 and send it and the execute queue opcode
commandSuccessful := FALSE;
SendOpcodeCommand.opcode := STEP_SERVO_OPCODES.QUEUE_LOAD_AND_EXECUTE;
SendOpcodeCommand.Parameter1 := INT_TO_WORD(programNumber);
SendOpcodeCommand.Execute();