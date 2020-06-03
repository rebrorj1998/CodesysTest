(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RunTestFBs
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
testee();

MC_MoveABSTestee(Axis := testee);
MC_MoveABSTorqueTestee(Axis := testee);
MC_MoveRELTestee(Axis := testee);
MC_PowerTestee(Enable := TRUE, Axis := testee);
MC_HomeTestee(Axis := testee);