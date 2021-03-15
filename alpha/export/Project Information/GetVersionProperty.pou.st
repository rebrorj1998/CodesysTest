(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// This function has been automatically generated from the project information.
{attribute 'signature_flag' := '1073741824'}
{attribute 'register_in_runtime'}
FUNCTION GetVersionProperty : VERSION
VAR_INPUT
	stKey: WSTRING;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF stKey = "Version" THEN
	GetVersionProperty.uiMajor := 0;
	GetVersionProperty.uiMinor := 9;
	GetVersionProperty.uiServicePack := 15;
	GetVersionProperty.uiPatch := 18;
ELSE
	GetVersionProperty.uiMajor := 0;
	GetVersionProperty.uiMinor := 0;
	GetVersionProperty.uiServicePack := 0;
	GetVersionProperty.uiPatch := 0;
END_IF