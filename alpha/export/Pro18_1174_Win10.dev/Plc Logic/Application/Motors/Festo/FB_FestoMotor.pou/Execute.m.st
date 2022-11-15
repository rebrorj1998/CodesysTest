(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)


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