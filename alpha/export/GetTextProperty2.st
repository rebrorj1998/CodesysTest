

// This function has been automatically generated from the project information.
{attribute 'signature_flag' := '1073741824'}
{attribute 'register_in_runtime'}
FUNCTION GetTextProperty2 : POINTER TO WSTRING
VAR_INPUT
	stKey: WSTRING;
END_VAR
IF stKey = "Author" THEN
	GetTextProperty2 := ADR("Ben Hess");
ELSIF stKey = "Company" THEN
	GetTextProperty2 := ADR("Sharp Packaging");
ELSIF stKey = "Project" THEN
	GetTextProperty2 := ADR("AlphaController");
ELSIF stKey = "Title" THEN
	GetTextProperty2 := ADR("MOAB Prototype");
ELSIF stKey = "VersionPostfix" THEN
	GetTextProperty2 := ADR("-alpha");
ELSE
	GetTextProperty2 := ADR("");
END_IF
