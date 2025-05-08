(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollectionHandlerPassiveFaults
VAR_INPUT
END_VAR
VAR_OUTPUT
	totalObj : INT;
	faultPassive : BOOL;
	collection : ARRAY[0..GlobalObjects.MAX_FAULTS] OF IFault;
END_VAR
VAR
	_objNames : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_CollectionHandlerPassiveFaults
//  FB/Object Handling/FB_CollectionHandlerPassiveFaults
//
//  Created by Evan Ische on 12/01/2021.
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//