(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_OEE IMPLEMENTS ILoggable 
VAR_INPUT
	baggerInCycle : BOOL;
	clearNow : BOOL;
	blocked : BOOL;
	cumulativeBagsMade : DINT;
	collectionOfActiveFaults : REFERENCE TO FB_CollectionHandlerActiveFaults;
	collectionOfOEEExemptFaults : REFERENCE TO FB_CollectionHandlerOEEExemptFaults;
END_VAR
VAR_OUTPUT
	state : OEE_STATES;
	availablePercent : REAL;
	availableTimeInSeconds : DINT;
	availableTimeInHours : REAL;
	qualityPercent : REAL;
	faultedPercent : REAL;
	faultedTimeInSeconds : DINT;
	faultedTimeInHours : REAL;
	idlePercent : REAL;
	idleTimeInSeconds : DINT;
	idleTimeInHours : REAL;
	runningPercent : REAL;
	runningTimeInSeconds : DINT;
	runningTimeInHours : REAL;
	bagsMade : DINT;
	qualityFaults : DINT;
	throughputPercent : REAL;
	blockedPercent : REAL;
	blockedTimeInSeconds : DINT;
	blockedTimeInHours : REAL;
	OEE : REAL;
END_VAR
VAR
	_instanceName : STRING;
	_timeToWaitAfterCycleForIdleState : TON := (PT := T#2M);
	_inCycleONS : FB_ONS;
	_clearNowONS : FB_ONS;
	_runningTimer : TON := (PT := T#1D1S);
	_runTimeLast : TIME;
	_faultedTimer : TON := (PT := T#5m);
	_faultTimeLast : TIME;
	_blockedTimer : TON := (PT := T#1D1S);
	_blockedTimeLast : TIME;
	_exemptFaultsOnlyActive : BOOL;
	_realFaultActive : BOOL;
	_logger : IMachineLogger;
	_bagsMadeLast : DINT;
	_testQualityCounter:BOOL;
	_testClearNow : BOOL;
	_runningTimeInMinutes : REAL;
	_10MinTimer : TON := (PT := T#10M);
	_testLog : BOOL;
	_testGetFaults : BOOL;
	//_logString : STRING(5000);
	_faultsActiveCount : DINT;
	_faultsActiveCountLast : DINT;
	_logDetailedNow : BOOL;
	_logDailyNow : BOOL;
	_clearDailyNow : BOOL;
	_currentTimeStructured : OSCAT_BASIC.SDT;
	_localTime : DATE_AND_TIME;
	_readableTime : STRING;
	_qualityFaultsONS : FB_ONS();
END_VAR

VAR CONSTANT
	SECONDS_IN_DAY : DINT := 86400;
	SECONDS_IN_HOUR : DINT := 3600;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_OEE
//    Description: Calculates OEE 
//    
//    Created by: Ben Hess
//    Created Date: 05/31/2022

// Clear/Reset OEE every 24 hours
_clearDailyNow := (_currentTimeStructured.HOUR = 23 AND _currentTimeStructured.MINUTE = 59) OR _testClearNow;
//Log every 10 mins.
_10MinTimer(IN := NOT _10MinTimer.Q);

// Logger triggers
IF _testGetFaults OR collectionOfActiveFaults.totalObj <> _faultsActiveCountLast OR _clearDailyNow OR _10MinTimer.Q THEN
	_testGetFaults := FALSE;
	_faultsActiveCountLast := collectionOfActiveFaults.totalObj;
	_logDetailedNow := TRUE;
	Globals.fileLoggerOEEDetailed.xText_Write := THIS^.GetDetailedLogString();
	Globals.fileLoggerOEEDaily.xText_Write := THIS^.GetDailyLogString();
END_IF

// Time handling
_localTime := OSCAT_BASIC.UTC_TO_LTIME(Globals.SystemLog.RTC.currentDateAndTime,TRUE,-300);
_currentTimeStructured := OSCAT_BASIC.DT_TO_SDT(_localTime);
_readableTime := DELETE(TO_STRING(_localTime),3,1);

// Logger FBs
Globals.fileLoggerOEEDetailed(
	xFilePath:= 'C:\Users\Public\Documents\SharpPackaging\Logs\OEE-Detailed.csv', 
	//xText_Write:= _logString, 
	xAppend_OverWrite:= TRUE, 
	xAppend_Pos:= , 
	xWrite:= _testLog OR _10MinTimer.Q OR _logDetailedNow, 
	xRead:= , 
	xLine_No_To_Read:= , 
	xText_Read=> , 
	xDone=> );
IF Globals.fileLoggerOEEDetailed.xDone THEN
	_testLog := _logDetailedNow := FALSE;
END_IF

Globals.fileLoggerOEEDaily(
	xFilePath:= 'C:\Users\Public\Documents\SharpPackaging\Logs\OEE-Daily.csv', 
	//xText_Write:= _logString, 
	xAppend_OverWrite:= TRUE, 
	xAppend_Pos:= , 
	xWrite:= _clearDailyNow, 
	xRead:= , 
	xLine_No_To_Read:= , 
	xText_Read=> , 
	xDone=> );
IF Globals.fileLoggerOEEDaily.xDone THEN
	_testLog := _logDailyNow := FALSE;
END_IF

// Capture and count quality faults
_qualityFaultsONS(CLK := _exemptFaultsOnlyActive);
IF _qualityFaultsONS.OSR THEN 
	OEE_Persistent.qualityFaults := OEE_Persistent.qualityFaults + 1;
END_IF
// Reset at same time every day
_clearNowONS(CLK := clearNow OR _clearDailyNow);
// Capture cycle start
_inCycleONS(CLK := baggerInCycle);
// A pause is not a stop of running state. Stay active
_timeToWaitAfterCycleForIdleState(IN := NOT baggerInCycle);

// Log runtime for the day
_runningTimer(IN := (state = OEE_STATES.Running) AND NOT _clearNowONS.OSR);
IF _runningTimer.ET <> _runTimeLast THEN
	IF _runningTimer.ET > T#0MS THEN
		OEE_Persistent.runningTime := OEE_Persistent.runningTime + (_runningTimer.ET - _runTimeLast);
	END_IF
	_runTimeLast := _runningTimer.ET;
END_IF

// Log *truly* faulted time for the day
_faultedTimer(IN := (state = OEE_STATES.Faulted) AND NOT _clearNowONS.OSR);
IF _faultedTimer.ET <> _faultTimeLast THEN
	IF _faultedTimer.ET > T#0MS THEN
		OEE_Persistent.faultedTime := OEE_Persistent.faultedTime + (_faultedTimer.ET - _faultTimeLast);
	END_IF
	_faultTimeLast := _faultedTimer.ET;
END_IF

// Log blocked time for the day (trunk line etc.)
_blockedTimer(IN := blocked AND NOT _clearNowONS.OSR);
IF _blockedTimer.ET <> _blockedTimeLast THEN
	IF _blockedTimer.ET > T#0MS THEN
		OEE_Persistent.blockedTime := OEE_Persistent.blockedTime + (_blockedTimer.ET - _blockedTimeLast);
	END_IF
	_blockedTimeLast := _blockedTimer.ET;
END_IF

// Log bags made
IF cumulativeBagsMade <> _bagsMadeLast THEN
	IF _bagsMadeLast > 0 THEN
		OEE_Persistent.bagsMade := OEE_Persistent.bagsMade + (cumulativeBagsMade - _bagsMadeLast);
	END_IF
	_bagsMadeLast := cumulativeBagsMade;
END_IF

// Flag type of fault currently active
_exemptFaultsOnlyActive := (collectionOfActiveFaults.faultActive AND (collectionOfActiveFaults.totalObj = collectionOfOEEExemptFaults.totalObj));
_realFaultActive := (collectionOfActiveFaults.faultActive AND NOT _exemptFaultsOnlyActive);


// Current machine status state machine
CASE state OF
		OEE_STATES.Idle : 	//
				IF baggerInCycle THEN
					state := OEE_STATES.Running;
				END_IF
				IF _realFaultActive THEN
					state := OEE_STATES.Faulted;
				END_IF
// 				IF _exemptFaultsOnlyActive THEN
// 					state := OEE_STATES.ExemptFault;
// 				END_IF
		OEE_STATES.Faulted : //
				IF NOT collectionOfActiveFaults.faultActive THEN
					state := OEE_STATES.Idle;
				END_IF
		
		OEE_STATES.Running : //
				IF _timeToWaitAfterCycleForIdleState.Q THEN
					state := OEE_STATES.Idle;
				END_IF
				IF _realFaultActive THEN
					state := OEE_STATES.Faulted;
 				END_IF
// 				IF _exemptFaultsOnlyActive THEN
// 					state := OEE_STATES.ExemptFault;
// 				END_IF
		OEE_STATES.ExemptFault :
END_CASE

// Outputs
runningTimeInSeconds := TIME_TO_DINT(OEE_Persistent.runningTime) / 1000;
faultedTimeInSeconds := TIME_TO_DINT(OEE_Persistent.faultedTime) / 1000;
idleTimeInSeconds := SECONDS_IN_DAY - faultedTimeInSeconds - runningTimeInSeconds;
availableTimeInSeconds := SECONDS_IN_DAY - faultedTimeInSeconds;
bagsMade := OEE_Persistent.bagsMade;
qualityFaults := OEE_Persistent.qualityFaults;
blockedTimeInSeconds := TIME_TO_DINT(OEE_Persistent.blockedTime) / 1000;

// Quality % calculation
IF bagsMade <> 0 THEN
	qualityPercent := 1.0 - (TO_REAL(qualityFaults) / TO_REAL(bagsMade));
ELSE
	qualityPercent := 1.0;
END_IF

faultedPercent := (TO_REAL(faultedTimeInSeconds) / TO_REAL(SECONDS_IN_DAY));
idlePercent := (TO_REAL(idleTimeInSeconds) / TO_REAL(SECONDS_IN_DAY));
runningPercent := (TO_REAL(runningTimeInSeconds) / TO_REAL(SECONDS_IN_DAY));
availablePercent := (TO_REAL(availableTimeInSeconds) / TO_REAL(SECONDS_IN_DAY));
blockedPercent := (TO_REAL(blockedTimeInSeconds) / TO_REAL(SECONDS_IN_DAY));

// Get throughput
_runningTimeInMinutes := TO_REAL(runningTimeInSeconds) / 60.0;
IF _runningTimeInMinutes <> 0 THEN
	throughputPercent := TO_REAL(bagsMade) / (OEE_Persistent.expectedPackagePerMinuteRate * _runningTimeInMinutes);
ELSE
	throughputPercent := 1.0;
END_IF

//Calulate OEE
OEE := availablePercent * qualityPercent * throughputPercent;

// Convert seconds to hours for logging
faultedTimeInHours := TO_REAL(faultedTimeInSeconds) / TO_REAL(SECONDS_IN_HOUR);
idleTimeInHours := TO_REAL(idleTimeInSeconds) / TO_REAL(SECONDS_IN_HOUR);
runningTimeInHours := TO_REAL(runningTimeInSeconds) / TO_REAL(SECONDS_IN_HOUR);
availableTimeInHours := TO_REAL(availableTimeInSeconds) / TO_REAL(SECONDS_IN_HOUR);
blockedTimeInHours := TO_REAL(blockedTimeInSeconds) / TO_REAL(SECONDS_IN_HOUR);

// Clear/Reset OEE counters 
IF _clearNowONS.OSR THEN
	OEE_Persistent.runningTime := T#0MS;
	OEE_Persistent.faultedTime := T#0MS;
	OEE_Persistent.blockedTime := T#0MS;
	OEE_Persistent.bagsMade := 0;
	OEE_Persistent.qualityFaults := 0;
	_bagsMadeLast := 0;
END_IF