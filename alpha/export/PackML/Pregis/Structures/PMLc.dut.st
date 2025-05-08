(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE PMLc :
STRUCT
	UnitMode : INT;
	UnitModeChangeRequest : BOOL;
	MachSpeed : REAL;
	MaterialInterlocks : DWORD;
	CntrlCmd : INT;
	CMDChangeRequest : BOOL;
	RemoteInterface : ARRAY[0..Packml_Variable_Config.maxInterfaces] OF InterfacePackML;
	Parameter : ARRAY [0..Packml_Variable_Config.maxParameters] OF Descriptor;
	Product : ARRAY[0..Packml_Variable_Config.maxProducts] OF Product;
END_STRUCT
END_TYPE
//
// 7.5.1 Command Tags 

// Command tags are used to control the operation of the unit machine. Command tags include 
// unit state commands which control the state transitions in the Base State Model. The 
// command tags also include parameters and process variables which control how the machine 
// operates. Command tags generally originate from the machine user or a remote system. The 
// originator of the command in this report is defined as the “requestor” or “information sender.” 
// The unit machine in this report is known as the “execution system”. 

// 7.5.1.1 Command.UnitMode 

// Data Type: INT (32bit) 
// Tag Descriptor: Unit Mode Target 
// This value is predefined by the user/OEM, and are the desired unit modes of the machine. 
// The UnitMode tag is a numerical representation of the commanded mode. There can be any 
// number of unit modes, and for each unit mode there is an accompanying state model. 

// EXAMPLE: Unit modes are Production, Maintenance, Manual, Clean Out, Dry Run, Setup, etc. 
// 0 Undefined 
// 1 Producing 
// 2 Maintenance 
// 3 Manual 
// 4 <future reserve> 
// 5 <future reserve> 
// 6 <future reserve> 
// 7 <future reserve> 
// 8 <future reserve> 
// 9 <future reserve> 
// 10 <future reserve> 
// 11 <future reserve> 
// 12 <future reserve> 
// 13 <future reserve> 
// 14 <future reserve> 
// 15 <future reserve> 
// 16 User Defined 1 
// 17 User Defined 2 
// N User Defined n 


// 7.5.1.2 Command.UnitModeChangeRequest 

// Data Type: Bool 
// Tag Descriptor: Request Unit Mode Change 
// When a unit mode request takes place a numerical value must be present in the 
// Command.UnitMode tag to change the unit mode. Local processing and conditioning of the 
// requested mode change is necessary in order to accept, reject, or condition the timing of the 
// change request. 

// 7.5.1.3 Command.MachSpeed 
// Data Type: REAL 
// Unit of Measure: Primary packages/minute 
// Tag Descriptor: Current Machine Speed 
// This defines the set point for the current speed of the machine in primary packages per 
// minute. Keeping speed in a primary package unit of measure (UOM) allows for easier control 
// integration. The primary package UOM is the normalized rate for the machine, normalized to 
// a value chosen on the line. 

//The following example is for a bottle line running at balance line 
// speed of 1000 packages/minute. The UOM chosen is equivalent to be the actual count of the 
// Filler or Labeler. 
// Machine Actual Pack Counts Primary packages 
// (UOM) 
// Bulk Depalletizer 41.6666 (24 pack equiv) 1,000 
// Filler 1,000 1,000 
// Labeler 1,000 1,000 
// Packer 66.666 (15 packs) 1,000 


// 7.5.1.4 Command.MaterialInterlocks 
// Data Type: Structure of 32 bits in length 
// Tag Descriptor: Materials Ready 
// Indicates materials are ready for processing. It is comprised of a series of bits with 1 
// equaling ready or not low, 0 equaling not ready, or low. Each bit represents a different user 
// material. Materials are defined as all consumables such as product, cartons, labels, utilities, 
// and glue. The word contains bits that indicate when a critical material or process parameter 
// is ready for use; it can also be used for production, and/or indication of low condition. This 
// information may be sent to the unit machine at any time as the interlock information changes. 

// MATERIAL INTERLOCKS EXAMPLE
//  Raw Material #1 – Not Low 
// Raw Material #1 - Ready 
// Air Pressure - Ready 
// Compressed Air - Ready 
// Lubrication Water - Ready 
// Container Caps – Not Low 
// Container Caps – Ready 
// Undefined / Unused 
// Undefined / Unused 
// Undefined / Unused 
// MaterialInterlocks.bit# 1 1 1 1 1 1 1 1 1 1 
// Bit # 0 1 2 3 4 5 6 .. 30 31 


// 7.5.1.5 Command.CntrlCmd 
// Data Type: INT (32bit) 
// Tag Descriptor: Control Command 
// The tag holds the value of the command that provides the state command to drive a state 
// change in the Base State Model; this tag is typically manipulated locally. Local processing of 
// this tag can be combined with remote or local machine conditions to drive the state model 
// from Wait state to a Transient state. This tag can be set by a local or remote source. All 
// values in the table below are reserved. 
// 0 Undefined 
// 1 Reset 
// 2 Start 
// 3 Stop 
// 4 Hold 
// 5 Unhold 
// 6 Suspend 
// 7 Unsuspend 
// 8 Abort 
// 9 Clear 

// 7.5.1.6 Command.CmdChangeRequest 

// Data Type: Bool 
// Tag Descriptor: State Change Request 
// This CmdChangeRequest bit will command the machine to proceed to change the state to the 
// target state. The tag can be used to condition when a change of state can occur. The target 
// state will be one of the states in the base state model. 

// 7.5.1.7 Command.RemoteInterface[#] 

// Data Type: Structured Array of DataType Interface 
// Tag Descriptor: Upstream or Downstream Machine 
// This structured array is use for coordinating upstream or downstream machines in a cell of 
// multiple unit machines. The array is chosen to be of a length that is equal to the number of 
// machines that will be sending commands. This could be expanded if a machine is capable of 
// receiving material from multiple upstream and / or downstream machines, thereby receiving 
// multiple commands and parameters. This can be used for machine to machine coordination 
// without supervisory control, or for tightly controlled units under supervisory control. These 
// tags are typically used for consumption within the unit machine procedure. Specifically, if a 
// remote controller was issuing commands the commands would be read by this tag and used 
// in the unit machine. 

// 7.5.1.7.1 Command.RemoteInterface[#].Number 

// Data Type: INT (32bit) 
// Tag Descriptor: Identification Number of Upstream or Downstream Unit Machine 
// This is the unique number for the downstream/upstream unit machine using a common tag 
// structure as the unit machine. The number should correspond to a number on the 
// communication network, such network ID, or IP address identifier. This number corresponds 
// to the “Information Sender” that is setting the command data in the RemoteInterface[#] 
// structure of the unit machine. 

// 7.5.1.7.2 Command.RemoteInterface[#].ControlCmdNumber 

// Data Type: INT (32bit) 
// Tag Descriptor : Control Command for Upstream or Downstream Machine 
// A user defined command number associated with coded value from a remote unit. This 
// number is a coded value sent from one node on the network to another. The value can be 
// associated with a unit mode change request, speed change request, a state change request, 
// etc. 

// 7.5.1.7.3 Command.RemoteInterface[#].CmdValue 

// Data Type: INT (32bit) 
// Tag Descriptor: Control Command Value Associated ControlCmdNumber 
// This is the command value associated with the ControlCmdNumber above. The command 
// value may be the speed requested, state change, etc. 

// EXAMPLE: 
// For an upstream machine designated as #2 a control command number of 5 may be related to the speed setting 
// value for the machine. A value of 400 can be used to modify the remote machine setpoint. 
// Command.RemoteInterface[1].Number = 2 
// Command.RemoteInterface[1].ControlCmdNumber = 5 
// Command.RemoteInterface[1].CmdValue = 400 
// For a downstream machine designated as #4 the control command number of 0 can be used to remotely command 
// a state transition for the machine. The value of 2 is the command value for start. 
// Command.RemoteInterface[1].Number = 4 
// Command.RemoteInterface[1].ControlCmdNumber = 0 
// Command.RemoteInterface[1].CmdValue = 2 

// 7.5.1.7.4 Command.RemoteInterface[#].Parameter[#] 

// Data Type: Structured Array of Data Type Descriptor 
// The Parameter tags associated to Commanded Remote Interface are typically used for 
// command parameters that are given to the unit machine from remote machines. The 
// parameters are typically needed for coordinating the unit machine or production with other 
// machines. The parameter value may be anything from machine limit parameters to 
// temperatures and counter presets. The parameters are typically limited to machine 
// parameters as product and process parameters are describe in later tags. 

// 7.5.1.7.4.1 Command. RemoteInterface[#].Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) ID value assigned to the parameter. This is non-descript 
// value that can be used for user tag requirements. 

// 7.5.1.7.4.2 Command.RemoteInterface[#].Parameter[#].Name 

// Data Type: String 
// Tag Descriptor: String value assigned to Parameter 
// The literal parameter name is used to describe the parameter variable number, and its 
// associated value from the remote interface. An example parameter name may be GLUE 
// TEMP, BEARING TEMP, OVERLOAD TIME, etc. 

// 7.5.1.7.4.3 Command.RemoteInterface[#].Parameter[#].Unit 

// Data Type: String[5] 
// Tag Descriptor:String value of Parameter unit of measure 
// Unit is a string that describes the unit of measure associated with the parameter’s value (i.e., 
// secs, deg, rpm, ppm, etc). This tag describes the unit of measure associated with the 
// following tag value sent from the remote interface. 

// 7.5.1.7.4.4 Command.RemoteInterface[#].Parameter[#].Value 

// Data Type: REAL 
// Tag Descriptor: Numeric Value of Parameter 
// This is the numeric value of the parameter. The value is described by the Parameter[#].ID, 
// Parameter[#].Name, and is of unit of measure is described by the Parameter[#].Unit sent by 
// the remote interface as a command to the unit machine. 

// 7.5.1.8 Command.Parameter[#] 

// Data Type: Array of Data Type Descriptor 
// The Parameter tags associated to the local Interface and are typically used for command 
// parameters that are given to the unit locally, for example from an HMI. The parameters are 
// typically needed for running the unit machine. The parameter value may be anything from 
// machine limit parameters to temperatures and counter presets. The parameters are typically 
// limited to machine parameters as product and process parameters are describe in later tags. 

// 7.5.1.8.1 Command.Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID value of Parameter 
// This is the arbitrary (user defined) ID value of the parameter. This is non-descript value that 
// can be used for any user tag requirements. 

// 7.5.1.8.2 Command.Parameter[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured array of Parameter names for the machine unit. 
// The literal parameter name is used to describe the parameter number, and its associated 
// value. An example parameter name may be GLUE TEMP, BEARING TEMP, OVERLOAD 
// TIME, etc. 

// 7.5.1.8.3 Command.Parameter[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Parameter Unit of Measure for the Machine Unit 
// The parameter unit is used to describe the unit of measure of the parameter, and its 
// associated value. An example parameter unit of measure may be DegF, secs, PPM, revs, 
// mm, etc. 

// 7.5.1.8.4 Command.Parameter[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured Array of Parameter Values 
// This is the numeric value of the parameter. The value is described by the Parameter[#].ID, 
// Parameter[#].Name, and is a unit of measure described by the Parameter[#].Unit commanded 
// by the local interface, or local processor, as a command to the unit machine. 


// EXAMPLE: 
// Command.Parameter[1].Value = 22.5 
// Command.Parameter[2].Value = 12 

// EXAMPLE: Machine Unit Process Variable 
// Command.Parameter[1].Name = BEARING_1_OVERTEMP 
// Command.Parameter[1].Unit = DegC 
// Command.Parameter[1].Value = 350.00 
// This defines the temperature of a Bearing Overtemp alarm of the #1 bearing is to be set at 
// 350.0 Degrees C for all products. 


// 7.5.1.9 Command.Product[#] 

// Data Type: Array of Data Type Product 
// The Product data type can be used for defining product and product processing parameter 
// variables. The command tags can come from either a local HMI or remote systems and are 
// used to process the product on the unit machine. The array is typically needed for machines 
// that run multiple products. 

// 7.5.1.9.1 Command.Product[#].ProductID 

// Data Type: INT (32bit) 
// Tag Descriptor: Structured Array of Product ID# 
// This Product ID is used to indicate to the machine which product it is producing (i.e., SKU or 
// UPC). The array can be used for machines that run multiple products. 

// 7.5.1.9.2 Command.Product[#].ProcessVariables[#] 

// Data Type: Array of Data Type Descriptor 
// The Process Variables structured array can be used for specific process variables needed by 
// the unit machine for the processing of a specific product. Process variables include set 
// points, limits, quality parameters, etc, that are needed to produce a particular product on a 
// unit machine. The number of tags for this array will be the maximum number of needed 
// process variables for any particular product defined on the unit machine. 

// 7.5.1.9.2.1 Command.Product[#].ProcessVariables[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) process variable ID value assigned to the process variable. 

// 7.5.1.9.2.2 Command.Product[#].ProcessVariables[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Process Variable Names for Multiple Product ID#s 
// The process variable literal name is used to describe the process variable number, and its 
// associated value. An example process variable name may be GLUE TEMP, 
// MaxTimeInMachine, MixingTime, KnifeSpeed, ChillRollPhaseOffset, etc. 

// 7.5.1.9.2.3 Command.Product[#].ProcessVariables[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Process Variable Unit of Measure 
// The process variable unit of measure is a string data type used to describe the unit of 
// measure of the process variable number, and its associated value. An example process unit 
// of measure may be DegF, secs, PPM, revs, mm, etc. . 

// 7.5.1.9.2.4 Command.Product[#].ProcessVariables[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured Array of Process Variable Values 
// The process variable value is used to specify a process variable for the Product[#] specified 
// by the ProcessVariable[#].ID, ProcessVariables[#].Name, and ProcessVariables[#].Unit. 
// Command.Product[1].ProcessVariables[1].Value = 22.5 
// Command.Product[1].ProcessVariables[2].Value = 12 
// Combined with other examples of Product[#] 
// Command.Product[1].ProcessVariables[1].Name = Glue1Temp 
// Command.Product[1].ProcessVariables[1].Unit = DegF 
// Command.Product[1].ProcessVariables[1].Value = 356.4 
// Meaning the temperature of at Glue station 1 is to be controlled at 356.4 Degrees F for 
// product number 1. 
// Other Examples of Process Variable Name for Products: 
// Name = ProductMaxTimeInMachine 
// Name = ProductMinTimeInMachine 
// Name = ByproductID 
// Name = ByproductsMaxTimeInMachine 

// 7.5.1.9.3 Command.Product[#].Ingredients[#] 

// Data Type: Array of Data Type Ingredient 
// This array serves to hold the information needed for the raw materials that are used by the 
// unit machine in the processing of a particular product. The extent of this array will be the 
// maximum number of ingredients used in the processing of any particular product. 

// 7.5.1.9.3.1 Command.Product[#].Ingredients[#].IngredientID 

// Data Type: INT (32bit) 
// Tag Descriptor: Structured Array of Ingredient IDs 
// The Ingredient ID is an arbitrary number associated with the raw material, or ingredient for a 
// particular product number. The user will define the value associated to the ingredient IDs that 
// are used in the operation of the machine for a particular product. Each ingredient should have 
// a distinct ID (SKU or UPC). 

// 7.5.1.9.3.2 Command.Product[#].Ingredients[#].Parameter[#] 

// Data Type: Array of Data Type Descriptor 
// This array or structures is used for parameters associated with a particular ingredient or raw 
// material used the processing of a particular product number. This command tag is typically 
// set by a “Information Sender” to the unit machine controller. The extent of this array is the 
// maximum number of parameters associated with any ingredient in any product that is defined 
// on the unit machine. 

// 7.5.1.9.3.2.1 Command.Product[#].Ingredients[#].Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) ID value assigned to one of the parameters for the 
// ingredient or raw material, needed for the processing of the product defined by the product 
// number. 
//  
// 7.5.1.9.3.2.2 Command.Product[#].Ingredients[#].Parameter[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Ingredient Parameter Names 
// The parameter variable name in the parameter array is used to describe the parameter names 
// associated with a specific ingredient number in a specific product number. An example 
// parameter name may be SETUP TIME, TEMP, TAB POSITION etc. The array is typically 
// needed for machines that run multiple ingredients with multiple parameters with multiple 
// products. 

// 7.5.1.9.3.2.3 Command.Product[#].Ingredients[#].Parameter[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Unit of Measure 
// The parameter unit tag is used to describe the parameter names associated with a specific 
// parameter in an specific ingredient in a specific product. An example unit of measure name 
// may be DegF, secs, PPM, revs, mm, etc. The array is typically needed for unit machines that 
// run multiple products with multiple ingredients with multiple processing parameters. 

// 7.5.1.9.3.2.4 Command.Product[#].Ingredients[#].Parameter[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured Array of Values 
// The ingredient parameter value is used to specify a parameter variable for the control of the 
// process. The array is typically needed for unit machines that run multiple products with 
// multiple ingredients with multiple processing parameters. As an example with Ingredient 
// number 1 in Product number 1: 
// Command.Product[1].Ingredients[1].Parameter[1].Value = 225 
// Command.Product[1].Ingredients[1].Parameter[2].Value = 12 
// Combined with other examples of Product[#] 
// Command.Product[1].Ingredients[1].Parameter[1].Name = KNIFE_OFFSET 
// Command.Product[1].Ingredients[1].Parameter[1].Unit = degrees 
// Command.Product[1].Ingredients[1].Parameter[1].Value = 3.564 
// Meaning the offset of the knife is to be controlled at 3.564 Degrees for Parameter variable 
// number 1, on ingredient 1 for product number 1. 
