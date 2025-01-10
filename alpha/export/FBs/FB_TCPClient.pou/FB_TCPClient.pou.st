(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_TCPClient
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR

VAR
    // =======================================
    // set up Client
    // =======================================
    _TCPClient : NBS.TCP_Client;
    _TCPClient_ipAddr: NBS.IP_ADDR;
    _TCPClient_uiPort: UINT := 9100;
    _TCPClient_hClient : CAA.HANDLE; // Client handle
    _sClientIP : STRING(15):='192.168.10.160'; (* this device's Client IP address *)
    _uiPort : UINT:= 9100;
    _TCPConnection : NBS.TCP_Connection; // TCP connection instances
    _TCPConnection_hConnection: CAA.HANDLE;    // handle of client connections    
    _TCPWriteSendLabel : NBS.TCP_Write; // TCP write
	_TCPWriteClearLabel : NBS.TCP_Write; // TCP write
    _TCPRead : NBS.TCP_Read; // TCP read
    _sTCPSendLabel: STRING(25000); // This is the label
	_sTCPClearLabel : STRING(3) := '~JA';
    _sTCPReadData: STRING(1000); //receive up to 1000 chars if needed
    _TCPWriteEn: BOOL;
    _sServerIP: STRING(80);
    _sendLabel : BOOL;
	_clearLabel : BOOL;
	label203 : STRING(8000) := '^XA
^LRY
^LL1218

^GFA,26624,26624,00104,:Z64:
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:58A1

^FX Border
^FO0,0 ^GB812,1218,2,,1 ^FS

^FX Normal type
^FO80,265^A0,7 ^FD7 px The Quick Brown Fox 0123456789^FS
^FO80,277^A0,14 ^FD14 px The Quick Brown Fox 0123456789^FS
^FO80,295^A0,23 ^FD23 px The Quick Brown Fox 0123456789^FS
^FO80,319^A0,32 ^FD32 px The Quick Brown Fox 0123456789^FS

^FX Vertical type
^FO725,557^A0R,14 ^FD14 px The Quick Brown Fox 0123456789^FS
^FO690,557^A0R,23 ^FD23 pxThe Quick Brown Fox 0123456789^FS

^FX reverse type
^FO80,390^A0,7  ^FD7  px The Quick Brown Fox 0123456789^FS
^FO80,402^A0,14 ^FD14 px The Quick Brown Fox 0123456789^FS
^FO80,420^A0,23 ^FD23 px The Quick Brown Fox 0123456789^FS
^FO80,444^A0,32 ^FD32 px The Quick Brown Fox 0123456789^FS

^FX Reverse Type box
^FO25,360  ^GB760,150, 100,B, 4 ^FS

^FX Circles
^FO 203,636 ^GC50,2 ^FS
^FO 253,636 ^GC50,50 ^FS

^FO 303,636 ^GC50,2 ^FS
^FO 353,636 ^GC50,50 ^FS

^FO 403,636 ^GC50,2 ^FS
^FO 453,636 ^GC50,50 ^FS

^FO 503,636 ^GC50,2 ^FS
^FO 553,636 ^GC50,50 ^FS

^LRN

^FX Box with slashed lines
^FO203,576 ^GB406,50,2^FS

^FO203,576 ^GD50,50,2^FS
^FO253,576 ^GD50,50,2^FS
^FO203,576 ^GD50,50,2,,L^FS
^FO253,576 ^GD50,50,2,,L^FS

^FO353,576 ^GD50,50,2^FS
^FO303,576 ^GD50,50,2^FS
^FO353,576 ^GD50,50,2,,L^FS
^FO303,576 ^GD50,50,2,,L^FS

^FO453,576 ^GD50,50,2^FS
^FO403,576 ^GD50,50,2^FS
^FO453,576 ^GD50,50,2,,L^FS
^FO403,576 ^GD50,50,2,,L^FS

^FO553,576 ^GD50,50,2^FS
^FO503,576 ^GD50,50,2^FS
^FO553,576 ^GD50,50,2,,L^FS
^FO503,576 ^GD50,50,2,,L^FS

^FX Picket Fence Barcodes 
^BY2 ^BC,100 ^FO260,720 ^FD1234567890^FS
^BY3 ^BC,100 ^FO180,860 ^FD1234567890^FS

^FX 2D Barcodes
^FO30,1000^BQN,2,6,M,7^FDQA,http://www.pregis.com^FS
^FO320,1000^BQN,2,6,M,7^FDQA,http://www.pregis.com^FS
^FO610,1000^BQN,2,6,M,7^FDQA,http://www.pregis.com^FS

^FX Ladder barcodes - 
^BY3
^BCB,100 ^FO25,550 ^FD1234567890^FS

^XZ';
	label300 : STRING(8000) := '^XA
^LRY

^FO0,0
^GFA,58368,58368,00152,:Z64:
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:DCC5

^FX Border
^FO0,0 ^GB1200,1800,2,,1 ^FS

^FX Normal type
^FO118,391^A0,14 ^FD14 px The Quick Brown Fox 0123456789^FS
^FO118,409^A0,23 ^FD23 px The Quick Brown Fox 0123456789^FS
^FO118,436^A0,32 ^FD32 px The Quick Brown Fox 0123456789^FS
^FO118,471^A0,42 ^FD42 px The Quick Brown Fox^FS

^FX Vertical type
^FO1071,823^A0R,23 ^FD23 px The Quick Brown Fox 0123456789^FS
^FO1020,823^A0R,32 ^FD32 pxThe Quick Brown Fox^FS

^FX reverse type
^FO118,576^A0,14 ^FD14  px The Quick Brown Fox 0123456789^FS
^FO118,594^A0,23 ^FD23 px The Quick Brown Fox 0123456789^FS
^FO118,621^A0,32 ^FD32 px The Quick Brown Fox 0123456789^FS
^FO118,656^A0,42 ^FD42 px The Quick Brown Fox ^FS

^FX Reverse Type box
^FO37,532  ^GB1123,222, 200,B, 4 ^FS

^FX Circles
^FO 300,940 ^GC75,2 ^FS
^FO 374,940 ^GC75,50 ^FS

^FO 448,940 ^GC75,2 ^FS
^FO 522,940 ^GC75,50 ^FS

^FO 596,940 ^GC75,2 ^FS
^FO 669,940 ^GC75,50 ^FS

^FO 743,940 ^GC75,2 ^FS
^FO 817,940 ^GC75,50 ^FS

^LRN

^FX Box with slashed lines
^FO300,851 ^GB600,75,3^FS

^FO300,851 ^GD75,75,3^FS
^FO375,851 ^GD75,75,3^FS
^FO300,851 ^GD75,75,3,,L^FS
^FO375,851 ^GD75,75,3,,L^FS

^FO522,851 ^GD75,75,3^FS
^FO448,851 ^GD75,75,3^FS
^FO522,851 ^GD75,75,3,,L^FS
^FO448,851 ^GD75,75,3,,L^FS

^FO669,851 ^GD75,75,3^FS
^FO596,851 ^GD75,75,3^FS
^FO669,851 ^GD75,75,3,,L^FS
^FO596,851 ^GD75,75,3,,L^FS

^FO817,851 ^GD75,75,3^FS
^FO743,851 ^GD75,75,3^FS
^FO817,851 ^GD75,75,3,,L^FS
^FO743,851 ^GD75,75,3,,L^FS

^FX Picket Fence barcodes 
^BY3 ^BC,148 ^FO384,1064 ^FD1234567890^FS
^BY4 ^BC,148 ^FO310,1271 ^FD1234567890^FS

^FX 2D Barcodes
^FO70,1500^BQN,2,8,M,7^FDQA,http://www.pregis.com^FS
^FO480,1500^BQN,2,8,M,7^FDQA,http://www.pregis.com^FS
^FO910,1500^BQN,2,8,M,7^FDQA,http://www.pregis.com^FS

^FX Ladder barcode 
^BY4
^BCB,148 ^FO37,813 ^FD1234567890^FS

^XZ';
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Program: PRG_TCP_Client
//    Description: This provides TCP Comms to the zebra printer
//    
//    Created by: Ben Hess
//    Created Date: Tuesday, May 1, 2018

// Here's an example label
CASE HMIData.printerSelection OF
	LabelPrinterSelection.PrintAndApply203DPI:
		_sTCPSendLabel := label203;
		_sClientIP := '192.168.10.165';
	
	LabelPrinterSelection.PrintAndApply300DPI:
		_sTCPSendLabel := label300;
		_sClientIP := '192.168.10.165';
	
	LabelPrinterSelection.ZebraPrinter203DPI:
		_sTCPSendLabel := label203;
		_sClientIP :='192.168.10.160';
	
	LabelPrinterSelection.ZebraPrinter300DPI:
		_sTCPSendLabel := label300;
		_sClientIP :='192.168.10.160';
END_CASE

_TCPClient_ipAddr.sAddr := _sClientIP; // Set IP address
_TCPClient(
	xEnable:= _sendLabel OR _clearLabel, // Manually toggle for testing
	ipAddr:= _TCPClient_ipAddr, 
	uiPort:= _uiPort,
	hConnection=> _TCPConnection_hConnection
);

// set TCP connection
_TCPConnection(
	xEnable:= _TCPClient.xBusy AND NOT(_TCPConnection.xDone), //when server is ready
);

// Write when connection is ready
_TCPWriteSendLabel(
	xExecute:= _sendLabel AND _TCPClient.xActive, // Manually enable for testing
	udiTimeOut:= 600000, // In microseconds => 600ms
	hConnection := _TCPConnection_hConnection,
	szSize := 25000, // Write length only
	pData := ADR(_sTCPSendLabel)
);
// Reset write enable
IF(_TCPWriteSendLabel.xDone) THEN
	_TCPWriteEn:= FALSE;
	_sendLabel := FALSE;
END_IF

// Write when connection is ready
_TCPWriteClearLabel(
	xExecute:= _clearLabel AND _TCPClient.xActive, // Manually enable for testing
	udiTimeOut:= 600000, //in microseconds => 600ms
	hConnection := _TCPConnection_hConnection,
	szSize := 3, // write length only
	pData := ADR(_sTCPClearLabel)
);
// Reset write enable
IF(_TCPWriteClearLabel.xDone) THEN
	_TCPWriteEn:= FALSE;
	_clearLabel := FALSE;
END_IF

