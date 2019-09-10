

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



METHOD ExecuteStoredProgram
VAR_INPUT
    (*Program number to execute*)
    programNumber    : INT;
END_VAR

InitDrive();
IF InPosition AND CRTL_Axis.ActualRecordNo = programNumber THEN
    commandSuccessful := TRUE;
ELSE
    CRTL_Axis.RecordNo := programNumber;
    _sendStart := TRUE;
END_IF

{attribute 'monitoring' := 'variable'}
PROPERTY CommandAcknowledged : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY CurrentPosition : REAL


PROPERTY Homing : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY InPosition : BOOL


PROPERTY HomeRequired : BOOL


METHOD Execute
VAR_INPUT
END_VAR



//Check to make sure we have a valid reference.  Disable complier warning since we're doing the check
//{warning disable C0371}
(*
IF NOT __ISVALIDREF(ptrReadFHPPRegister) 
    OR NOT __ISVALIDREF(ptrReadFPCRegister) 
    OR NOT __ISVALIDREF(ptrWriteFHPPRegister)
    OR NOT __ISVALIDREF(ptrWriteFPCRegister)
THEN
     RETURN;
END_IF
*)



//Convert array of bytes to array of words. Playin' with pointers!
ptrModbusMemory := ptrReadFHPPRegister;
FHPP_IN := ptrModbusMemory^; 
ptrModbusMemory := ptrReadFPCRegister;
FPC_IN := ptrModbusMemory^;
ptrModbusMemory := ptrWriteFHPPRegister;
ptrModbusMemory^ := FHPP_OUT; 
ptrModbusMemory := ptrWriteFPCRegister;
ptrModbusMemory^ := FPC_OUT;

// Function block calls for axis
ReadAxis(
    FML_REF            := DATA_REF_Axis,
    Modbus            := FALSE,
    HighByteFirst    := TRUE,
    DeviceType        := deviceType,
    FPC_active        := isFPCActive,
    
    FHPP_Source        := FHPP_IN,
    FPC_Source        := FPC_IN);    
CRTL_Axis(
    FML_REF            := DATA_REF_Axis);    
PNU_Axis(
    FML_REF            := DATA_REF_Axis);
MULTI_Axis(
    FML_REF            := DATA_REF_Axis,
    SizeOfParam        := SIZEOF(MultiParam),
    AdrOfParam        := ADR(MultiParam));
DIRMP_Axis(
    FML_REF            := DATA_REF_Axis);    
DIAG_Axis(
    FML_REF            := DATA_REF_Axis);
DIAG_BUFF_Axis(
    FML_REF            := DATA_REF_Axis);
DATA_OBJECT_Axis(
    FML_REF            := DATA_REF_Axis);
FILE_Axis(
    FML_REF            := DATA_REF_Axis);
FILE_ARRAY_Axis(
    FML_REF            := DATA_REF_Axis,
    SizeOfFileArray    := SIZEOF(ARY_DATA_FILE),
    AdrOfFileArray    := ADR(ARY_DATA_FILE));    
WriteAxis(
    FML_REF            := DATA_REF_Axis,
    FHPP_Target        => FHPP_OUT,
    FPC_Target        => FPC_OUT);
{warning 'TODO: Remove this hack to clear start command if error occurs'}
removeStartCommandTimer(IN := CRTL_Axis.StartTask OR CRTL_Axis.AckStart);
//removeStartCommandTimer(IN := CRTL_Axis.AckStart);
startAckONS(CLK := CRTL_Axis.AckStart);    
//IF removeStartCommandTimer.Q THEN
IF _sendStart AND NOT CRTL_Axis.AckStart THEN
    CRTL_Axis.StartTask := TRUE;
    _sendStart := FALSE;
END_IF

IF startAckONS.Q OR removeStartCommandTimer.Q THEN
    CRTL_Axis.StartTask := FALSE;
    commandSuccessful := TRUE;
END_IF
//Set Home required indication
homeRequiredIndication S= NOT CRTL_Axis.HomingValid;
//commandSuccessful S= CRTL_Axis.AckStart;
//{warning restore C0371}

{attribute 'monitoring' := 'variable'}
PROPERTY ActiveStoredProgramNumber : INT


METHOD Stop

commandSuccessful := FALSE;
CRTL_Axis.EnableDrive := TRUE;
CRTL_Axis.Halt := TRUE;
CRTL_Axis.Stop := FALSE;    


METHOD PRIVATE InitDrive
VAR_INPUT
END_VAR

//Initialize the drive to prepare for a move
CRTL_Axis.EnableDrive := TRUE;
CRTL_Axis.Halt := TRUE;
CRTL_Axis.Stop := TRUE;    
//CRTL_Axis.StartTask := FALSE;
commandSuccessful := FALSE;


PROPERTY Moving : BOOL


{warning 'add method implementation '}
METHOD MoveDistance
VAR_INPUT
    (*Distance to move in inches*)
    distance    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
END_VAR



{warning 'add method implementation '}
METHOD MoveToPosition
VAR_INPUT
    (*Position to move to in inches*)
    position    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
END_VAR



METHOD HomeNow

CRTL_Axis.StartHoming := TRUE;