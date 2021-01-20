(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ModbusDWORD
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    _highWord : WORD;
    _lowWord : WORD;
    _rawValue : DWORD;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_ModbusDWORD
//    Description: Automatically handles the packing and unpacking of Upper and Lower words to create a DWORD
//    for 16 bit modbus communications
//    
//    Created by: Ben Hess
//    Created Date: Wednesday, April 11, 2018
