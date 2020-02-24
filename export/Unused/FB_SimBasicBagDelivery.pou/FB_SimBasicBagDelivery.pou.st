(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SimBasicBagDelivery EXTENDS FB_BaseComponent IMPLEMENTS IBagDelivery, IExecuteAutomatically
VAR_INPUT
	feedSpeed : UDINT;
	reverseSpeed : UDINT;
	printSpeed : UDINT;
	printLength : REAL;
	bagLength : REAL;
	reverseLength : REAL;
	printOffset : REAL;
END_VAR
VAR_OUTPUT
END_VAR

VAR
	feedAtPrintSpeed : FB_SimulatedFeedback(name := CONCAT(_prefix,'Feed at Print Speed'));
	feedBagOut : FB_SimulatedFeedback(name := CONCAT(_prefix,'Feed Bag Out'));
	feedToPrintOffset : FB_SimulatedFeedback(name := CONCAT(_prefix,'Feed to Print Offset'));
	reverseToSeparate : FB_SimulatedFeedback(name := CONCAT(_prefix,'Reverse to Separate'));
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
