

FUNCTION FN_RandomDINT : DINT
VAR_INPUT
	last : DINT;
	low : DINT;
	high : DINT;
END_VAR
VAR
END_VAR

FN_RandomDINT := TO_DINT(OSCAT_BASIC.RDM(OSCAT_BASIC.FRACT(TO_REAL(last) * OSCAT_BASIC.Globale_Variablen.MATH.PI)) * (TO_REAL(high) - TO_REAL(low) + 1)) + low;
