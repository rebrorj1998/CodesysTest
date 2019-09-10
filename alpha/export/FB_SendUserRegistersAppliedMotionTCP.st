

FUNCTION_BLOCK FB_SendUserRegistersAppliedMotionTCP
VAR_INPUT
    Parameter1HW : WORD := 0;        //User Parameter 1 HW
    Parameter1LW : WORD := 0;        //User Parameter 1 LW
    Parameter2HW : WORD := 0;        //User Parameter 2 HW
    Parameter2LW : WORD := 0;        //User Parameter 2 LW
    Parameter3HW : WORD := 0;        //User Parameter 3 HW
    Parameter3LW : WORD := 0;        //User Parameter 3 LW
    Parameter4HW : WORD := 0;        //User Parameter 4 HW
    Parameter4LW : WORD := 0;        //User Parameter 4 LW
    opcode : STEP_SERVO_OPCODES;    //Opcode to perform
END_VAR
VAR_IN_OUT
    Slave :  IoDrvModbusTCP.ModbusTCPSlave;
END_VAR

VAR_OUTPUT
    xDone : BOOL;        //Successfully performed action
END_VAR
VAR
    QXCommandState : OPCODE_MODBUS_COMMAND_STATES;
    modbusRequestTCP: IoDrvModbusTCP.ModbusRequest;
    modbusCommandTCP : IoDrvModbusTCP.ModbusCommand;
    sendBuffer : ARRAY [0 .. 7] OF WORD;            //Array of registers to send
    xExecute : BOOL;
    xExecuteONS : R_TRIG();
END_VAR

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
                                
CASE QXCommandState OF
    OPCODE_MODBUS_COMMAND_STATES.Idle :                    //Move on to Send Parameters
                                                        IF xExecute THEN
                                                            QXCommandState := OPCODE_MODBUS_COMMAND_STATES.SendOpcodeAndParameters;
                                                        END_IF
                                                        xExecute := FALSE;
                                
    OPCODE_MODBUS_COMMAND_STATES.SendOpcodeAndParameters :            
                                                        //Setup parameter registers to send to drive
                                                        sendBuffer[0] := Parameter1HW;
                                                        sendBuffer[1] := Parameter1LW;
                                                        sendBuffer[2] := Parameter2HW;
                                                        sendBuffer[3] := Parameter2LW;
                                                        sendBuffer[4] := Parameter3HW;
                                                        sendBuffer[5] := Parameter3LW;
                                                        sendBuffer[6] := Parameter4HW;
                                                        sendBuffer[7] := Parameter4LW;
                                                        
                                                        //    Declare command options : Write to multiple registers (Function 16), length of 6, offset of 124 (MB Register 400125)
                                                        modbusCommandTCP.FunctionCode := IoDrvModbusBase.MBFunctionCode.WriteMultipleRegisters;
                                                        modbusCommandTCP.uiWriteLen := 8;
                                                        modbusCommandTCP.uiWriteOffset := 60;
                                                        
                                                        modbusRequestTCP.xExecute := TRUE;
                                                        QXCommandState := OPCODE_MODBUS_COMMAND_STATES.WaitAfterOpcodeAndParametersSent;
                                                        
                                                        
    OPCODE_MODBUS_COMMAND_STATES.WaitAfterOpcodeAndParametersSent :
                                                        //Wait for confimation
                                                        IF modbusRequestTCP.xDone = TRUE THEN
                                                            modbusRequestTCP.xExecute := FALSE;
                                                            xDone := TRUE;
                                                            QXCommandState := OPCODE_MODBUS_COMMAND_STATES.Idle;
                                                        ELSIF modbusRequestTCP.xError THEN
                                                            modbusRequestTCP.xExecute := FALSE;
                                                            xDone := TRUE;
                                                            QXCommandState := OPCODE_MODBUS_COMMAND_STATES.Fault;
                                                        END_IF
    
    OPCODE_MODBUS_COMMAND_STATES.Fault :                    
                                                        //Move on to Send Parameters
                                                        IF xExecute THEN
                                                            QXCommandState := OPCODE_MODBUS_COMMAND_STATES.SendOpcodeAndParameters;
                                                        END_IF
                                                        xExecute := FALSE;
END_CASE






METHOD Execute
VAR_INPUT
END_VAR

xExecute := TRUE;