(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollectionHandlerOEEQualityFaults
VAR_INPUT
END_VAR
VAR_OUTPUT
	totalObj : INT;
	faultExempt : BOOL;
	collection : ARRAY[0..GlobalObjects.MAX_FAULTS] OF IFault;
END_VAR
VAR
	_objNames : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_CollectionHandlerPassiveFaults
//  FB/Object Handling/FB_CollectionHandlerOEEExemptFaults
//
//  Created by Ben Hess on 05/31/2022.
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//