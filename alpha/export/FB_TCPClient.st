

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
    _TCPWrite : NBS.TCP_Write; // TCP write
    _TCPRead : NBS.TCP_Read; // TCP read
    _sTCPSendData: STRING(3000); // This is the label
    _sTCPReadData: STRING(1000); //receive up to 1000 chars if needed
    _TCPWriteEn: BOOL;
    _sServerIP: STRING(80);
    _sendLabel : BOOL;
END_VAR

//    Program: PRG_TCP_Client
//    Description: This provides TCP Comms to the zebra printer
//    
//    Created by: Ben Hess
//    Created Date: Tuesday, May 1, 2018

// Here's an example label
_sTCPSendData := 
'^XA^DFR:SSF0.ZPL
^LL1218
^FO20,20^A0N,22,16^FDFrom:^FS
^FO20,45^A0N,22,16^FD^FS
^FO20,70^A0N,22,16^FDSHARP PACKAGING^FS
^FO20,95^A0N,22,16^FDBY PREGIS^FS
^FO20,120^A0N,22,16^FDN59 W22387 Silver Spring Dr^FS
^FO20,145^A0N,22,16^FDSUSSEX, WI 53089^FS
^FO275,145^A0N,22,16^FD^FS


^FO464,13^GB0,165,2^FS

^FO477,23^A0N,22,22^FDShip Date: 10/16/2018^FS
^FO477,45^A0N,22,22^FDActual Wgt: 14 LBS^FS
^FO477,67^A0N,22,22^FDSystem #: 161112^FS
^FO477,89^A0N,22,22^FDAccount: 344796459^FS

^FO0,175^GB800,0,2^FS

^FO10,182^A0N,28,28^FDTO:^FS
^FO55,182^A0N,28,28^FD262-555-1212^FS
^FO55,210^A0N,28,28^FDJON UBERT^FS
^FO55,238^A0N,28,28^FDIBUB LLC^FS
^FO55,266^A0N,28,28^FD1801 W OLIVE ST^FS
^FO55,294^A0N,28,28^FD2ND FLOOR^FS
^FO55,322^A0N,35,40^FDMILWAUKEE, WI 53223^FS
^FO550,330^A0N,35,40^FD^FS

^FO628,183^A0N,48,53^FDFedEx.^FS
^FO640,224^A0N,16,18^FD             Ground^FS
^FO743,240^GB0,100,14^FS
^FO642,249^GB0,100,14^FS
^FO642,340^GB115,0,14^FS
^FO642,240^GB115,0,14^FS
^FO665,265^A0N,85,115^FDG^FS

^FO0,400^GB800,0,2^FS

^FO20,430^BY2,2.0^B7N,10,5,12,,N^FH^FD[)>_1E01_1D0290040_1D840_1D422_1D044137590247547_1DFDEB_1D_1D032_1D_1D5/6_1D14.0LB_1DN_1D100 CITADEL DRIVE_1DCOMMERCE_1DCA_1D90040PU_1E06_1D10ZGD004_1D11ZPUMA-CITADEL OUTLET_1D12Z9786981000_1D14ZSUITE 662_1D18Z344796459_1CEX_1D23ZN_1D_1E_04^FS

^FO580,420^A0N,38,40^FDService Code^FS
^FO655,460^A0N,42,40^FD422^FS
^FO670,510^A0N,38,40^FD5^FS
^FO670,550^A0N,38,40^FDof^FS
^FO670,590^A0N,38,40^FD6^FS

^FO644,636^A0N,45,48^FR^FD^FS

^FO0,690^GB800,0,2^FS

^FO59,715^BY4^BCN,295,N,N^FD>;>89612422044137590247547^FS
^FO120,1030^A0N,44,38^FD(9612422)    0441375    90247547^FS

^FO20,1070^A0N,40,38^FDINVALID^FS
^FO20,1110^A0N,40,38^FD^FS
^FO312,1070^A0N,40,38^FD^FS
^FO312,1110^A0N,40,38^FD^FS
^FO20,1165^A0N,20,21^FD^FS

^FO0,1190^GB800,0,2^FS

^FO15,1200^A0N,15,16^FDCARTON NUMBER: 00006031519137464996^FS
^XZ
^XA^XFR:SSF0.ZPL^PQ1,0,1,Y^XZ
^XA^IDR:SSF0.ZPL^XZ';

_TCPClient_ipAddr.sAddr := _sClientIP; //set IP address
_TCPClient(
xEnable:= _sendLabel AND NOT _TCPWrite.xDone, // manually toggle for testing
xDone=> ,
xBusy=> ,
xError=> ,
ipAddr:= _TCPClient_ipAddr, 
uiPort:= _uiPort,
eError=> ,
hConnection=> _TCPConnection_hConnection);

// set TCP connection
_TCPConnection(
xEnable:= _TCPClient.xBusy AND NOT(_TCPConnection.xDone), //when server is ready
xDone=> , // client manually disconnected
xBusy=> ,
xError=> ,
hServer:=, // point all connections back to the same server
eError=> ,
xActive=> , 
hConnection=> );

// only execute on active connections

// write when connection is ready
_TCPWrite(
xExecute:= _sendLabel AND _TCPClient.xActive, //manually enable for testing
udiTimeOut:= 600000, //in microseconds => 600ms
xDone=> ,
xBusy=> , 
xError=> ,
hConnection := _TCPConnection_hConnection,
szSize := 3000, // write length only
pData := ADR(_sTCPSendData), 
eError=> );
//reset write enable
IF(_TCPWrite.xDone) THEN
_TCPWriteEn:= FALSE;
_sendLabel := FALSE;
END_IF



METHOD SendLabel
VAR_INPUT
END_VAR

_sendLabel := TRUE;