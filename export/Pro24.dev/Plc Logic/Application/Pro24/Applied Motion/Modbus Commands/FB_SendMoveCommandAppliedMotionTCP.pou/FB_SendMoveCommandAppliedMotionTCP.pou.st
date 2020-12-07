(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SendMoveCommandAppliedMotionTCP
VAR_INPUT
    distanceHighWord : WORD;
    distanceLowWord : WORD;        
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
    opcode : STEP_SERVO_OPCODES;    //Opcode to perform
END_VAR
VAR_IN_OUT
    Slave :  IoDrvModbusTCP.ModbusTCPSlave;
END_VAR

VAR_OUTPUT
    xDone : BOOL;        //Successfully performed action
END_VAR
VAR
    moveCommandState : MOVE_MODBUS_COMMAND_STATES;
    modbusRequestTCP: IoDrvModbusTCP.ModbusRequest;
    modbusCommandTCP : IoDrvModbusTCP.ModbusCommand;
    sendBuffer : ARRAY [0 .. 4] OF WORD;            //Array of registers to send
    xExecute : BOOL;
    xExecuteONS : R_TRIG();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
modbusRequestTCP(
                                slave:= Slave , 
                                xExecute:= , 
                                xAbort:= , 
                                usiUnitID:= , 
                                ModbusCommand:= modbusCommandTCP, 
                                pSendData:= ADR(sendBuffer), 
                                pRecvData:= , 
                                xBusy=> , 
                                xDone=> , 
                                xError=> , 
                                xAborted=> , 
                                ModbusError=> );

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
                                
    MOVE_MODBUS_COMMAND_STATES.SendParameters :            
                                                        //Setup parameter registers to send to drive
                                                        sendBuffer[0] := INT_TO_WORD(acceleration);
                                                        sendBuffer[1] := INT_TO_WORD(deceleration);
                                                        sendBuffer[2] := INT_TO_WORD(velocity);
                                                        sendBuffer[3] := distanceHighWord;
                                                        sendBuffer[4] := distanceLowWord;
                                                        
                                                        //    Declare command options : Write to multiple registers (Function 16), length of 5, offset of 27 (MB Register 40028)
                                                        modbusCommandTCP.FunctionCode := IoDrvModbusBase.MBFunctionCode.WriteMultipleRegisters;
                                                        modbusCommandTCP.uiWriteLen := 5;
                                                        modbusCommandTCP.uiWriteOffset := 27;
                                                        
                                                        modbusRequestTCP.xExecute := TRUE;
                                                        moveCommandState := MOVE_MODBUS_COMMAND_STATES.WaitAfterParametersSent;
                                                        
                                                        
    MOVE_MODBUS_COMMAND_STATES.WaitAfterParametersSent :
                                                        //Wait for confimation
                                                        IF modbusRequestTCP.xDone = TRUE THEN
                                                            modbusRequestTCP.xExecute := FALSE;
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.SendOpcode;
                                                        ELSIF modbusRequestTCP.xError THEN
                                                            modbusRequestTCP.xExecute := FALSE;
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.Fault;
                                                        END_IF
    MOVE_MODBUS_COMMAND_STATES.SendOpcode :                
                                                        //Send just Opcode now
                                                        sendBuffer[0] := INT_TO_WORD(opcode);
                                                        
                                                        modbusCommandTCP.FunctionCode := IoDrvModbusBase.MBFunctionCode.WriteSingleRegister;
                                                        modbusCommandTCP.uiWriteLen := 1;
                                                        modbusCommandTCP.uiWriteOffset := 124;
                                                        
                                                        modbusRequestTCP.xExecute := TRUE;
                                                        moveCommandState := MOVE_MODBUS_COMMAND_STATES.WaitAfterOpcodeSent;
                                                        
    MOVE_MODBUS_COMMAND_STATES.WaitAfterOpcodeSent :    //Wait for confimation
                                                        IF modbusRequestTCP.xDone = TRUE THEN
                                                            modbusRequestTCP.xExecute := FALSE;
                                                            xDone := TRUE;
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.Idle;
                                                        ELSIF modbusRequestTCP.xError THEN
                                                            modbusRequestTCP.xExecute := FALSE;
                                                            xDone := TRUE;
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.Fault;
                                                        END_IF
    MOVE_MODBUS_COMMAND_STATES.Fault :                    
                                                        //Move on to Send Parameters
                                                        IF xExecute THEN
                                                            moveCommandState := MOVE_MODBUS_COMMAND_STATES.SendParameters;
                                                        END_IF
                                                        xExecute := FALSE;
END_CASE




