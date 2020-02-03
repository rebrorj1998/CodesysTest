(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK TimeLeftFB
VAR_INPUT
    targetDate : DATE_AND_TIME;
END_VAR
VAR_OUTPUT
    timeLeft : DATE_AND_TIME;
    
    targetMonths : UINT;
    targetDays : UINT;
    targetHours : UINT;
    targetMinutes : UINT;
    targetSeconds : UINT;
    currentMonths : UINT;
    currentDays : UINT;
    currentHours : UINT;
    currentMinutes : UINT;
    currentSeconds : UINT;
    timeLeftMonths : UINT;
    timeLeftDays : UINT;
    timeLeftHours : UINT;
    timeLeftMinutes : UINT;
    timeLeftSeconds : UINT;
    timeLeftString : STRING[250];
END_VAR
VAR
    iState                    : INT;
    udiUtcTime             : UDINT;
    udiUtcTimeLocal     : UDINT;
    strTimeDate         : SYSTIMEDATE;
    strTimeDateLocal     : SYSTIMEDATE;
    dtDateTimeUTC        : DATE_AND_TIME;
    timeLeftTime        : TIME;
    timeLeftDWORD        : DWORD;
    dDateUTC            : DATE;
    todTimeOfDayUTC        : TOD;
    
    tSysStartTime        : TIME;
    systimeStartNano    : SYSTIME;
    udiStartTimeResult    : UDINT;
    
    udiResult             : UDINT;
    
    
    GetDateAndTime            : DTU.GetDateAndTime;
    SetTimeZoneInformation    : DTU.SetTimeZoneInformation;
    
    dtCurrent                : DATE_AND_TIME;
    dtConcated                : DATE_AND_TIME;
    eWeekday                 : RTCLK.WEEKDAY;
    uiYear                     : UINT;
    uiMonth                     : UINT;
    uiDay                     : UINT;
    uiHour                     : UINT;
    uiMinute                 : UINT;
    uiSecond                 : UINT;
        
    dtuError                : DTU.ERROR;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE iState OF

    0:    
        iState:= 1;
        
    1:  // retrieves the target date and time, including the timezone information which was set before
        GetDateAndTime( xExecute:= TRUE);
        IF GetDateAndTime.xDone THEN
            dtCurrent:= GetDateAndTime.dtDateAndTime;
            GetDateAndTime(xExecute:= FALSE);
            //timeLeft := TIME_TO_DT(DT_TO_TIME(targetDate) - DT_TO_TIME(dttarget));
            iState:= 2;
        END_IF
        IF GetDateAndTime.xError THEN
            GetDateAndTime(xExecute:= FALSE);
            iState:= 32767;
        END_IF
    
    2: (*set a spedific date and time --> returns a variable of type DATE_AND_TIME 
         DateConcat --> set only date information --> returns a variable of type DATE
         TODConcat  --> set only the time information  --> returns a variable of TOD (Time of day) *)
        dtConcated := DTU.DTConcat(uiYear:= 2010, uiMonth:= 10, uiDay:= 5, 
                            uiHour:= 9, uiMinute:= 20, uiSecond:= 12, peError:=ADR(dtuError));
        IF dtuError = 0 THEN
            iState := 3;
        ELSE
            iState := 32767;
        END_IF
        
    3:  (*a DATE_AND_TIME variable is splitted in its parts, like year, month, day etc.
            DateSplit --> the same function for a DATE variable
            TODSplit  --> the same function for a TOD variable *)
        dtuError := DTU.DTSplit(
            dtDateAndTime := dtCurrent,
            puiYear := ADR(uiYear), 
            puiMonth := ADR(currentMonths), 
            puiDay := ADR(currentDays), 
            puiHour := ADR(currentHours), 
            puiMinute := ADR(currentMinutes), 
            puiSecond := ADR(currentSeconds));
        dtuError := DTU.DTSplit(
            dtDateAndTime := targetDate,
            puiYear := ADR(uiYear), 
            puiMonth := ADR(targetMonths), 
            puiDay := ADR(targetDays), 
            puiHour := ADR(targetHours), 
            puiMinute := ADR(targetMinutes), 
            puiSecond := ADR(targetSeconds));
            
        IF dtuError = 0 THEN
            iState:= 1;
        ELSE
            iState:= 32767;
        END_IF
        
    32767: ; //error

END_CASE

timeLeftMonths := currentMonths - targetMonths;
timeLeftDays := currentDays - targetDays;
timeLeftHours := currentHours - targetHours;
timeLeftMinutes := currentMinutes - targetMinutes;
timeLeftSeconds := currentSeconds - targetSeconds;

timeLeftString := CONCAT('Time left to PMMI: ', UINT_TO_STRING(timeLeftMonths));
timeLeftString := CONCAT(' Months, ', UINT_TO_STRING(timeLeftDays));
timeLeftString := CONCAT(' Days, ', UINT_TO_STRING(timeLeftHours));
timeLeftString := CONCAT(' Hours, ', UINT_TO_STRING(timeLeftMinutes));
timeLeftString := CONCAT(' Minutes, ', UINT_TO_STRING(timeLeftSeconds));
timeLeftString := CONCAT(' Seconds', '');

timeLeftDWORD := DT_TO_DWORD(targetDate) - DT_TO_DWORD(dtCurrent);
timeLeftDays := DWORD_TO_UINT(timeLeftDWORD / 86000);
