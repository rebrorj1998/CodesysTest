

FUNCTION_BLOCK SerialMotorTestFB
VAR_INPUT
    runMotorPB : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
    //testMotor : FB_AppliedMotionStepServoRTU();    
    //orientalMotor : FB_OrientalAZDrive();
END_VAR

(*
orientalMotor(modbusInBuffer := OrientalMotorModbusRead,
                stepsPerInchSetpoint := 2122,
                reversePolarity := FALSE,
                operatingCurrentDefault := 100,
                modbusCommandOutBuffer := OrientalMotorCommandWrites,
                modbusParametersOutBuffer := OrientalMotorParameterWrites,
                triggerCommandWrite => OrientalMotorTriggerCommandWrite,
                triggerParameterWrite => OrientalMotorTriggerParameterWrite);                
orientalMotor.Execute();
*)


IF runMotorPB THEN
    //testMotor.MoveDistance(12,100,100,215);
    //testMotor.HomeNow();
    
    //orientalMotor.MoveDistance(12,10000,10000,10000);
    runMotorPB := FALSE;
END_IF



