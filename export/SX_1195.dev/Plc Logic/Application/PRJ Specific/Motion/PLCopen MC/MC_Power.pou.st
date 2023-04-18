(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_Power
VAR_INPUT
	enable : BOOL; 			// Enables the FUNCTION block 
END_VAR
VAR_OUTPUT
	status : BOOL; 				// Axis ready for motion 
	busy : BOOL; 				// Function block is executing 
	error : BOOL; 				// Signals that an error has occured 
	errorID : eMCError; 		// Error number 
END_VAR
VAR_IN_OUT
	axis : Axis_REF;		// Reference to the axis 
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  MC_Power
//  Application/Motion Control/PLCOpen MC/MC_Power
//
//  Created by Evan Ische on 6/29/2022.
//  Copyright (C) 2022 Sharp Packaging Systems By Pregis. All rights reserved.
//

//
axis.driveEnable := enable;