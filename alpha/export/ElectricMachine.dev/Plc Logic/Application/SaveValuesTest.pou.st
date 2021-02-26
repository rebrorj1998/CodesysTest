(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION SaveValuesTest : DWORD
VAR
	recipieManager : Recipe_Management.RecipeManCommands;
	recipeName : STRING;
	recResult : DWORD;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF HMIData.bagsMade.count <> 0 THEN
	recResult := recipieManager.CreateRecipe(RecipeDefinitionName := 'Recipes', RecipeName := 'ExitTasks');
	//recResult := recipieManager.GetRecipeNames('Recipes', ADR(recipeName),1,0);
	recResult := recipieManager.ReadAndSaveRecipe(RecipeDefinitionName := 'Recipes', RecipeName := 'ExitTasks');
END_IF
