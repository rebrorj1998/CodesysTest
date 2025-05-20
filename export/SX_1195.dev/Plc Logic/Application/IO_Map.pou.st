(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM IO_Map
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//Output Configuration

oSealWire REF= IO_Mapping.mainIOamax4830Output[0].discreteSignal;
oLowerPrinthead REF= IO_Mapping.mainIOamax4830Output[1].discreteSignal;
oRequestPrint REF=IO_Mapping.mainIOamax4830Output[2].discreteSignal;
oPrinterRibbonUnwind REF=IO_Mapping.mainIOamax4830Output[3].discreteSignal;
oTriggerBCV REF=IO_Mapping.mainIOamax4830Output[4].discreteSignal;
//IO_Mapping.mainIOamax4830Output[5].discreteSignal;
oFansEnable REF=IO_Mapping.mainIOamax4830Output[6].discreteSignal;
oBaggerOK REF=IO_Mapping.mainIOamax4830Output[7].discreteSignal;
oWaitingForPrinter REF= IO_Mapping.mainIOamax4830Output[8].discreteSignal;
oPalmButton0 REF=IO_Mapping.mainIOamax4830Output[9].discreteSignal;
oPalmButton1 REF=IO_Mapping.mainIOamax4830Output[10].discreteSignal;
oPbarClampMotorStart REF=IO_Mapping.mainIOamax4830Output[11].discreteSignal;
oPbarClampMotorReverse REF=IO_Mapping.mainIOamax4830Output[12].discreteSignal;
oPbarClampMotorAlarmReset REF=IO_Mapping.mainIOamax4830Output[13].discreteSignal;
//IO_Mapping.mainIOamax4830Output[14].discreteSignal;
//IO_Mapping.mainIOamax4830Output[15].discreteSignal;

IO_Mapping.mainIOamax4830Output[0].signalCommonName := 'O0\0: Seal Wire';
IO_Mapping.mainIOamax4830Output[1].signalCommonName := 'O0\1: Lower Print Head';
IO_Mapping.mainIOamax4830Output[2].signalCommonName := 'O0\2: Request Print';
IO_Mapping.mainIOamax4830Output[3].signalCommonName := 'O0\3: Printer Ribbon Unwind';
IO_Mapping.mainIOamax4830Output[4].signalCommonName := 'O0\4: Trigger Barcode Verification';
IO_Mapping.mainIOamax4830Output[5].signalCommonName := 'O0\5: Spare';
IO_Mapping.mainIOamax4830Output[6].signalCommonName := 'O0\6: Fans Enable';
IO_Mapping.mainIOamax4830Output[7].signalCommonName := 'O0\7: Bagger OK';
IO_Mapping.mainIOamax4830Output[8].signalCommonName := 'O0\8: Waiting for Printer';
IO_Mapping.mainIOamax4830Output[9].signalCommonName := 'O0\9: Palm Button 0';
IO_Mapping.mainIOamax4830Output[10].signalCommonName := 'O0\10: Palm Button 1';
IO_Mapping.mainIOamax4830Output[11].signalCommonName := 'O0\11: Pbar Clamp Motor Start';
IO_Mapping.mainIOamax4830Output[12].signalCommonName := 'O0\12: Pbar Clamp Motor Reverse';
IO_Mapping.mainIOamax4830Output[13].signalCommonName := 'O0\13: Pbar Clamp Motor Alarm Reset';
IO_Mapping.mainIOamax4830Output[14].signalCommonName := 'O0\14: Spare';
IO_Mapping.mainIOamax4830Output[15].signalCommonName := 'O0\15: Spare';


//Input Configuration

iPrinterServiceRequired REF= IO_Mapping.mainIOamax4830Input[0].discreteSignal;
iPrinterDataReady REF= IO_Mapping.mainIOamax4830Input[1].discreteSignal;
iPrinterBusy REF= IO_Mapping.mainIOamax4830Input[2].discreteSignal;
iBagEdgePhotoeye REF= IO_Mapping.mainIOamax4830Input[3].discreteSignal;
iCycleStart REF= IO_Mapping.mainIOamax4830Input[4].discreteSignal;
iPbarClampMotorAlarm REF= IO_Mapping.mainIOamax4830Input[5].discreteSignal;
iClampHomeSensor REF= IO_Mapping.mainIOamax4830Input[6].discreteSignal;
iJawNotObstructed REF= IO_Mapping.mainIOamax4830Input[7].discreteSignal;
iBarcodeOK REF= IO_Mapping.mainIOamax4830Input[8].discreteSignal;
iBarcodeNG REF= IO_Mapping.mainIOamax4830Input[9].discreteSignal;
iLightCurtainClear REF= IO_Mapping.mainIOamax4830Input[10].discreteSignal;
iLightCurtainStart REF=IO_Mapping.mainIOamax4830Input[11].discreteSignal;
//IO_Mapping.mainIOamax4830Input[12].discreteSignal;
iEstopNormal REF= IO_Mapping.mainIOamax4830Input[13].discreteSignal;
iSafePowerOK REF= IO_Mapping.mainIOamax4830Input[14].discreteSignal;
iPrinterRibbonEncoder REF= IO_Mapping.mainIOamax4830Input[15].discreteSignal;

IO_Mapping.mainIOamax4830Input[0].signalCommonName := 'I0\0: Printer Service Required';
IO_Mapping.mainIOamax4830Input[1].signalCommonName := 'I0\1: Printer Data Ready';
IO_Mapping.mainIOamax4830Input[2].signalCommonName := 'I0\2: Printer Busy';
IO_Mapping.mainIOamax4830Input[3].signalCommonName := 'I0\3: Bag Edge Detect Photoeye';
IO_Mapping.mainIOamax4830Input[4].signalCommonName := 'I0\4: Cycle Start';
IO_Mapping.mainIOamax4830Input[5].signalCommonName := 'I0\5: Pbar Clamp Motor Alarm';
IO_Mapping.mainIOamax4830Input[6].signalCommonName := 'I0\6: Clamp Home Sensor';
IO_Mapping.mainIOamax4830Input[7].signalCommonName := 'I0\7: Jaw Not Obstructed';
IO_Mapping.mainIOamax4830Input[8].signalCommonName := 'I0\8: Barcode OK';
IO_Mapping.mainIOamax4830Input[9].signalCommonName := 'I0\9: Barcode NG';
IO_Mapping.mainIOamax4830Input[10].signalCommonName := 'I0\10: Light Curtain Clear';
IO_Mapping.mainIOamax4830Input[11].signalCommonName := 'I0\11: Spare';
IO_Mapping.mainIOamax4830Input[12].signalCommonName := 'I0\12: Spare';
IO_Mapping.mainIOamax4830Input[13].signalCommonName := 'I0\13: E-Stop OK';
IO_Mapping.mainIOamax4830Input[14].signalCommonName := 'I0\14: Safe Power OK';
IO_Mapping.mainIOamax4830Input[15].signalCommonName := 'I0\15: Printer Ribbon Encoder';