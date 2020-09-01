(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckBounds : DINT
VAR_INPUT
	index, lower, upper: DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF  index < lower THEN
	CheckBounds := lower;
ELSIF  index > upper THEN
	CheckBounds := upper;
ELSE  
	CheckBounds := index;
END_IF

(*It is also possible to set a breakpoint, log messages or e.g. to halt on an exception:
Add CmpApp.library, SysExcept.library and SysTypes2_Itf as newest.
Declaration:
VAR
    _pApp : POINTER TO CmpApp.APPLICATION;
    _result   : SysTypes.RTS_IEC_RESULT;
END_VAR

Implementation:
_pApp := AppGetCurrent(pResult:=_result);
IF  index < lower THEN
        CheckBounds := lower;
        IF _pApp <> 0 THEN
                AppGenerateException(pApp:=_pApp, ulException:=RtsExceptions.RTSEXCPT_ARRAYBOUNDS);
        END_IF
ELSIF  index > upper THEN
        CheckBounds := upper;
        IF _pApp <> 0 THEN
                AppGenerateException(pApp:=_pApp,   ulException:=RtsExceptions.RTSEXCPT_ARRAYBOUNDS);
        END_IF
ELSE  
        CheckBounds := index;
END_IF
*)
