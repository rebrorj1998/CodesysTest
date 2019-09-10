

FUNCTION_BLOCK FB_SendOpcodeCommandAppliedMotionRTU
VAR_INPUT
    Parameter1 : WORD := 0;        //QX Parameter 1
    Parameter2 : WORD := 0;        //QX Parameter 2
    Parameter3 : WORD := 0;        //QX Parameter 3
    Parameter4 : WORD := 0;        //QX Parameter 3
    Parameter5 : WORD := 0;        //QX Parameter 3
    opcode : STEP_SERVO_OPCODES;    //Opcode to perform
END_VAR
VAR_IN_OUT
    opcodeWithArgumentsSettingsBuffer : ARRAY[0..1] OF WORD;
END_VAR

VAR_OUTPUT
    xDone : BOOL;        //Successfully performed action
    triggerOpcodeWrite : BOOL;
END_VAR
VAR
    QXCommandState : OPCODE_MODBUS_COMMAND_STATES;
    sendBuffer : ARRAY [0 .. 5] OF WORD;            //Array of registers to send
    xExecute : BOOL;
    xExecuteONS : R_TRIG();
END_VAR


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
                                                        triggerOpcodeWrite := TRUE;
                                                        QXCommandState := OPCODE_MODBUS_COMMAND_STATES.WaitAfterOpcodeAndParametersSent;
                                                        
                                                        
    OPCODE_MODBUS_COMMAND_STATES.WaitAfterOpcodeAndParametersSent :
                                                        //Wait for confimation
                                                            xDone := TRUE;
                                                            triggerOpcodeWrite := FALSE;
                                                            QXCommandState := OPCODE_MODBUS_COMMAND_STATES.Idle;
                                                
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