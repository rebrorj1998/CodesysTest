(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RegisterWithFaultHandler : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// If faulthandler hasn't been initialized yet then do nothing.

(*
IF NOT __ISVALIDREF(faultHandler) THEN
     RETURN;
END_IF

interfaceToPass := THIS^;
faultHandler.registerFaultSource(interfaceToPass);
RegisterWithFaultHandler := TRUE;
*)
