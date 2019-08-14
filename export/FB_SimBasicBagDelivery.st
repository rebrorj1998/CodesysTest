

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



{attribute 'monitoring' := 'variable'}
PROPERTY BagFeedDone : BOOL


METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR

feedAtPrintSpeed.in := FALSE;
feedBagOut.in := FALSE;
feedToPrintOffset.in := FALSE;
reverseToSeparate.in := FALSE;
THIS^.Execute();

{attribute 'monitoring' := 'variable'}
PROPERTY BagSeparated : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY ReadyForPrint : BOOL


METHOD ReverseToSeparate

ClearStatus();
reverseToSeparate.maxDelay := TO_DINT(((reverseLength / TO_REAL(reverseSpeed)) * 1000) + 50.0);  
reverseToSeparate.minDelay := TO_DINT(((reverseLength / TO_REAL(reverseSpeed)) * 1000) + 10.0);  
reverseToSeparate.in := TRUE;

METHOD FeedToPrintOffset

ClearStatus();
feedToPrintOffset.maxDelay := TO_DINT(((printOffset / TO_REAL(feedSpeed)) * 1000) + 50.0);  
feedToPrintOffset.minDelay := TO_DINT(((printOffset / TO_REAL(feedSpeed)) * 1000) + 20.0);  
feedToPrintOffset.in := TRUE;

METHOD FeedAtPrintSpeed

ClearStatus();
feedAtPrintSpeed.maxDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 50.0);  
feedAtPrintSpeed.minDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 10.0);  
feedAtPrintSpeed.in := TRUE;

METHOD FeedBagOut

ClearStatus();
feedBagOut.maxDelay := TO_DINT(((bagLength / TO_REAL(feedSpeed)) * 1000) + 50.0);  
feedBagOut.minDelay := TO_DINT(((bagLength / TO_REAL(feedSpeed)) * 1000) + 10.0);  
feedBagOut.in := TRUE;

METHOD Execute

SUPER^.Execute();
feedAtPrintSpeed();
feedBagOut();
feedToPrintOffset();
reverseToSeparate();

METHOD FeedToPhotoeye
VAR_INPUT
END_VAR



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



{attribute 'monitoring' := 'variable'}
PROPERTY BagFeedDone : BOOL


METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR

feedAtPrintSpeed.in := FALSE;
feedBagOut.in := FALSE;
feedToPrintOffset.in := FALSE;
reverseToSeparate.in := FALSE;
THIS^.Execute();

{attribute 'monitoring' := 'variable'}
PROPERTY BagSeparated : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY ReadyForPrint : BOOL


METHOD ReverseToSeparate

ClearStatus();
reverseToSeparate.maxDelay := TO_DINT(((reverseLength / TO_REAL(reverseSpeed)) * 1000) + 50.0);  
reverseToSeparate.minDelay := TO_DINT(((reverseLength / TO_REAL(reverseSpeed)) * 1000) + 10.0);  
reverseToSeparate.in := TRUE;

METHOD FeedToPrintOffset

ClearStatus();
feedToPrintOffset.maxDelay := TO_DINT(((printOffset / TO_REAL(feedSpeed)) * 1000) + 50.0);  
feedToPrintOffset.minDelay := TO_DINT(((printOffset / TO_REAL(feedSpeed)) * 1000) + 20.0);  
feedToPrintOffset.in := TRUE;

METHOD FeedAtPrintSpeed

ClearStatus();
feedAtPrintSpeed.maxDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 50.0);  
feedAtPrintSpeed.minDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 10.0);  
feedAtPrintSpeed.in := TRUE;

METHOD FeedBagOut

ClearStatus();
feedBagOut.maxDelay := TO_DINT(((bagLength / TO_REAL(feedSpeed)) * 1000) + 50.0);  
feedBagOut.minDelay := TO_DINT(((bagLength / TO_REAL(feedSpeed)) * 1000) + 10.0);  
feedBagOut.in := TRUE;

METHOD Execute

SUPER^.Execute();
feedAtPrintSpeed();
feedBagOut();
feedToPrintOffset();
reverseToSeparate();

METHOD FeedToPhotoeye
VAR_INPUT
END_VAR

