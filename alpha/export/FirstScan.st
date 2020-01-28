

FUNCTION FirstScan : DWORD
VAR_IN_OUT
    EventPrm: CmpApp.EVTPARAM_CmpApp;
END_VAR
VAR
	recipieManager : Recipe_Management.RecipeManCommands;
	recipeName : STRING;
	recResult : DWORD;
END_VAR

Globals.firstScan := TRUE;
	recResult := recipieManager.GetRecipeNames('Recipes', ADR(recipeName),1,0);
	recResult := recipieManager.LoadAndWriteRecipe(RecipeDefinitionName := 'Recipes', RecipeName := recipeName);