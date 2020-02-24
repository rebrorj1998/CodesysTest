(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
InPosition := 	moveToBagFeed.Q OR 
				moveToBagHolding.Q OR
				moveToClearance.Q OR
				moveToSeal.Q OR
				moveToIn.Q;