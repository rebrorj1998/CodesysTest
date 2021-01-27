(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD HomeNow
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//Load program 1 into queue by setting it as parameter 1 and send it and the execute queue opcode
ExecuteStoredProgram(QX_PROGRAMS.HOME_HARD_STOP);
HomeRequired := FALSE;