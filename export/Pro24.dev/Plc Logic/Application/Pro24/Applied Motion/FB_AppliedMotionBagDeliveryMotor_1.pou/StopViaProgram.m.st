(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD StopViaProgram
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Load program segment 12 into buffer and execute.  This program contains nothing but a SM command.
// We must do it this way because the normal "stop command" opcode we have access to over modbus 
// also kills the program buffer which is bad.
SUPER^.Stop();