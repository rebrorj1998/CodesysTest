

FUNCTION_BLOCK FB_MurrMaster EXTENDS FB_BaseObject
VAR_INPUT
	ptrEIPInputs : POINTER TO BYTE;	// Pointer to starting word of EIP Inputs for the I/O Image
    ptrEIPOutputs : POINTER TO BYTE;	// Pointer to starting word of EIP Outputs for the I/O Image
END_VAR
VAR_OUTPUT
	headIONode : FB_IOLinkBlock(name := 'Head Block');
	frontGuardIONode : FB_Murr16PointCFGIO(name := 'Front Guard Block');
	dischargeIONode : FB_Murr16PointCFGIO(name := 'Discharge Block');
	printerIONode : FB_Murr56691_IP20(name := 'Printer Block');
END_VAR
VAR
END_VAR
VAR (*Faults*)
	commFail : FB_Fault(name := CONCAT(_prefix,  'Communication Failure'));
END_VAR
// Head IO Node, offset of 0 for I/O
headIONode(ptrEIPInputs := ptrEIPInputs, ptrEIPOutputs := ptrEIPOutputs);
frontGuardIONode(ptrEIPInputs := ADR(ptrEIPInputs[30]), ptrEIPOutputs := ADR(ptrEIPOutputs[30]));
dischargeIONode(ptrEIPInputs := ADR(ptrEIPInputs[32]), ptrEIPOutputs := ADR(ptrEIPOutputs[32]));
printerIONode(ptrEIPInputs := ADR(ptrEIPInputs[34]), ptrEIPOutputs := ADR(ptrEIPOutputs[34]));
{region 'Alarms'}

{endregion}

FUNCTION_BLOCK FB_MurrMaster EXTENDS FB_BaseObject
VAR_INPUT
	ptrEIPInputs : POINTER TO BYTE;	// Pointer to starting word of EIP Inputs for the I/O Image
    ptrEIPOutputs : POINTER TO BYTE;	// Pointer to starting word of EIP Outputs for the I/O Image
END_VAR
VAR_OUTPUT
	headIONode : FB_IOLinkBlock(name := 'Head Block');
	frontGuardIONode : FB_Murr16PointCFGIO(name := 'Front Guard Block');
	dischargeIONode : FB_Murr16PointCFGIO(name := 'Discharge Block');
	printerIONode : FB_Murr56691_IP20(name := 'Printer Block');
END_VAR
VAR
END_VAR
VAR (*Faults*)
	commFail : FB_Fault(name := CONCAT(_prefix,  'Communication Failure'));
END_VAR
// Head IO Node, offset of 0 for I/O
headIONode(ptrEIPInputs := ptrEIPInputs, ptrEIPOutputs := ptrEIPOutputs);
frontGuardIONode(ptrEIPInputs := ADR(ptrEIPInputs[30]), ptrEIPOutputs := ADR(ptrEIPOutputs[30]));
dischargeIONode(ptrEIPInputs := ADR(ptrEIPInputs[32]), ptrEIPOutputs := ADR(ptrEIPOutputs[32]));
printerIONode(ptrEIPInputs := ADR(ptrEIPInputs[34]), ptrEIPOutputs := ADR(ptrEIPOutputs[34]));
{region 'Alarms'}

{endregion}