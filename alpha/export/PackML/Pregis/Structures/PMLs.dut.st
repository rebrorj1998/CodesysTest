(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE PMLs :
STRUCT
	UnitModeCurrent : INT;
	UnitModeRequested : BOOL;
	UnitModeChangeInProcess : BOOL;
	StateCurrent : INT; 
	StateRequested : INT;
	StateChangeInProcess : BOOL; 
	MachSpeed : REAL;
	CurMachSpeed : REAL;
	MaterialInterlocks : DWORD;
	RemoteInterface : ARRAY[0..Packml_Variable_Config.maxInterfaces] OF InterfacePackML;
	Parameter : ARRAY [0..Packml_Variable_Config.maxParameters] OF Descriptor;
	Product : ARRAY[0..Packml_Variable_Config.maxProducts] OF Product;
END_STRUCT
END_TYPE

// 7.5.2 Status Tags 
// Status tags are used to describe the operation of the unit machine. Status tags include state 
// commands which describe the state transitions in the Base State Model. The status tags also 
// include parameters and process variables which describe how the machine operates. Status 
// tags generally originate from the unit machine user and can be used on the HMI or a remote 
// system. The originator of the status tags in this report is defined as the “Execution system”. 

// 7.5.2.1 Status.UnitModeCurrent 

// Data Type: INT (32bit) 
// Tag Descriptor: Unit Mode in Current Use 
// This value is predefined by the user/OEM of the available unit modes of the machine allowing 
// a possible different set of states for the Base State Model and could provide completely 
// different functionality in the same machinery such as Cleanout, Producing, etc. 
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

// 7.5.2.2 Status.UnitModeRequested 

// Data Type: Bool 
// Tag Descriptor: Requested Unit Mode Change 
// When a unit mode request takes place a numerical value must be present in the unit mode 
// target to change the unit mode. Local processing and conditioning of the requested mode 
// change is necessary in order to accept, reject, or condition the timing of the change request. 

// 7.5.2.3 Status.UnitModeChangeInProcess 

// Data Type: Bool 
// Tag Descriptor: Requested Unit Mode Change in Process 
// When a unit mode request takes place, this tag reflects the status of the state model. If the 
// state of the machine required time to change mode this bit would track the request and reset 
// when the change was completed. 
// Figure 7: Unit Mode Change Example Sequence 

// 7.5.2.4 Status.StateCurrent 

// Data Type: INT (32bit) 
// Tag Descriptor: Current State Number 
// The StateCurrent status tag specifies the current state in the current unit mode of the unit 
// machine. The numerical values are in the table below are reserved. 
// 0 Undefined 
// 1 “Clearing” 
// 2 “Stopped” 
// 3 “Starting” 
// 4 “Idle” 
// 5 “Suspended” 
// 6 “Execute” 
// 7 “Stopping” 
// 8 “Aborting” 
// 9 “Aborted” 
// 10 “Holding” 
// 11 “Held” 
// 12 “UnHolding” 
// 13 “Suspending” 
// 14 “Unsuspending” 
// 15 “Resetting” 
// 16 “Completing” 
// 17 “Complete” 

// 7.5.2.5 Status.StateRequested 

// Data Type: INT (32bit) 
// Tag Descriptor: Target State. 
// This value is used for state transition checking to ensure that a target state can be 
// transitioned to. The target state, StateRequesed, is a numerical value corresponding to a 
// state in the Base State Model (shown above). 

// 7.5.2.6 Status.StateChangeInProcess 
// Data Type: Bool 
// Tag Descriptor: State Change in Process. 
// This bit indicates that a change in state is in progress following a state change request 
// command. 
// Figure 8: State Change Example Sequence 

// 7.5.2.7 Status.MachSpeed 

// Data Type: REAL 
// Units: Primary packages/minute 
// Tag Descriptor: Current Machine Speed 
// This describes the set point for the current speed of the machine in primary packages per 
// minute. Keeping speed in a primary package unit of measure (UOM) allows for easier control 
// integration. The primary package UOM is the normalized rate for the machine, normalized to 
// a value chosen on the line. The following example is for a bottle line running at balance line 
// speed of 1000 packages/minute. The UOM chosen is equivalent to be the actual count of the 
// Filler, or Labeler. 
// Machine Actual Pack Counts Primary packages 
// (UOM) 
// Bulk Depalletizer 41.6666 (24 pack equiv) 1,000 
// Filler 1,000 1,000 
// Labeler 1,000 1,000 
// Packer 66.666 (15 packs) 1,000 

// 7.5.2.8 Status.CurMachSpeed 

// Data Type: Real 
// Tag Descriptor: Current Machine Speed in Primary Packages/Minute 
// This the actual value of the machine speed. Keeping units in primary package unit of measure 
// (UOM), allows for easier control integration. The primary package UOM is the normalized 
// rate for the machine, normalized to a value chosen on the line. Pack counts are parameters 
// stored in the Administration tags or downloaded parameters stored in Command tags 
// parameters. 

// 7.5.2.9 Status.MaterialInterlocks 

// Data Type: Structure of 32 bits in length 
// Tag Descriptor: Materials Ready 
// MaterialInterlocks describes the status of the materials that are ready for processing. It is 
// comprised of a series of bits with 1 equaling ready or not low, 0 equaling not ready, or low. 
// Each bit represents a different user material. Materials are defined as all consumables such 
// as product, cartons, labels, utilities, and glue. The word contains bits that indicate when a 
// critical material or process parameter is ready for use, it can also be used for production, 
// and/or indication of low condition. This information is set by the by the unit machine at any 
// time as the interlock information changes. 
// MATERIALINTERLOCKS 
// EXAMPLE
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

// 7.5.2.10 Status.RemoteInterface[#] 

// Data Type: Structured Array of DataType Interface 
// Tag Descriptor: Upstream or Downstream Machine 
// This structured array is used for coordinating upstream or downstream machines in a cell of 
// multiple unit machines. The array is chosen to be of a length that is equal to the number of 
// machines that will be receiving commands. This could be expanded if a machine is capable 
// of receiving material from multiple upstream and/or downstream machines, thereby sending 
// multiple commands and parameters. This can be used for machine to machine coordination 
// without supervisory control, or for tightly controlled units under supervisory control. These 
// tags are typically used for consumption outside the unit machine procedure. Specifically, if 
// the local controller was sending status information the tags would be read by remote systems. 

// 7.5.2.10.1 Status.RemoteInterface[#].Number 

// Data Type: INT (32bit) 
// Tag Descriptor: Identification Number of Upstream or Downstream Machine 
// This is the unique number for the downstream/upstream unit machine using a common tag 
// structure as the unit machine. The number should correspond to a number on the 
// communication network, such network ID, or IP address identifier. This number corresponds 
// to the “Information Receiver” that is receiving the status data. 

// 7.5.2.10.2 Status.RemoteInterface[#].ControlCmdNumber 

// Data Type: INT (32bit) 
// Tag Descriptor: Control Command for Upstream or Downstream Machine 
// A user defined command number associated with coded value to a remote unit. This number 
// is a coded value sent from one node on the network to another. The value can be associated 
// with a unit mode change request, speed change request, a state change request, etc. 

// 7.5.2.10.3 Status.RemoteInterface[#].CmdValue 

// Data Type: INT (32bit) 
// Tag Descriptor: Control Command Value Associated ControlCmdNumber 
// This is the status value associated with the ControlCmdNumber above. The status value may 
// be the speed requested, state change, etc. 
// EXAMPLE: 
// For an upstream machine designated as #2 a control command number of 5 may be related to a speed setting 
// value from machine #2. A value of 400 can be used to modify the current machine setpoint. 
// Status.RemoteInterface[1].Number = 2 
// Status.RemoteInterface[1].ControlCmdNumber = 5 
// Status.RemoteInterface[1].CmdValue = 400 
// For a downstream machine designated as #4 the control command number of 0 can be used to read the command 
// of a state transition from machine #4. The value of 2 is the command value for start. 
// Status.RemoteInterface[1].Number = 4 
// Status.RemoteInterface[1].ControlCmdNumber = 0 
// Status.RemoteInterface[1].CmdValue = 2 

// 7.5.2.10.4 Status.RemoteInterface[#].Parameter[#] 

// Data Type: Structured Array of Data Type Descriptor 
// The status Parameter tags are associated with the Remote Interface and are typically used 
// for parameters that are sent to the remote machine(s) from the unit machine. The parameters 
// are typically needed for coordinating the unit with other machines. The parameter value may 
// be anything from machine limit parameters to temperatures and counter presets. The 
// parameters are typically limited to machine parameters as product and process parameters 
// are describe in later tags. 

// 7.5.2.10.4.1 Status.RemoteInterface[#].Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) ID value assigned to the parameter. This is non-descript 
// value that can be used for user tag requirements. 

// 7.5.2.10.4.2 Status.RemoteInterface[#].Parameter[#].Name 

// Data Type: String 
// Tag Descriptor: String Value Assigned to Parameter 
// The literal parameter name is used to describe the parameter variable number, and its 
// associated value from the unit machine. An example parameter name may be GLUE TEMP, 
// BEARING TEMP, OVERLOAD TIME, etc. This is also could be displayed on HMI screens. 

// 7.5.2.10.4.3 Status.RemoteInterface[#].Parameter[#].Unit 

// Data Type: String[5] 
// Tag Descriptor: String Value of Parameter Unit of Measure 
// Unit is a string that describes the unit of measure associated with the parameter’s value (i.e., 
// secs, deg, rpm, ppm, etc.). This tag describes the unit of measure associated with the 
// following tag value that is sent from the unit machine. 

// 7.5.2.10.4.4 Status.RemoteInterface[#].Parameter[#].Value 

// Data Type: REAL 
// Tag Descriptor: Numeric Value of Parameter 
// This is the numeric value of the parameter. The value is described by the Parameter[#].ID, 
// Parameter[#].Name, and is of unit of measure that is parameterized by the Parameter[#].Unit. 
// The value can be sent by the unit machine as information to a remote machine. 

// 7.5.2.11 Status.Parameter[#] 

// Data Type: Array of Data Type Descriptor 
// The Parameter tags are associated with the local Interface and are typically used for 
// parameters that are displayed or used on the unit locally, for example an HMI. These 
// parameters can be a reflection of the command parameter tags or used to display any 
// machine parameter. The parameters are typically needed for running the unit machine. The 
// parameter value may be anything from machine limit parameters to temperatures and counter 
// presets. The parameters are typically limited to machine parameters, as product and process 
// parameters are described in later tags. The extent of the array is dependent on the number of 
// parameters needed. 

// 7.5.2.11.1 Status.Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) ID value of the parameter. This is non-descript value that 
// can be used for any user tag requirements. 

// 7.5.2.11.2 Status.Parameter[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Parameter Variable Names for the Machine Unit 
// The literal parameter name is used to describe the parameter number, and its associated 
// value. An example parameter name may be GLUE TEMP, BEARING TEMP, OVERLOAD 
// TIME, etc. This is also could be displayed on HMI screens. 

// 7.5.2.11.3 Status.Parameter#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Parameter Unit of Measure for the Machine Unit 
// The parameter unit is used to describe the unit of measure of the parameter, and its 
// associated value. An example parameter unit of measure may be DegF, secs, PPM, revs, 
// mm, etc. This also could be displayed on HMI screens. 

// 7.5.2.11.4 Status.Parameter[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured Array of Parameter Values 
// This is the numeric value of the parameter. The value is described by the Parameter[#].ID, 
// Parameter[#].Name, and is a unit of measure described by the Parameter[#].Unit on the local 
// machine. An example is the following: 
// Status.Parameter[1].Value = 22.5 
// Status.Parameter[2].Value = 12 
// An example of a machine unit process variable: 
// Status.Parameter[1].Name = BEARING_1_OVERTEMP 
// Status.Parameter[1].Unit = DegC 
// Status.Parameter[1].Value = 350.00 
// This defines the temperature of a Bearing Overtemp alarm of the #1 bearing is to be set at 
// 350.0 Degrees C for all products. 

// 7.5.2.12 Status.Product[#] 

// Data Type: Array of Data Type Product 
// The Product data type can be used for displaying product and product processing parameter 
// variables. The status tags can come from either a local HMI or remote systems, and are used 
// to display or send information on the product(s) on the unit machine. The array is typically 
// needed for machines that run multiple products. 

// 7.5.2.12.1 Status.Product[#].ProductID 

// Data Type: INT (32bit) 
// Tag Descriptor: Structured Array of Product ID# 
// This Product ID is used to indicate to the machine which product it is producing (i.e., SKU or 
// UPC). This can also be displayed on all HMI screens. The array can be used for machines 
// that run multiple products. 

// 7.5.2.12.2 Status.Product[#].ProcessVariables[#] 

// Data Type: Array of Data Type Descriptor 
// The ProcessVaribles structured array can be used to display specific process variables used 
// by the unit machine for the processing of a specific product. Process variables include set 
// points, limits, quality parameters, etc., that are displayed to produce a particular product on a 
// unit machine. The number of tags for this array will be the maximum number of needed 
// process variables for any particular product defined on the unit machine. 

// 7.5.2.12.3 Status.Product[#].ProcessVariables[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) process variable ID value assigned to the process variable. 

// 7.5.2.12.4 Status.Product[#].ProcessVariables[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Process Variable Names for Multiple Product ID#s 
// The process variable literal name is used to describe the process variable number, and its 
// associated value. An example process variable name may be GLUE TEMP, 
// MaxTimeInMachine, MixingTime, KnifeSpeed, ChillRollPhaseOffset, etc. This also could be 
// displayed on HMI screens. 

// 7.5.2.12.5 Status.Product[#].ProcessVariables[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Process Variable Unit of Measure for Multiple Product 
// ID#s 
// The process variable unit is used to describe the units of the process variable number, and its 
// associated value. An example process unit name may be DegF, secs, PPM, revs, mm, etc. 
// This also could be displayed on HMI screens. The array is typically needed for machines that 
// run multiple products. 

// 7.5.2.12.6 Status.Product[#].ProcessVariables[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured array of Process Variable values 
// The process variable value is used to specify a process variable for the Product[#] specified 
// by the ProcessVariable[#].ID, ProcessVariables[#].Name, and ProcessVariables[#].Unit. This 
// also could be displayed on HMI screens. 
// Status.Product[1].ProcessVariables[1].Value = 22.5 
// Status.Product[1].ProcessVariables[2].Value = 12 
// Combined with other examples of Product[#] 
// Status.Product[1].ProcessVariables[1].Name = Glue1Temp 
// Status.Product[1].ProcessVariables[1].Unit = DegF 
// Status.Product[1].ProcessVariables[1].Value = 356.4 
// Meaning the temperature of at Glue station 1 is to be controlled at 356.4 Degrees F for 
// product number 1. 
// Other Examples of Process Variable Name For Products: 
// Name = ProductMaxTimeInMachine 
// Name = ProductMinTimeInMachine 
// Name = ByproductID 
// Name = ByproductsMaxTimeInMachine 

// 7.5.2.12.7 Status.Product[#].Ingredients[#] 

// Data Type: Array of Data Type Ingredient 
// This array serves to hold the information needed for the raw materials that are used by the 
// unit machine in the processing of a particular product. The extent of this array will be the 
// maximum number of ingredients used in the processing of any particular product. 

// 7.5.2.12.7.1 Status.Product[#].Ingredients[#].IngredientID 

// Data Type: INT (32bit) 
// Tag Descriptor: Structured Array of Ingredient IDs 
// The IngredientID is an arbitrary number associated with the raw material, or ingredient for a 
// particular product number. The user will define the value associated to the ingredient IDs that 
// are used in the operation of the machine for a particular product. Each ingredient should have 
// a distinct ID (SKU or UPC). 

// 7.5.2.12.7.2 Status.Product[#].Ingredients[#].Parameter[#] 

// Data Type: Array of Data Type Descriptor 
// This array of structures is used for parameters associated with a particular ingredient or raw 
// material used the processing of a particular product number. This status tag is typically set 
// by the unit machine controller. The extent of this array is the maximum number of parameters 
// associated with any ingredient in any product that is defined on the unit machine. 

// 7.5.2.12.7.2.1 Status.Product[#].Ingredients[#].Parameter[#].ID 

// Data Type: INT (32bit) 
// Tag Descriptor: ID Value of Parameter 
// This is the arbitrary (user defined) ID value assigned to one of the parameters for the 
// ingredient or raw material, needed for the processing of the product defined by the product 
// number. 
//  
// 7.5.2.12.7.2.2 Status.Product[#].Ingredients[#].Parameter[#].Name 

// Data Type: STRING 
// Tag Descriptor: Structured Array of Ingredient Parameter Names 
// The parameter variable name in the parameter array is used to describe the parameter names 
// associated with a specific ingredient number in a specific product number. An example 
// parameter name may be SETUP TIME, TEMP, TAB POSITION, etc. This also could be 
// displayed on HMI screens. The array is typically needed for machines that run multiple 
// ingredients with multiple parameters with multiple products. 

// 7.5.2.12.7.2.3 Status.Product[#].Ingredients[#].Parameter[#].Unit 

// Data Type: STRING[5] 
// Tag Descriptor: Structured Array of Unit of Measure 
// The parameter unit tag is used to describe the parameter names associated with a specific 
// parameter in a specific ingredient in a specific product. An example process unit of measure 
// name may be DegF, secs, PPM, revs, mm, etc. This also could be displayed on HMI screens. 
// The array is typically needed for unit machines that run multiple products with multiple 
// ingredients with multiple processing parameters. 

// 7.5.2.12.7.2.4 Status.Product[#].Ingredients[#].Parameter[#].Value 

// Data Type: Real 
// Tag Descriptor: Structured array of values 
// The ingredient parameter value is used to specify a parameter variable for displaying 
// information about the process. This also could be displayed on HMI screens. The array is 
// typically needed for unit machines that run multiple products with multiple ingredients with 
// multiple processing parameters. As an example with Ingredient number 1 in Product number 
// 1: 
// Status.Product[1].Ingredients[1].Parameter[1].Value = 225 
// Status.Product[1].Ingredients[1].Parameter[2].Value = 12 
// Combined with other examples of Product[#] 
// Status.Product[1].Ingredients[1].Parameter[1].Name = KNIFE_OFFSET 
// Status.Product[1].Ingredients[1].Parameter[1].Unit = degrees 
// Status.Product[1].Ingredients[1].Parameter[1].Value = 3.564 
// Meaning the offset of the knife is to be controlled at 3.564 Degrees for Parameter variable 
// number 1, on ingredient 1 for product number 1. 
