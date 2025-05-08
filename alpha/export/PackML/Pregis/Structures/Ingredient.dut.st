(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE Ingredient :
STRUCT
	IngredientID : INT;
	Parameter : ARRAY [0..Packml_Variable_Config.maxParameters] OF Descriptor;
END_STRUCT
END_TYPE
