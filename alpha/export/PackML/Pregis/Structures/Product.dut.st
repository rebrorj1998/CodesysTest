(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE Product :
STRUCT
	ProductID : INT;
	ProcessVariables : ARRAY[0..Packml_Variable_Config.maxProcessVariables] OF Descriptor; 
	Ingredients : ARRAY[0..Packml_Variable_Config.maxIngredients] OF Ingredient;
END_STRUCT
END_TYPE
