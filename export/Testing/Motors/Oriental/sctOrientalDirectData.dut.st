(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctOrientalDirectData :
STRUCT
	OperationNo : uModbusDWORD;
	OperationType : uModbusDWORD;
	Position : uModbusDWORD;
	Speed : uModbusDWORD;
	RateOfChange : uModbusDWORD;
	StoppingDecel : uModbusDWORD;
	Current : uModbusDWORD;
	Trigger : uModbusDWORD;
END_STRUCT
END_TYPE
