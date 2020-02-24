(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SolenoidValveManifold EXTENDS FB_BaseObject
VAR_INPUT
	ptrEIPOutputs : POINTER TO DWORD;	// Pointer to starting word of EIP Outputs for the I/O Image

	station : ARRAY[1..16] OF ISolenoidValve;	// Array of up to 16 valve stations on manifold 
	
END_VAR
VAR_OUTPUT
END_VAR
VAR
	i : INT;
	j : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_SolenoidValveManifold
//	Description: Sets the output image of the valve manifold (ptrEIPOutputs) to the correct values depending on configuration.  
//
//	Usage: All stations should be configured with a valve before running.
// 
//	Created by: Ben Hess
//	Created Date: 6-27-2019


// Loop through all possible stations
FOR i := 1 TO 16 DO
	IF station[i] <> 0 THEN	// Check for valid reference passed into the station interface
		// If ref good then set I/O image bit for proper station.  If simulated then don't set real output for solenoid
		ptrEIPOutputs^ := OSCAT_BASIC.BIT_LOAD_DW(in := ptrEIPOutputs^, POS := j, VAL := station[i].Solenoid0Asserted AND NOT station[i].Simulate);
		ptrEIPOutputs^ := OSCAT_BASIC.BIT_LOAD_DW(in := ptrEIPOutputs^, POS := j+1, VAL := station[i].Solenoid1Asserted AND NOT station[i].Simulate);
	END_IF
	j := j + 2;
END_FOR
// Restart bit loop
j := 0;