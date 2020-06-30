(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mPackDDOp : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Pack data for direct data operation
modbusDirectDataToDrive[0] := directDataOp.OperationNo.wWord[1];
modbusDirectDataToDrive[1] := directDataOp.OperationNo.wWord[0];
modbusDirectDataToDrive[2] := directDataOp.OperationType.wWord[1];
modbusDirectDataToDrive[3] := directDataOp.OperationType.wWord[0];
modbusDirectDataToDrive[4] := directDataOp.Position.wWord[1];
modbusDirectDataToDrive[5] := directDataOp.Position.wWord[0];
modbusDirectDataToDrive[6] := directDataOp.Speed.wWord[1];
modbusDirectDataToDrive[7] := directDataOp.Speed.wWord[0];
modbusDirectDataToDrive[8] := directDataOp.RateOfChange.wWord[1];
modbusDirectDataToDrive[9] := directDataOp.RateOfChange.wWord[0];
modbusDirectDataToDrive[10] := directDataOp.StoppingDecel.wWord[1];
modbusDirectDataToDrive[11] := directDataOp.StoppingDecel.wWord[0];
modbusDirectDataToDrive[12] := directDataOp.Current.wWord[1];
modbusDirectDataToDrive[13] := directDataOp.Current.wWord[0];
modbusDirectDataToDrive[14] := directDataOp.Trigger.wWord[1];
modbusDirectDataToDrive[15] := directDataOp.Trigger.wWord[0];