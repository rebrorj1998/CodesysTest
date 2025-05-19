(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//This is the support class for File_Handler
{attribute 'reflection'}
FUNCTION_BLOCK FB_fileWrite
VAR_INPUT
	exec:BOOL;
	appendCR: BOOL:= FALSE;
	filename: FILE.CAA.FILENAME:= 'writeFile.txt';
	writestr: STRING(5000):= 'this is a test of the emergency broadcast station.';
	strLength: DINT:=SIZEOF(writestr);
	cr: STRING(2) := '$R$N';
END_VAR
VAR_OUTPUT
	busy: BOOL;
	writeSuccess: BOOL;
	execTime: TIME;
	fileWriteTimeout: BOOL;
END_VAR
VAR
	startONS: FB_ONS;
	xBegin: BOOL;
	wdTime: TON;
	
	fOpen:FILE.Open;
	fWrite: FILE.Write;
	fClose: FILE.Close;
	fGStatus: SYS_FILE_STATUS;//FILE.SysFileGetStatus;
	filetext: STRING(5002);
	retryfopen: BOOL;
END_VAR
VAR
{attribute 'instance-path'}
{attribute 'noinit'}
 str: STRING;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
startONS(CLK:=exec);
wdTime(PT:=T#10S);
wdTime.IN:= xBegin;
IF startONS.OSR THEN
	xBegin:=TRUE;
END_IF
IF appendCR THEN
	filetext:= CONCAT(writestr,cr);
ELSE
	filetext:= writestr;
END_IF
//pro 24
//fOpen(xExecute:=xBegin,sFileName:= filename,eFileMode:=FILE.MODE.MAPPENDPLUS);
//pro18
IF 	retryfopen THEN
	fOpen(xExecute:=xBegin,sFileName:= filename,eFileMode:=FILE.MODE.MWRITE);
	retryfopen := FALSE;
ELSE
	fOpen(xExecute:=xBegin,sFileName:= filename,eFileMode:=FILE.MODE.MAPPD);	
END_IF
IF NOT fOpen.xError THEN
	fGStatus := SysFileGetStatus(hFile:=fOpen.hFile); 
	IF fGStatus = SYS_FILE_STATUS.FS_NO_FILE THEN
		retryfopen := TRUE;
	END_IF
		
END_IF

IF NOT fOpen.xError AND fGStatus = SYS_FILE_STATUS.FS_OK THEN
	fWrite(xExecute:=fOpen.xDone,hFile:=fOpen.hFile,pBuffer:=ADR(filetext),szSize:= strLength);
	busy:= fwrite.xBusy;
	retryfopen := FALSE;
	FClose(xExecute:= fWrite.xDone,hFile:=fWrite.hFile);
IF xBegin THEN
	xBegin := exec;
	execTime:= wdTime.ET;
	writeSuccess:=FALSE;
	IF fClose.xDone THEN
		writeSuccess:=TRUE;
		xBegin := FALSE;
		retryfopen := FALSE;
	END_IF
END_IF
END_IF
fileWriteTimeout := wdTime.Q OR retryfOpen;

