

FUNCTION_BLOCK FB_SimulatedFeedbackPhysicalInput EXTENDS FB_SimulatedFeedback
VAR_INPUT
	inputToSimulate : REFERENCE TO FB_PhysicalDigitalInput;					
END_VAR
VAR_OUTPUT

END_VAR
VAR

END_VAR

//	Function Block: FB_SimulatedFeedbackPhysicalInput
//	Description: Meant to simulate a feedback based off an input with an additional option to simulate a failed feedback signal
//				 Using a physical input to simulate
//
//	Usage: simPbarInFB(in := movePbarInOutput, minDelay := 100, maxDelay := 200);
// 
//	Created by: Ben Hess
//	Created Date: 5-20-2019

SUPER^();

IF inputToSimulate.simulate = TRUE THEN
	inputToSimulate.simValue := Q;
END_IF

FUNCTION_BLOCK FB_SimulatedFeedbackPhysicalInput EXTENDS FB_SimulatedFeedback
VAR_INPUT
	inputToSimulate : REFERENCE TO FB_PhysicalDigitalInput;					
END_VAR
VAR_OUTPUT

END_VAR
VAR

END_VAR

//	Function Block: FB_SimulatedFeedbackPhysicalInput
//	Description: Meant to simulate a feedback based off an input with an additional option to simulate a failed feedback signal
//				 Using a physical input to simulate
//
//	Usage: simPbarInFB(in := movePbarInOutput, minDelay := 100, maxDelay := 200);
// 
//	Created by: Ben Hess
//	Created Date: 5-20-2019

SUPER^();

IF inputToSimulate.simulate = TRUE THEN
	inputToSimulate.simValue := Q;
END_IF