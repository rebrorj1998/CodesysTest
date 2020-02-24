(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_GetTime
VAR_INPUT
END_VAR
VAR_OUTPUT
    currentDateAndTime : DATE_AND_TIME;
    
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
    //eWeekday                 : RTCLK.WEEKDAY;
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
			currentDateAndTime := dtCurrent;
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
        IF dtuError = 0 THEN
            iState := 3;
        ELSE
            iState := 32767;
        END_IF
        
    3:  (*a DATE_AND_TIME variable is splitted in its parts, like year, month, day etc.
            DateSplit --> the same function for a DATE variable
            TODSplit  --> the same function for a TOD variable *)

            
        IF dtuError = 0 THEN
            iState:= 1;
        ELSE
            iState:= 32767;
        END_IF
        
    32767: ; //error

END_CASE

