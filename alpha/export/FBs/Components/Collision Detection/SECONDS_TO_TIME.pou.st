(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION SECONDS_TO_TIME : TIME
VAR_INPUT
	secs : REAL;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  SECONDS_TO_TIME
//  FBs/Components/Collisiton Detection/SECONDS_TO_TIME
//
//  Created by Evan Ische on 8/10/2021. 
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

SECONDS_TO_TIME := TO_TIME(secs * 1000);