(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_WriteToFile
VAR_INPUT
   xFilePath: STRING;
   xText_Write: STRING(5000);
   xAppend_OverWrite: BOOL;
   xAppend_Pos: UDINT;
   xWrite: BOOL;
   xRead: BOOL;
   xLine_No_To_Read: UDINT;   
END_VAR
VAR_OUTPUT
   xText_Read: STRING(5000);
   xDone: BOOL;
END_VAR
VAR
   
// Write Variables
   xWrite_Trig: R_TRIG;
   xStart_Write: BOOL;
   xNew_Line: STRING(5000);
   
// Read Variables
   xRead_Trig: R_TRIG;
   xStart_Read: BOOL;
   xLine_Read: UDINT;
   
   hFile           : SysFile.RTS_IEC_HANDLE := SysFile.HandleConstants.RTS_INVALID_HANDLE;
   udiBytesRead    : LWORD;
   udiBytesCopied   : UDINT;
   udiWrite      : LWORD;
   udiFileSize     : UDINT;
   udiPos         : UDINT;

//(* Error Codes *)
   udiPosError          : SysFile.RTS_IEC_RESULT;
   udiCopyError      : SysFile.RTS_IEC_RESULT;
   udiDeleteError1      : SysFile.RTS_IEC_RESULT;
   udiDeleteError2      : SysFile.RTS_IEC_RESULT;
   udiWriteError1      : SysFile.RTS_IEC_RESULT;
   udiWriteError2      : SysFile.RTS_IEC_RESULT;
   udiWriteError3      : SysFile.RTS_IEC_RESULT;
   udiOpenError1      : SysFile.RTS_IEC_RESULT;
   udiOpenError2      : SysFile.RTS_IEC_RESULT;
   udiOpenError3      : SysFile.RTS_IEC_RESULT;
   udiOpenError4      : SysFile.RTS_IEC_RESULT;

   udiReadError1   : SysFile.RTS_IEC_RESULT;
   udiReadError2   : SysFile.RTS_IEC_RESULT;
   udiReadError3   : SysFile.RTS_IEC_RESULT;
   udiCloseError1   : SysFile.RTS_IEC_RESULT;
   udiCloseError2   : SysFile.RTS_IEC_RESULT;
   udiCloseError3   : SysFile.RTS_IEC_RESULT;
   udiCloseError4   : SysFile.RTS_IEC_RESULT;
   udiSizeError : SysFile.RTS_IEC_RESULT;
   udiDirDeleteError: UDINT; 
   udiCreateError: UDINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
xWrite_Trig();
//xWrite_Trig.PT:= T#500MS;
xWrite_Trig.CLK:= xWrite;
xStart_Write:= xWrite_Trig.Q;

xRead_Trig();
//xRead_Trig.PT:= T#500MS;
xRead_Trig.CLK:= xRead;
xStart_Read:= xRead_Trig.Q;

IF xStart_Write THEN
   xDone:= FALSE;
   IF xAppend_OverWrite THEN 
   hFile:= SysFileOpen(szFile:= xFilePath, am:= ACCESS_MODE.AM_APPEND, pResult:= ADR(udiOpenError1));
   END_IF
   IF xAppend_OverWrite = FALSE THEN
      hFile:= SysFileOpen(szFile:= xFilePath, am:= ACCESS_MODE.AM_WRITE_PLUS, pResult:= ADR(udiOpenError1));
   END_IF
   udiPosError:= SysFileGetPos(hFile:= hFile, pulPos:= ADR(udiPos));
   IF hFile <> SysFile.HandleConstants.RTS_INVALID_HANDLE THEN
      xNew_Line:= concat('$n', xText_Write);
      IF udiPos = 16#0 THEN
         udiWrite:= SysFileWrite(hFile:= hFile, pbyBuffer:= ADR(xText_Write), ulSize:= INT_TO_UDINT(LEN(xText_Write)), pResult:= ADR(udiWriteError1));
      ELSE
         udiWrite:= SysFileWrite(hFile:= hFile, pbyBuffer:= ADR(xNew_Line), ulSize:= INT_TO_UDINT(LEN(xNew_Line)), pResult:= ADR(udiWriteError1));
      END_IF
      udiCloseError1:= SysFileClose(hFile:= hFile);
   END_IF
   xDone:= TRUE;
END_IF

IF xStart_Read THEN
   xDone:= FALSE;
   hFile:= SysFileOpen(szFile:= xFilePath, am:= ACCESS_MODE.AM_READ, pResult:= ADR(udiOpenError1));
   IF hFile <> SysFile.HandleConstants.RTS_INVALID_HANDLE THEN
      udiBytesRead := SysFileRead(hFile:= hFile, pbyBuffer:= ADR(xText_Read), ulSize:=SIZEOF(xText_Read), pResult:=ADR(udiReadError1));
      xText_Read[udiBytesRead]:= 0;
   END_IF
   //xDone:= TRUE;   
END_IF