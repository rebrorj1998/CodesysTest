(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FINAL AddObject
VAR_INPUT
	Obj   : IAllObjects;
END_VAR
VAR
	AnyObject : IAllObjects;
	Fault : IFault;
	Cylinder : ICylinder;
	PositionableMotor : IPositionableMotor;
	Logger : IMachineLogger;
	Loggable : ILoggable;
	Executable : IExecuteAutomatically;
	Initializable : IInitializable;
	J   : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF (__QUERYINTERFACE(Obj, AnyObject)) THEN
   // make sure haven't already added this object
   FOR J:= 1 TO _TotalObj DO
      IF Collection[J] = AnyObject THEN
         // object pointer matches - dupe!
         _DupeObj:= _DupeObj + 1;
         RETURN;
      END_IF
   END_FOR
   
   IF _TotalObj < GlobalObjects.MAX_OBJECTS THEN
      Collection[_TotalObj]:= AnyObject;
      ObjNames[_TotalObj]:= Obj.InstanceName;
	   _TotalObj:= _TotalObj + 1;
   ELSE
      _ArrayOver:= TRUE;
      _OverObj:= _OverObj + 1;
   END_IF
ELSE
   _BadObj:= _BadObj + 1;
END_IF

// Add object to proper collection based on its interfaces
IF (__QUERYINTERFACE(Obj, Fault)) THEN
	GlobalObjects.CollectionOfFaults.AddObject(Fault);
END_IF

IF (__QUERYINTERFACE(Obj, Cylinder)) THEN
	GlobalObjects.CollectionOfCylinders.AddObject(Cylinder);
END_IF

IF (__QUERYINTERFACE(Obj, PositionableMotor)) THEN
	GlobalObjects.CollectionOfPositionableMotors.AddObject(PositionableMotor);
END_IF

IF (__QUERYINTERFACE(Obj, Logger)) THEN
	GlobalObjects.CollectionOfLogs.AddObject(Logger);
END_IF

IF (__QUERYINTERFACE(Obj, Loggable)) THEN
	GlobalObjects.CollectionOfLoggable.AddObject(Loggable);
END_IF

IF (__QUERYINTERFACE(Obj, Executable)) THEN
	GlobalObjects.CollectionOfExecutable.AddObject(Executable);
END_IF

IF (__QUERYINTERFACE(Obj, Initializable)) THEN
	GlobalObjects.CollectionOfInitialzable.AddObject(Initializable);
END_IF