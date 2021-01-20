(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE JOG_STATES :
(
    Idle := 0,
    JogForwardDIRequest := 10,
    JogForwardOpcodeRequest := 11,
    JoggingForward := 12,
    JogReverseDIRequest := 20,
    JogReverseOpcodeRequest := 21,
    JoggingReverse := 22,
    StoppingJog := 30
);
END_TYPE
