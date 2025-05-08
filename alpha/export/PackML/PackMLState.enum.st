(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE PackMLState :
(//
	STOPPED := 16#1,
//	
//State Type: Wait 
// The machine is powered and stationary after completing the 
// STOPPING state. All communications with other systems are 
// functioning (if applicable). A Reset command will cause an exit from 
// STOPPED to the RESETTING state. 
//
	STARTING := 16#8,
//	
// State TYPE: Acting
// This state provides the steps needed to start the machine and is a 
// result of a starting type command (local or remote). Following this 
// command the machine will begin to Execute.
//
	IDLE := 16#4,
//	
// State TYPE: Wait
// This is a state which indicates that RESETTING is complete. This 
// state maintains the machine conditions which were achieved during 
// the RESETTING state, and performs operations required when the 
// machine is in IDLE. 
//
SUSPENDING := 16#100,
// 
// State Type: Acting 
// This state is a result of a change in monitored conditions due to 
// process conditions or factors. The trigger event will cause a 
// temporary suspension of the EXECUTE state. SUSPENDING is 
// typically the result of starvation of upstream material in-feeds (i.e., 
// container feed, beverage feed, crown feed, lubricant feed, etc.) that 
// is outside the dynamic speed control range or a downstream outfeed blockage that prevents the machine from EXECUTING 
// continued steady production. During the controlled sequence of 
// SUSPENDING the machine will transition to a SUSPENDED state. 
// The SUSPENDING state might be forced by the operator. 
//
SUSPENDED := 16#200,
// 
// State Type: Wait
// The machine may be running at a relevant set point speed, but 
// there is no product being produced while the machine is waiting for 
// external process conditions to return to normal. When the offending 
// process conditions return to normal, the SUSPENDED state will 
// transition to UNSUSPENDING and hence continue towards the 
// normal EXECUTE state. 
// Note: The SUSPENDED state can be reached as a result of abnormal external 
// process conditions and differs from HELD. HELD is typically a result of an operator 
// request or an automatically detected machine fault condition that should be 
// corrected before an operator request to transition to the UNHOLDING state will be 
// processed. 
//
UNSUSPENDING := 16#400,
// 
// State Type: Acting 
// This state is a result of a machine generated request from 
// SUSPENDED state to go back to the EXECUTE state. The actions 
// of this state may include ramping up speeds, turning on vacuums, 
// and the re-engagement of clutches. This state is done prior to 
// EXECUTE state, AND prepares the machine FOR the EXECUTE state.
//
EXECUTE := 16#10,
// 
// State Type: Dual
// Once the machine is processing materials it is deemed to be 
// executing or in the EXECUTE state. Different machine modes will 
// result in specific types of EXECUTE activities. For example, if the 
// machine is in the Production mode, the EXECUTE will result in 
// products being produced, while in Clean Out mode the EXECUTE 
// state refers TO the ACTION OF cleaning the machine. 
//
STOPPING := 16#2000,
// 
// State Type: Acting
// This state executes the logic which brings the machine to a 
// controlled stop as reflected by the STOPPED state. Normal 
// STARTING of the machine can not be initiated unless RESETTING 
// had taken place. 
//
ABORTING := 16#4000,
// 
// State Type: Acting 
// The ABORTED state can be entered at any time in response to the 
// Abort command or on the occurrence of a machine fault. The 
// aborting logic will bring the machine to a rapid safe stop. Operation 
// of the emergency stop will cause the machine to be tripped by its 
// safety system. It will also provide a signal to initiate the 
// ABORTING State. 
//
ABORTED := 16#8000,
//
// State Type: Wait 
// This state maintains machine status information relevant to the 
// Abort condition. The machine can only exit the ABORTED state 
// after an explicit Clear command, subsequently to manual 
// intervention TO correct AND reset the detected machine faults. 
//
HOLDING := 16#20,
//
// State Type: Acting 
// When the machine is in the EXECUTE state, the Hold command 
// can be used to start HOLDING logic which brings the machine to a 
// controlled stop or to a state which represents HELD for the 
// particular unit control mode. A machine can go into this state either 
// when an internal equipment fault is automatically detected or by an 
// operator command. The Hold command offers the operator a safe 
// way to intervene manually in the process (such as removing a 
// broken bottle from the in-feed) and restarting execution when 
// conditions are safe. To be able to restart production correctly after 
// the HELD state, all relevant process set-points and return status of 
// the procedures at the time of receiving the Hold command must be 
// saved in the machine controller when executing the HOLDING 
// procedure. 
//
HELD := 16#40,
//
// State Type: Wait 
// The HELD state holds the machine's operation while material 
// blockages are cleared, or to stop throughput while a downstream 
// problem is resolved, or enable the safe correction of an equipment 
// fault before the production may be resumed. 
//
UNHOLDING := 16#80,
//
// State Type: Acting 
// The UNHOLDING state is a response to an Operator command to 
// resume the EXECUTE state. Issuing the Unhold command will 
// retrieve the saved set-points and return the status conditions to 
// prepare the machine to re-enter the normal EXECUTE state. 
// Note: An operator Unhold command is always required and UNHOLDING can 
// never be initiated automatically. 
//
COMPLETING := 16#800,
//
//State TYPE: Acting 
// This state is an automatic response from the EXECUTE state. 
// Normal operation has run to completion (i.e., processing of material 
// at the infeed will stop).
//
COMPLETE := 16#1000,
//
// State Type: Wait 
// The machine has finished the COMPLETING state and is now 
// waiting for a Reset command before transitioning to the 
//RESETTING state.
//
RESETTING := 16#2,
//
// State Type: Acting 
// This state is the result of a RESET command from the STOPPED or 
// complete state. RESETTING will typically cause a machine to 
// sound a horn and place the machine in a state where components 
// are energized awaiting a START command. 
//
 CLEARING := 16#10000,
//
//State Type: Acting 
// Initiated by a state command to clear faults that may have occurred 
// when ABORTING, and are present in the ABORTED state before 
// proceeding to a STOPPED state. 
//
	No := 0,
	All := 16#1FFFF,
	Invalid := 16#80000000
) DWORD;
END_TYPE