

FUNCTION_BLOCK FB_SendOpcodeCommandAppliedMotionTCP
VAR_INPUT
    Parameter1 : WORD := 0;        //QX Parameter 1
    Parameter2 : WORD := 0;        //QX Parameter 2
    Parameter3 : WORD := 0;        //QX Parameter 3
    Parameter4 : WORD := 0;        //QX Parameter 3
    Parameter5 : WORD := 0;        //QX Parameter 3
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
    sendBuffer : ARRAY [0 .. 5] OF WORD;            //Array of registers to send
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
                                                        sendBuffer[0] := INT_TO_WORD(opcode);
                                                        sendBuffer[1] := Parameter1;
                                                        sendBuffer[2] := Parameter2;
                                                        sendBuffer[3] := Parameter3;
                                                        sendBuffer[4] := Parameter4;
                                                        sendBuffer[5] := Parameter5;
                                                        
                                                        //    Declare command options : Write to multiple registers (Function 16), length of 6, offset of 124 (MB Register 400125)
                                                        modbusCommandTCP.FunctionCode := IoDrvModbusBase.MBFunctionCode.WriteMultipleRegisters;
                                                        modbusCommandTCP.uiWriteLen := 6;
                                                        modbusCommandTCP.uiWriteOffset := 124;
                                                        
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