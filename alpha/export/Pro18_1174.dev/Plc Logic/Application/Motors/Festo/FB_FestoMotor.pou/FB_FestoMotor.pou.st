(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_FestoMotor IMPLEMENTS IPositionableMotor, IStoredProgramMotor
VAR_INPUT
    deviceType : FML.E_FML_DEVICE_TYPE;                            //Must define drive type
    isFPCActive : BOOL;    
    ptrReadFHPPRegister : POINTER TO WORD;
    ptrReadFPCRegister : POINTER TO WORD;
    ptrWriteFHPPRegister : POINTER TO WORD;
    ptrWriteFPCRegister : POINTER TO WORD;                                        //Toggle if FPC(Festo Parameter Chanel) is active or not
END_VAR
VAR_IN_OUT
    //modbusReadRegisters :  ARRAY[0..7] OF WORD;        //Inputs from drive
    //modbusWriteRegisters : ARRAY[0..7] OF WORD;    //Outputs to write to drive

END_VAR
VAR_OUTPUT
END_VAR
VAR
    //Required datatypes for the Festo motor blocks
    FHPP_IN     :ARRAY[0..7] OF BYTE;
    FHPP_OUT     :ARRAY[0..7] OF BYTE;
    FPC_IN         :ARRAY[0..7] OF BYTE;
    FPC_OUT     :ARRAY[0..7] OF BYTE;
    ReadAxis            :FML.FML_Read;
    DATA_REF_Axis         :FML.DT_FML_REF;
    CRTL_Axis            :FML.FHPP_CTRL;
    PNU_Axis            :FML.FPC_PNU;
    MULTI_Axis            :FML.FPC_MULTI;    
    DIRMP_Axis            :FML.FPC_DIRMP;
    DIAG_Axis            :FML.FPC_DIAG;
    DIAG_BUFF_Axis        :FML.FPC_DIAG_BUFFER;
    DATA_OBJECT_Axis    :FML.FPC_DATA_OBJECT;
    FILE_Axis            :FML.FPC_FILE;
    FILE_ARRAY_Axis        :FML.FPC_FILE_ARRAY;
    WriteAxis            :FML.FML_Write;

    //Regular variables
    ptrModbusMemory : POINTER TO ARRAY[0..7] OF BYTE; 
    commandSuccessful : BOOL;    //Modbus Command was successful
    homeRequiredIndication : BOOL; //Home required indication
    homingActive : BOOL;            //Homing active
    removeStartCommandTimer : Standard.TON := (PT := T#100MS);
    startAckONS : Standard.R_TRIG;
    _sendStart : BOOL;
END_VAR
VAR_STAT    
    //Make these static to share amongst all instances of the Festo motors
    ARY_DATA_FILE        :ARRAY[0..25000] OF BYTE;
    MultiParam             :ARRAY [0..7] OF DT_FML_PRM_DESCRIPTION :=[
                                            (PNU:=404, SUBINDEX:=1, ACCESS:=0, VALUE:=0, LENGTH:=0),
                                            (PNU:=404, SUBINDEX:=1, ACCESS:=1, VALUE:=100, LENGTH:=4),
                                            (PNU:=404, SUBINDEX:=1, ACCESS:=0, VALUE:=0, LENGTH:=0),
                                            (PNU:=404, SUBINDEX:=2, ACCESS:=0, VALUE:=0, LENGTH:=0),
                                            (PNU:=404, SUBINDEX:=2, ACCESS:=1, VALUE:=200, LENGTH:=4),
                                            (PNU:=404, SUBINDEX:=2, ACCESS:=0, VALUE:=0, LENGTH:=0),
                                            (PNU:=404, SUBINDEX:=1, ACCESS:=1, VALUE:=111, LENGTH:=4),
                                            (PNU:=404, SUBINDEX:=1, ACCESS:=0, VALUE:=0, LENGTH:=0)];
                                            
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
