(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE PMLa :
STRUCT
	Parameter : ARRAY [0..Packml_Variable_Config.maxParameters] OF Descriptor;
	Alarm : ARRAY[0..Packml_Variable_Config.maxAlarms] OF pacalarm;
	AlarmExtent : DINT;
	ModeCurrentTime : ARRAY[0..Packml_Variable_Config.maxModeCurrentTimes] OF DINT;
	ModeCumulativeTime : ARRAY[0..Packml_Variable_Config.maxModeCumulativeTimes] OF DINT;
	StateCurrentTime : ARRAY[0..Packml_Variable_Config.maxStateCurrentTimes] OF DINT;
	StateCumulativeTime : ARRAY[0..Packml_Variable_Config.maxStateCumulativeTimes] OF DINT;
END_STRUCT
END_TYPE


// 7.5.3 Administration Tags 

// Administration tags are used to describe the quality and alarm information of the unit 
// machine. Administration tags include alarm parameters which describe the conditions within 
// the Base State model typically for production data acquisition (PDA) systems. The 
// administration tags also include parameters which can describe how well the machine 
// operates, or specifically information on the product quality produced by the machine. 
// Administration tags generally originate from the unit machine and can be used on the HMI or 
// a remote system. 

// 7.5.3.1 Admin.Parameter[#] 

// Data Type: Array of Data Type Descriptor 
// The Parameter tags associated to the local interface are typically used for as parameters that 
// are displayed or used on the unit locally, for example from an HMI. These parameters can be 
// used to display any quality, alarm, or machine downtime parameter. The parameters are 
// typically limited to parameters related the unit. The extent of the array is the maximum 
// number of parameters needed. 

// 7.5.3.1.1 Admin.Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) ID value of the parameter. This is non-descript value that 
// can be used for any user tag requirements 

// 7.5.3.1.2 Admin.Parameter[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Parameter Names for the Machine Unit 
// The parameter name is used to describe the parameter number, and its associated value. An 
// example parameter name may be CASES MADE, OPERATOR SHIFT, REJECTED 
// PRODUCTS, etc. This also could be displayed on HMI screens. The array is typically needed 
// for machines that have quality reporting or PDA (Production Data Acquisition) needs. 

// 7.5.3.1.3 Admin.Parameter[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Parameter Variable Unit of Measure for the Machine Unit 
// The administration parameter unit of measure is used to describe the unit of measure of the 
// parameter, and its associated value. An example parameter unit of measure may be CASES, 
// PROD, PPM, etc. This also could be displayed on HMI screens. 

// 7.5.3.1.4 Admin.Parameter[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured Array of Parameter Values 
// The parameter value is used to specify a unit machine variable for use in the PDA or to be 
// sent to an “information receiver”. This is also could be displayed on HMI screens. As an 
// example: 
// Admin.Parameter[1].Value = 50019 
// An example of a machine unit process variable: 
// Admin.Parameter[1].Name = TOTAL PRODUCTION 
// Admin.Parameter[1].Unit = STAT 
// Admin.Parameter[1].Value = 50010. 

// 7.5.3.2 Admin.Alarm[#] 

// Data Type: Alarm 
// Descriptor: Array of Given Size for Machine Fault Number and Messaging 
// The Alarm tags associated with the local interface are typically used as parameters that are 
// displayed or used on the unit locally, for example from a HMI. These alarm parameters can 
// be used to display any alarm, or machine downtime cause that is currently occurring in the 
// system. The alarms are typically limited to the machine unit. The extent of the array is the 
// maximum number of alarms needed to be annunciated. 

// 7.5.3.2.1 Admin.Alarm[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: Alarm Message Identification Number 
// The Alarm ID number is an unique value assigned to each alarm. The ID can be used for any 
// general alarms and faults (alarms detailed in Appendix A). 
//  
// 7.5.3.2.2 Admin.Alarm[#].Value 

// Data Type: INT (32bit) 
// Tag Descriptor: Alarm Message Number 
// The Alarm Message number is a value that is associated with the alarm allowing for user 
// specific detail, or to break down the Alarm.ID to greater detail (alarms detailed in Appendix 
// A). For instance an Alarm[#].ID value of 4 from Appendix A may require a more detailed 
// breakdown as shown in Appendix A. 

// 7.5.3.2.3 Admin.Alarm[#].Message 

// Data Type: String 
// Tag Descriptor: Alarm Message 
// The alarm message is the actual text of the alarm for those machines capable of reading the 
// string information. 

// 7.5.3.2.4 Admin.Alarm[#].TimeEvent 

// Data Type: TimeStamp 
// Structure of date and time in the alarm array to detail the date and time the alarm occurred. 

// 7.5.3.2.4.1 Admin.Alarm[#].TimeEvent.AlmDate 

// Data Type: Date 
// Tag Descriptor: ISO Date Data type 
// Defines the date the alarm has occurred in ISO 8601:1988 format (defines as seconds from 
// January 1, 1970 at 12:00am). 

// 7.5.3.2.4.2 Admin.Alarm[#].TimeEvent.AlmTime 

// Data Type: Time 
// Tag Descriptor: ISO Time Data Type 
// Defines the time the alarm has occurred in ISO 8601:1988 format (defines as seconds from 
// January 1, 1970 at 12:00am). 

// 7.5.3.2.5 Admin.Alarm[#].TimeAck 

// Data Type: TimeStamp 
// Structure of date and time in the alarm array to detail the date and time the alarm was 
// acknowledged. 

// 7.5.3.2.5.1 Admin.Alarm[#].TimeAck.AlmDate 

// Data Type: Date 
// Tag Descriptor: ISO Date Data type 
// Defines the time the alarm was acknowledged in ISO 8601:1988 format (defines as seconds 
// from January 1, 1970 at 12:00am). 

// 7.5.3.2.5.2 Admin.Alarm[#].TimeAck.AlmTime 

// Data Type: Time 
// Tag Descriptor: ISO Time Data Type 
// Defines the date the alarm was acknowledged in ISO 8601:1988 format (defines as seconds 
// from January 1, 1970 at 12:00am). 
// The following is an example of how the Alarm structure may appear: 
// The alarm array is for currently occurring alarms and will can be sorted in chronological order 
// with the most recently occurring alarmed indexed as Admin.Alarm[0]. 
// Any unused elements in the array should be set to the following values: 
// Admin.Alarm[#].ID 0 
// Admin.Alarm[#].Value 0 
// Admin.Alarm[#].Message “” 
// Admin.Alarm[#].TimeEvent.AlmDate 0 
// Admin.Alarm[#].TimeEvent.AlmTime 0 
// Admin.Alarm[#].TimeAck.AlmDate 0 
// Admin.Alarm[#].TimeAck.AlmTime 0 

// 7.5.3.3 Admin.AlarmExtent 

// Data Type: INT (32bit) 
// Tag Descriptor: Extent of Alarm Array 
// The alarm extent is associated with the maximum number of alarms needed for the machine 
// annunciation or reporting. This tag can be used by a remote machine to understand the 
// extent of the alarm array, or locally to manage the use of the array. 

// 7.5.3.4 Admin.AlarmHistory[#] 

// Data Type: Alarm 
// Descriptor: Array of Given Size for Machine Fault Number and Messaging History 
// The Alarm tags associated to the local interface are typically used for parameters that are 
// displayed or used on the unit locally, for example for a HMI. These alarm history parameters 
// can be used to display any alarm history, or machine downtime cause. The historical alarms 
// are typically limited to the machine unit. The extent of the array is the maximum number of 
// historical alarms needed. 

// 7.5.3.4.1 Admin.AlarmHistory[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: Alarm Message Identification Number 
// The Alarm ID number is an unique value assigned to each alarm. The ID can be used for any 
// general alarms and faults (alarms detailed in Appendix A). 
//  
// 7.5.3.4.2 Admin.AlarmHistory[#].Value 

// Data Type: INT (32bit) 
// Tag Descriptor: Alarm Message Number 
// The Alarm Message number is a value that is associated with the alarm allowing for user 
// specific detail, or to break down the Alarm.ID to greater detail (alarms detailed in Appendix 
// A). For instance an Alarm[#].ID value of 4 from Appendix A may require a more detailed 
// breakdown as shown in Appendix A. 

// 7.5.3.4.3 Admin.AlarmHistory[#].Message 

// Data Type: String 
// Tag Descriptor: Alarm Message 
// The alarm message is the actual text of the alarm for those machines capable of reading the 
// string information. 

// 7.5.3.4.4 Admin.AlarmHistory[#].TimeEvent 

// Data Type: TimeStamp 
// Structure of date and time in the alarm array to detail the date and time the alarm occurred. 

// 7.5.3.4.4.1 Admin.AlarmHistory[#].TimeEvent.AlmDate 

// Data Type: Date 
// Tag Descriptor: ISO Date Data Type 
// Defines the date the alarm has occurred in ISO 8601:1988 format (defines as seconds from 
// January 1, 1970 at 12:00am). 

// 7.5.3.4.4.2 Admin.AlarmHistory[#].TimeEvent.AlmTime 

// Data Type: Date 
// Tag Descriptor: ISO Time Data Type 
// Defines the Time the alarm has occurred in ISO 8601:1988 format (defines as seconds from 
// January 1, 1970 at 12:00am). 

// 7.5.3.4.5 Admin.AlarmHistory[#].TimeAck 

// Data Type: TimeStamp 
// Structure of date and time in the alarm array to detail the date and time the alarm was 
// acknowledged. 

// 7.5.3.4.5.1 Admin.AlarmHistory[#].TimeAck.AlmDate 

// Data Type: Date 
// Tag Descriptor: ISO Date Data Type 
// Defines the date the alarm has occurred in ISO 8601:1988 format (defines as seconds from 
// January 1, 1970 at 12:00am). 

// 7.5.3.4.5.2 Admin.AlarmHistory[#].TimeAck.AlmTime 

// Data Type: Date 
// Tag Descriptor: ISO Time Data Type 
// Defines the Time the alarm has occurred in ISO 8601:1988 format (defines as seconds from 
// January 1, 1970 at 12:00am). 
// The following is an example of how the AlarmHistory structure may appear: 
// The AlarmHistory array is reserved for alarms that have occurred and can be sorted in 
// chronological order with the most recently occurring alarmed indexed as 
// Admin.AlarmHistory[0]. 
// Any unused elements should be set to the following values 
// Admin.AlarmHistory[#].ID 0 
// Admin.AlarmHistory[#].Value 0 
// Admin.AlarmHistory[#].Message “” 
// Admin.AlarmHistory[#].TimeEvent.AlmDate 0 
// Admin.AlarmHistory[#].TimeEvent.AlmTime 0 
// Admin.AlarmHistory[#].TimeAck.AlmDate 0 
// Admin.AlarmHistory[#].TimeAck.AlmTime 0 

// 7.5.3.5 Admin.AlarmHistoryExtent 

// Data Type: INT (32bit) 
// Tag Descriptor: Extent of Alarm History Array 
// The alarm history extent is associated with the maximum number of alarms needed to be 
// archived or tagged as alarm history for the machine. This tag can be used by a remote 
// machine to understand the extent of the alarm array, or locally to manage the array. 

// 7.5.3.6 Admin.ModeCurrentTime[#] 

// Data Type: INT (32bit) 
// Unit of Measure: sec 
// Tag Descriptor: Array of Timer Values 
// This tag represents the current amount of time (in sec) in any defined unit mode. The array 
// index is equal to the designation of the of the unit machine mode values – defined in 
// Status.UnitModeCurrent. The values roll over to 0 at 2,147,483,647. 

// 7.5.3.7 Admin.ModeCumulativeTime[#] 

// Data Type: INT (32bit) 
// Unit of Measure: sec 
// Tag Descriptor: Array of Timer Values 
// This tag represents the cumulative amount of time (in sec) in any defined unit mode. The 
// array index is equal to the designation of the of the unit machine mode values – defined in 
// Status.UnitModeCurrent. The value is the cumulative elapsed time the machine has spent in 
// each mode since its timers and counters were reset. The values roll over to 0 at 
// 2,147,483,647. 

// 7.5.3.8 Admin.StateCurrentTime[#,#] 

// Data Type: INT (32bit) 
// Unit of Measure: sec 
// Tag Descriptor: Array of Timer Values 
// This tag represents the current amount of time (in sec) in any defined state in any particular 
// mode. The array index is equal to the designation of the of the unit machine mode values 
// defined in Status.UnitModeCurrent, and the state values defined in Status.StateCurrent; such 
// that the array index is [Status.UnitModeCurrent, Status.StateCurrent]. The values roll over to 
// 0 at 2,147,483,647. 

// 7.5.3.9 Admin.StateCumulativeTime[#,#] 

// Data Type: INT (32bit) 
// Unit of Measure: sec 
// Tag Descriptor: Array of Timer Values 
// This tag represents the cumulative amount of time (in sec) in any defined state in any 
// particular mode since the last timer and counter reset was executed. The array index is equal 
// to the designation of the of the unit machine mode values defined in Status.UnitModeCurrent, 
// and the state values defined in Status.StateCurrent; such that the array index is 
// [Status.UnitModeCurrent, Status.StateCurrent]. The values roll over to 0 at 2,147,483,647. 
//  
// 7.5.3.10 Admin.ProdConsumedCount[#] 

// Data Type: Array of Data Type ProdCount 
// This tag represents the material used/consumed in the production machine. An example of 
// tag usage would be the number of bags consumed in a Filler, or bagger packaging machine, 
// or the amount of linear length used, or the number caps used. This tag can be used locally or 
// remotely if needed. The extent of the array is typically limited to the number of raw materials 
// needed to be counted. The array is typically used for unit machines that run multiple raw 
// materials. This array may also be used to track the number of unfinished products entering a 
// machine for processing, but typically Admin.ProdProcessedCount[#] is used for this. 

// 7.5.3.10.1 Admin.ProdConsumedCount[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of ProdConsumedCount 
// This is the arbitrary (user defined) ID value of the consumed production material. This is nondescript value that can be used for any user tag requirements. The ID value can be SKU or a 
// user specific material identifier. 

// 7.5.3.10.2 Admin.ProdConsumedCount[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Names in ProdConsumedCount 
// The name is used to literally describe the material ID, and its associated material. An example 
// parameter name may be PRODUCT A BAGS, XYZ CAPS FOR ABC PRODUCT, etc. This 
// also could be displayed on HMI screens. The array is typically needed for machines that have 
// quality reporting or PDA (Production Data Acquisition) needs. 

// 7.5.3.10.3 Admin.ProdConsumedCount[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Units in ProdConsumedCount 
// The unit tag is used to describe the names associated with a specific material used by the 
// machine. An example process unit of measure name may be FT, CNT, KG, etc. This also 
// could be displayed on HMI screens. 

// 7.5.3.10.4 Admin.ProdConsumedCount[#].Count 

// Data Type: Int(32bit) 
// Tag Descriptor: Structured Array of Values 
// The count value is used as a variable for displaying information about the amount of 
// consumed production material. The value is indexed upon the machine consuming a unit of 
// the material defined by the ID and NAME. This could be displayed on HMI screens or higher 
// level PDA systems. The counter rolls over to 0 at 2,147,483,648. 

// 7.5.3.10.5 Admin.ProdConsumedCount[#].AccCount 

// Data Type: Int(32bit) 
// Tag Descriptor: Structured Array of Values 
// The accumulative count value is used as a variable for displaying information about the total 
// amount of consumed production material. The value is indexed upon the machine consuming 
// a unit of the material defined by the ID and NAME. This could be displayed on HMI screens 
// or higher level PDA systems. This counter gives the user a non-resetting counter that may be 
// used for OEE calculations. The counter rolls over to 0 at 2,147,483,648. 
// An example of the Production Consumption counter is the following: 
// Admin.ProdConsumedCount[1].ID = 546732 
// Admin.ProdConsumedCount[1].Name = LABELS FOR XYZ 
// Admin.ProdConsumedCount[1].Units = CNT 
// Admin.ProdConsumedCount[1].Count = 2305 
// Admin.ProdConsumedCount[1].AccCount = 14,995,100 
// The above describes consumed labels used by the machine for product XYZ as being 2305 
// since the last operator reset and 14,995,100 since the last accumulative counter reset. 

// 7.5.3.11 Admin.ProdProcessedCount[#] 

// Data Type: Array of Data Type ProdCount 
// This tag represents the number of products processed by the production machine. An 
// example of tag usage would be the number of products that were made, including all good 
// and defective products. This tag can be used locally or remotely if needed. The extent of the 
// array is typically limited to the number of products needed to be counted. The number of 
// products processed minus the defective count is the number of products made by the 
// machine. The array index of # = 0 can be reserved for the count of the number of units from 
// the primary production stream. 

// 7.5.3.11.1 Admin.ProdProcessedCount[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of ProdProcessedCount 
// This is the arbitrary (user defined) ID value of the processed products. This is non-descript 
// value that can be used for any user tag requirements. The ID value can be SKU or a user 
// specific product identifier. 

// 7.5.3.11.2 Admin.ProdProcessedCount[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Names in ProdProcessedCount 
// The name is used to literally describe the product ID. An example parameter name may be 
// PRODUCT A, ABC PRODUCT, etc. This also could be displayed on HMI screens. The array 
// is typically needed for machines that have quality reporting or PDA (Production Data 
// Acquisition) needs. 

// 7.5.3.11.3 Admin.ProdProcessedCount[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Units in ProdProcessedCount 
// The unit tag is used to describe the names associated with a specific product used by the 
// machine. An example process unit of measure name may be FT, CNT, KG, etc. This also 
// could be displayed on HMI screens. 

// 7.5.3.11.4 Admin.ProdProcessedCount[#].Count 

// Data Type: Int(32bit) 
// Tag Descriptor: Structured Array of Values 
// The count value is used as a variable for displaying information about the amount of 
// processed product. The value is indexed upon the machine processing a unit of the product 
// defined by the ID and NAME. This could be displayed on HMI screens or higher level PDA 
// systems. The counter rolls over to 0 at 2,147,483,648. 

// 7.5.3.11.5 Admin.ProdProcessedCount[#].AccCount 

// Data Type: Int(32bit) 
// Tag Descriptor: Structured Array of Values 
// The accumulative count value is used as a variable for displaying information about the 
// amount of processed product. The value is indexed upon the machine processing a unit of 
// the product defined by the ID and NAME. This could be displayed on HMI screens or higher 
// level PDA systems. This counter gives the user a non-resetting counter that may be used for 
// OEE calculations. The counter rolls over to 0 at 2,147,483,648. 
// An example of the production processed counter is the following: 
// Admin.ProdProcessedCount[1].ID = 546732 
// Admin.ProdProcessedCount[1].Name = XYZ Product 
// Admin.ProdProcessedCount[1].Units = CNT 
// Admin.ProdProcessedCount[1].Count = 2305 
// Admin.ProdProcessedCount[1].AccCount = 2305 
// This describes the number of processed products the machine has made for product XYZ, 
// i.e., 2305 products were processed by the machine. 

// 7.5.3.12 Admin.ProdDefectiveCount[#] 

// Data Type: Array of Data Type ProdCount 
// This tag represents the product that is marked as defective in the production machine, to be 
// used if applicable. An example of tag usage would be the number of products rejected or 
// products that are termed defective. This tag can be used locally or remotely if needed. The 
// extent of the array is typically limited to the number of products needed to be counted as 
// defective. When this tag is used with Admin.ProdProcessedCount[#], the number of good 
// products/well formed cycles made by the machine can be calculated. The array index of # = 0 
// can be reserved for the total cumulative rejected units from the primary production stream. 

// 7.5.3.12.1 Admin.ProdDefectiveCount[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of ProdDefectiveCount 
// This is the arbitrary (user defined) ID value of the defective production material. This is nondescript value that can be used for any user tag requirements. The ID value can be SKU or a 
// user specific material identifier. 

// 7.5.3.12.2 Admin.ProdDefectiveCount[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Names in ProdDefectiveCount 
// The name is used to literally describe the product ID, and its associated material. An example 
// parameter name may be PRODUCT A, XYZ PRODUCT, etc. This also could be displayed on 
// HMI screens. The array is typically needed for machines that have quality reporting or PDA 
// (Production Data Acquisition) needs. 

// 7.5.3.12.3 Admin.ProdDefectiveCount[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Units in ProdDefectiveCount 
// The unit tag is used to describe the names associated with a specific product processed by 
// the machine. An example process unit of measure name may be FT, CNT, KG, etc. This also 
// could be displayed on HMI screens. The array is typically used for unit machines that run 
// multiple products. 

// 7.5.3.12.4 Admin.ProdDefectiveCount[#].Count 

// Data Type: Int(32bit) 
// Tag Descriptor: Structured Array of Values 
// The count value is used as a variable for displaying information about the amount of defective 
// product. The value is indexed upon the machine using a unit of the material defined by the ID 
// and NAME. This could be displayed on HMI screens or higher level PDA systems. The 
// counter rolls over to 0 at 2,147,483,648. 

// 7.5.3.12.5 Admin.ProdDefectiveCount[#].AccCount 

// Data Type: Int(32bit) 
// Tag Descriptor: Structured Array of Values 
// The accumulative count value is used as a variable for displaying information about the 
// amount of defective product. The value is indexed upon the machine using a unit of the 
// material defined by the ID and NAME. This could be displayed on HMI screens or higher level 
// PDA systems. This counter gives the user a non-resetting counter that may be used for OEE 
// calculations. The counter rolls over to 0 at 2,147,483,648. 
// An example of the production defective counter is the following: 
// Admin.ProdDefectiveCount[1].ID = 546732 
// Admin.ProdDefectiveCount[1].Name = XYZ Product 
// Admin.ProdDefectiveCount[1].Units = CNT 
// Admin.ProdDefectiveCount[1].Count = 1005 
// Admin.ProdDefectiveCount[1].AccCount = 3001 
// This describes defective products made by the machine (i.e., 1005 defective products made 
// since the last reset of count and 3001 defective products since the last reset of AccCount). 

// 7.5.3.13 Admin.AccTimeSinceReset 

// Data Type: Int(32bit) 
// Unit of Measure: Secs 
// Tag Descriptor: Accumulative Time Since Last Reset 
// The tag represents the amount of time since the reset has been triggered. When a reset is 
// triggered all resettable tags are reset which can include: 
// UnitName.Admin.ModeCurrentTime[#] 
// UnitName.Admin.ModeCumulativeTime[#] 
// UnitName.Admin.StateCurrentTime[#,#] 
// UnitName.Admin.StateCumulativeTime[#,#] 
// UnitName.Admin.ProdConsumedCount[#].Count 
// UnitName.Admin.ProdProcessedCount[#].Count 
// UnitName.Admin.ProdDefectiveCount[#].Count 
// UnitName.Admin.AccTimeSinceReset. 
// This value rolls over at 2,147,483,648 to 0. The tag can be used for simple OEE calculations 
// as the definition of “scheduled production time”. The simple OEE calculation is the total 
// amount of good products divided by the total amount of good products that can be produced 
// with the unit time, with the unit of time being scheduled production time. 

// 7.5.3.14 Admin.MachDesignSpeed 

// Data Type: Real 
// Unit of Measure: Primary Packages/minute 
// Tag Descriptor: Machine Design Speed 
// This tag represents the maximum design speed of the machine in primary packages per 
// minute for the package configuration being run. This speed is NOT the maximum speed as 
// specified by the manufacturer, but rather the speed the machine is designed to run in its 
// installed environment. 
// NOTE: In practice the maximum speed of the machine as used for efficiency calculations will be a function of how 
// it is set up and what products it is producing. 

// 7.5.3.15 Admin.PACDateTime 

// Data Type: TimeStamp 
// This tag defines the structure of date and time of the Programmable Automation Controller 
// (PAC). The tag can be used to synchronize the clock with the PAC to the higher level 
// systems used for OEE calculations. 

// 7.5.3.15.1 Admin.PACDateTime.Date 

// Data Type: Date 
// Tag Descriptor: ISO Date Data Type 
// Defines the date within the PAC in ISO 8601:1988 format (defines as seconds from January 1, 
// 1970 at 12:00am). 

// 7.5.3.15.2 Admin.PACDateTime.Time 

// Data Type: Time 
// Tag Descriptor: ISO Time Data Type 
// Defines the time within the PAC in ISO 8601:1988 format (defines as seconds from January 1, 
// 1970 at 12:00am). 