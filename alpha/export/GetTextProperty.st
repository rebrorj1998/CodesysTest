

// This function has been automatically generated from the project information.
{attribute 'signature_flag' := '1073741824'}
{attribute 'register_in_runtime'}
FUNCTION GetTextProperty : WSTRING
VAR_INPUT
	stKey: WSTRING;
END_VAR
IF stKey = "Author" THEN
	GetTextProperty := "Ben Hess";
ELSIF stKey = "Company" THEN
	GetTextProperty := "Sharp Packaging";
ELSIF stKey = "Project" THEN
	GetTextProperty := "AlphaController";
ELSIF stKey = "Title" THEN
	GetTextProperty := "MOAB Prototype";
ELSIF stKey = "VersionPostfix" THEN
	GetTextProperty := "-alpha/master";
ELSE
	GetTextProperty := "";
END_IF
