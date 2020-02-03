(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE ModbusLongType :
STRUCT
    highWord : WORD;
    lowWord : WORD;
    displayValue : DINT;
    rawValue : DINT;
END_STRUCT
END_TYPE
