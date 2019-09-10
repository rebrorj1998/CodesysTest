

FUNCTION_BLOCK FB_SendMoveCommandAppliedMotionRTU
VAR_INPUT
//    distanceHighWord : WORD;
//    distanceLowWord : WORD;        
//    acceleration : INT;        //Acceleration in RPM/sec
//    deceleration : INT;        //Deceleration in RPM/sec
//    velocity : INT;            //Velocity in .25RPM
    opcode : STEP_SERVO_OPCODES;    //Opcode to perform
    
    //Parameters from motor - we need to check these to verify successful send
    distanceHighWordFromMotor : REFERENCE TO WORD;    //DistanceHighWord From Motor
    distanceLowWordFromMotor : REFERENCE TO WORD;        //DistanceLowWord from Motor
    accelerationFromMotor : REFERENCE TO INT;        //Acceleration in RPM/sec from Motor
    decelerationFromMotor : REFERENCE TO INT;        //Deceleration in RPM/sec from Motor
    velocityFromMotor : REFERENCE TO INT;            //Velocity in .25RPM from Motor
    //opcodeFromMotor : REFERENCE TO INT;                //Opcode from motor
END_VAR
VAR_IN_OUT
    parameterSettingsBuffer : ARRAY [0..4] OF WORD;
END_VAR

VAR_OUTPUT
    triggerParameterWrite : BOOL;
    triggerOpcodeWrite : BOOL;
    xDone : BOOL;
END_VAR
VAR
    moveCommandState : MOVE_MODBUS_COMMAND_STATES;
    modbusRequestTCP: IoDrvModbusTCP.ModbusRequest;
    modbusCommandTCP : IoDrvModbusTCP.ModbusCommand;
    sendBuffer : ARRAY [0 .. 4] OF WORD;            //Array of registers to send
    xExecute : BOOL;
    xExecuteONS : R_TRIG();
END_VAR

xExecuteONS(CLK := xExecute);
IF xExecuteONS.Q THEN
    xDone := FALSE;
END_IF    

CASE moveCommandState OF
    MOVE_MODBUS_COMMAND_STATES.Idle :                    //Move on to Send Parameters
                                                        IF xExecute THEN
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.SendParameters;
                                                        END_IF
                                                        xExecute := FALSE;
                                
    MOVE_MODBUS_COMMAND_STATES.SendParameters :            //We have to use triggers instead of taking over the handle to the COM port
                                                        IF CheckIfParSendSuccessful() THEN
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.SendOpcode;
                                                        ELSE    
                                                            triggerParameterWrite := TRUE;
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.WaitAfterParametersSent;                                            
                                                        END_IF
                                                        
    MOVE_MODBUS_COMMAND_STATES.WaitAfterParametersSent :
                                                        //Wait for confimation
                                                        IF CheckIfParSendSuccessful() THEN
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.SendOpcode;                                                    
                                                        END_IF
    MOVE_MODBUS_COMMAND_STATES.SendOpcode :                
                                                        //Send just Opcode now
                                                        triggerOpcodeWrite := TRUE;
                                                        moveCommandState := MOVE_MODBUS_COMMAND_STATES.WaitAfterOpcodeSent;
                                                        
    MOVE_MODBUS_COMMAND_STATES.WaitAfterOpcodeSent :    //
                                                        xDone := TRUE;
                                                        triggerParameterWrite := FALSE;
                                                        triggerOpcodeWrite := FALSE;
                                                        moveCommandState := MOVE_MODBUS_COMMAND_STATES.Idle;    
                                        
    MOVE_MODBUS_COMMAND_STATES.Fault :                    
                                                        //Move on to Send Parameters
                                                        IF xExecute THEN
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.SendParameters;
                                                        END_IF
                                                        xExecute := FALSE;
END_CASE






METHOD Execute
VAR_INPUT
END_VAR

xExecute := TRUE;

METHOD CheckIfParSendSuccessful : BOOL
VAR_INPUT
END_VAR


//Check to make sure we have a valid reference.  Disable complier warning since we're doing the check
{warning disable C0371}
IF NOT __ISVALIDREF(parameterSettingsBuffer) THEN
     RETURN;
END_IF

//Check if parameters from drive match the ones we sent

CheckIfParSendSuccessful := (parameterSettingsBuffer[0] = INT_TO_WORD(accelerationFromMotor) AND parameterSettingsBuffer[1] = INT_TO_WORD(decelerationFromMotor) AND parameterSettingsBuffer[2] = INT_TO_WORD(velocityFromMotor) AND parameterSettingsBuffer[3] = distanceHighWordFromMotor AND parameterSettingsBuffer[4] = distanceLowWordFromMotor);
{warning restore C0371}