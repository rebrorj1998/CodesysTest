(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
//Taken from Host-Command-Reference pdf on Applied Motion website
TYPE eAppliedMotionOpcodes :
(
	ALARM_RESET := 16#BA,     
	START_JOGGING := 16#96,     
	STOP_JOGGING := 16#D8,     
	ENCODER_FUNCTION := 16#D6,     //0
	ENCODER_POSITION := 16#98,     //Position
	FEED_TO_DOUBLE_SENSOR := 16#69,     //I/O Point 1 Condition 1 I/O Point 2 Condition 2
	FOLLOW_ENCODER := 16#CC,     //I/O Point Condition
	FEED_TO_LENGTH := 16#66,     
	FEED_TO_SENSOR_WITH_MASK_DISTANCE := 16#6A,     //I/O Point Condition
	FEED_AND_SET_OUTPUT := 16#68,     //I/O Point Condition
	FEED_TO_POSITION := 16#67,     
	FEED_TO_SENSOR := 16#6B,     //I/O Point Condition
	FEED_TO_SENSOR_WITH_SAFETY_DISTANCE := 16#6C,     //I/O Point Condition
	JOG_DISABLE := 16#A3,     
	JOG_ENABLE := 16#A2,     
	MOTOR_DISABLE := 16#9E,     
	MOTOR_ENABLE := 16#9F,     
	SEEK_HOME := 16#6E,     //I/O Point Condition
	SET_POSITION := 16#A5,     //Position
	FILTER_INPUT := 16#C0,     //I/O Point Filter Time
	FILTER_SELECT_INPUTS := 16#D3,     
	STEP_FILTER_FREQ := 16#06,     //Freq
	ANALOG_DEADBAND := 16#D2,     //0.001 V
	ALARM_RESET_INPUT := 16#46,     //Function ('1'..'3') I/O Point
	ALARM_OUTPUT := 16#47,     //Function ('1'..'3') I/O Point
	ANALOG_SCALING := 16#D1,     
	DEFINE_LIMITS := 16#42,     //1..3
	SET_OUTPUT := 16#8B,     //I/O Point Condition
	WAIT_FOR_INPUT := 16#70,     
	QUEUE_LOAD_AND_EXECUTE := 16#78,     //1..12
	WAIT_TIME := 16#6F,     //0.01 sec
	STOP_MOVE_KILL_BUFFER := 16#E1,    
	STOP_MOVE_KILL_BUFFER_NORMAL_DECEL := 16#E2,
	STOP_MOVE := 16#B5  // Might work, might not     
);
END_TYPE