(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_FaultManager
VAR_INPUT
	tamped : BOOL;
	sealed : BOOL;
	onTrunk : BOOL;
	ackAll : REFERENCE TO BOOL;
	collectionOfActiveFaults : REFERENCE TO FB_CollectionHandlerActiveFaults;
	collectionOfPassiveFaults : REFERENCE TO FB_CollectionHandlerPassiveFaults;
END_VAR
VAR_OUTPUT
	faultActive : BOOL;
	passiveFaultActive : BOOL;
	passiveExitConveyorOverride : BOOL;
	passiveExternalExitConveyorOverride : BOOL;
	passiveExemptFaultActive : BOOL;
	OEEExemptFaultActive : BOOL;
END_VAR
VAR
	_i, _j : INT;
	_castedFault : IFault;
	//_passiveExemptList : ARRAY [1..PASSIVE_EXEMPT_LIST_LENGTH] OF STRING := ['Pressure Bar Obstruction Detected', 'Barcode Verification Failed','Opened Bag was Removed'];
END_VAR
VAR CONSTANT
	PASSIVE_EXEMPT_LIST_LENGTH : INT := 3;

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_FactoryTest
//  FB/Fault/FB_FaultManager
//
//  Created by Evan Ische on 11/30/2021.
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

// No pointers, No good
IF NOT __ISVALIDREF(collectionOfActiveFaults) OR
   NOT __ISVALIDREF(collectionOfPassiveFaults) THEN
   RETURN;
END_IF

// Loop through passive faults checking for 'Action' completion
passiveExitConveyorOverride := FALSE;
passiveExternalExitConveyorOverride := FALSE;
FOR _i := 0 TO collectionOfPassiveFaults.totalObj DO
	IF __QUERYINTERFACE(collectionOfPassiveFaults.collection[_i], _castedFault) THEN
		
		// Check if active passive fault should halt the exit conveyor
		IF _castedFault.PassiveExitConeyorOverride THEN
			passiveExitConveyorOverride := TRUE;
		END_IF
		
		// Check if active passive fault should halt the external exit conveyor 
		IF _castedFault.PassiveExternalExitConveyorOverride THEN
			passiveExternalExitConveyorOverride := TRUE;
		END_IF
		
		//
		CASE _castedFault.PassiveTrigger OF
			// Once Package has been tamped
			PASSIVE_FAULT_TRIGGERS.AfterTamp:
				IF tamped THEN
					_castedFault.Trigger();
				END_IF
			// Once current bag is sealed
			PASSIVE_FAULT_TRIGGERS.AfterSeal:
				IF sealed THEN
					_castedFault.Trigger();
				END_IF
				
			PASSIVE_FAULT_TRIGGERS.onTrunk:
				IF onTrunk THEN
					_castedFault.Trigger();
				END_IF
				
		END_CASE
	END_IF
END_FOR

// Ack Active & Passive Faults on reset
IF ackAll THEN
	ackAll := FALSE;
	collectionOfActiveFaults.AckAll();
	collectionOfPassiveFaults.AckAll();
END_IF

// Looks for faults matching faults in the exempt list
IF collectionOfActiveFaults.totalObj > 0 THEN
 
	IF collectionOfActiveFaults.totalObj = collectionOfPassiveFaults.totalObj THEN
		passiveExemptFaultActive := TRUE;
	ELSE
		passiveExemptFaultActive := FALSE;
	END_IF
END_IF

// Pass To Output
faultActive := collectionOfActiveFaults.faultActive;
passiveFaultActive := collectionOfPassiveFaults.faultPassive; 
