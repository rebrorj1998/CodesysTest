

FUNCTION PrepareShutdown : DWORD
VAR_IN_OUT
	EventPrm: Component_Manager.EVTPARAM_CmpMgr_Shutdown;
END_VAR
VAR
	recipieManager : Recipe_Management.RecipeManCommands;
	recipeName : STRING;
	recResult : DWORD;
END_VAR

	recResult := recipieManager.CreateRecipe(RecipeDefinitionName := 'Recipes', RecipeName := 'Automatic');
	recResult := recipieManager.ReadAndSaveRecipe(RecipeDefinitionName := 'Recipes', RecipeName := recipeName);