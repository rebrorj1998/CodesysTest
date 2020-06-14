(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'to_string'}
TYPE eOrientalAZDriveFaults :
(
	ExcessivePositionDeviation := 16#10,
	Overcurrent := 16#20,
	MainCircuitOverheat := 16#21,
	Overvoltage := 16#22,
	MainPowerOff := 16#23,
	Undervoltage := 16#25,
	MotorOverheat := 16#26,
	SensorError := 16#28,
	ABZOSensorComm := 16#2A,
	Overload := 16#30,
	Overspeed := 16#31,
	AbsPositionError := 16#33,
	CommandPulseError := 16#34,
	EEPROMError := 16#41,
	SensorErrorPowerup := 16#42,
	RotationErrorPowerup := 16#43,
	EncoderEEPROMError := 16#44,
	MotorCombinationError := 16#45,
	ReturnToHomeIncomplete := 16#4A,
	RegenUnitOverheat := 16#51,
	EStopCircuitError := 16#53,
	LSBothSidesActive := 16#60,
	ReversLSDirection := 16#61,
	ReturnToHomeOpError := 16#62,
	NoHOMES := 16#63,
	TIM_Z_SLITSignalError := 16#64,
	HardwareOvertravel := 16#66,
	SoftwareOvertravel := 16#67,
	Estop := 16#68,
	ReturnToHomeOpOffsetError := 16#6A,
	MechanicalOvertravel := 16#6D,
	OpDataError := 16#70,
	ElectronicGearSettingError := 16#71,
	WrapSettingError := 16#72,
	NetworkBusError := 16#81,
	CommSwitchSettingError := 16#83,
	RS485CommError := 16#84,
	RS485Timeout := 16#85,
	NetworkConverterError := 16#8E,
	CPUError := 16#F0
);
END_TYPE
