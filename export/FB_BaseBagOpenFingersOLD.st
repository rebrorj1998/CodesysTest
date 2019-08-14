

FUNCTION_BLOCK FB_BaseBagOpenFingersOLD EXTENDS FB_BaseComponent IMPLEMENTS IBagOpenFingers
VAR_INPUT
	simulateIO : BOOL;
	simMissedBag : BOOL;
	delayToGrabSetting : REAL;						// How long to wait afer a grab request to start moving fingers
	delayToCheckBagPresentSetting : REAL;			// How long to wait after grabbing bag to check if it is present
	delayToClearSetting : REAL;						// How long to wait after letting go of bag to call it clear of the pressure bar
END_VAR
VAR_OUTPUT
	grabCounter : FB_MachineCounter(name := CONCAT(_prefix, 'Grab Counter'));
	releaseCounter : FB_MachineCounter(name := CONCAT(_prefix, 'Release Counter'));
	missedCounter : FB_MachineCounter(name := CONCAT(_prefix, 'Missed Counter'));
END_VAR
VAR
	_grabBagRequest : BOOL;
	_releaseBagRequest : BOOL;
	_bagCleared : BOOL;
	_bagGrabbed : BOOL;
	_bagMissed : BOOL;
	delayToGrab : Standard.TON;
	delayToCheckBagPresent : Standard.TON;
	delayToClear : Standard.TON;
END_VAR
VAR_IN_OUT
	
END_VAR
SUPER^();
delayToGrab(IN := _grabBagRequest, PT := REAL_TO_TIME(delayToGrabSetting * 1000));
delayToCheckBagPresent(IN := delayToGrab.Q, PT := REAL_TO_TIME(delayToCheckBagPresentSetting * 1000));
delayToClear(IN := _releaseBagRequest, PT := REAL_TO_TIME(delayToClearSetting * 1000));

{attribute 'monitoring' := 'variable'}
PROPERTY BagCleared : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY BagGrabbed : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY BagMissed : BOOL


METHOD RemovePower
VAR_INPUT
END_VAR

_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_grabBagRequest := FALSE;
_releaseBagRequest := FALSE;
_logger.AddLogItem(CONCAT(_prefix,' Remove Power Request'));

METHOD GrabBag

_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_releaseBagRequest := FALSE;
_grabBagRequest := TRUE;
_logger.AddLogItem(CONCAT(_prefix,' Grab Bag Request'));

METHOD ReleaseBag

_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_grabBagRequest := FALSE;
_releaseBagRequest := TRUE;
_logger.AddLogItem(CONCAT(_prefix,' Release Bag Request'));

FUNCTION_BLOCK FB_BaseBagOpenFingersOLD EXTENDS FB_BaseComponent IMPLEMENTS IBagOpenFingers
VAR_INPUT
	simulateIO : BOOL;
	simMissedBag : BOOL;
	delayToGrabSetting : REAL;						// How long to wait afer a grab request to start moving fingers
	delayToCheckBagPresentSetting : REAL;			// How long to wait after grabbing bag to check if it is present
	delayToClearSetting : REAL;						// How long to wait after letting go of bag to call it clear of the pressure bar
END_VAR
VAR_OUTPUT
	grabCounter : FB_MachineCounter(name := CONCAT(_prefix, 'Grab Counter'));
	releaseCounter : FB_MachineCounter(name := CONCAT(_prefix, 'Release Counter'));
	missedCounter : FB_MachineCounter(name := CONCAT(_prefix, 'Missed Counter'));
END_VAR
VAR
	_grabBagRequest : BOOL;
	_releaseBagRequest : BOOL;
	_bagCleared : BOOL;
	_bagGrabbed : BOOL;
	_bagMissed : BOOL;
	delayToGrab : Standard.TON;
	delayToCheckBagPresent : Standard.TON;
	delayToClear : Standard.TON;
END_VAR
VAR_IN_OUT
	
END_VAR
SUPER^();
delayToGrab(IN := _grabBagRequest, PT := REAL_TO_TIME(delayToGrabSetting * 1000));
delayToCheckBagPresent(IN := delayToGrab.Q, PT := REAL_TO_TIME(delayToCheckBagPresentSetting * 1000));
delayToClear(IN := _releaseBagRequest, PT := REAL_TO_TIME(delayToClearSetting * 1000));

{attribute 'monitoring' := 'variable'}
PROPERTY BagCleared : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY BagGrabbed : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY BagMissed : BOOL


METHOD RemovePower
VAR_INPUT
END_VAR

_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_grabBagRequest := FALSE;
_releaseBagRequest := FALSE;
_logger.AddLogItem(CONCAT(_prefix,' Remove Power Request'));

METHOD GrabBag

_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_releaseBagRequest := FALSE;
_grabBagRequest := TRUE;
_logger.AddLogItem(CONCAT(_prefix,' Grab Bag Request'));

METHOD ReleaseBag

_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_grabBagRequest := FALSE;
_releaseBagRequest := TRUE;
_logger.AddLogItem(CONCAT(_prefix,' Release Bag Request'));