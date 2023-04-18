(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mInPosition : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Set in position status if we're float =
mInPosition := TO_DINT(actPos * 1000) >= (TO_DINT(targetPosDist * 1000) - 10) AND TO_DINT(actPos * 1000) <= (TO_DINT(targetPosDist * 1000) + 10);