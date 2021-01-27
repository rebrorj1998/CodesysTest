(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION RecallValues : DWORD
VAR
	recipieManager : Recipe_Management.RecipeManCommands;
	recipeName : STRING;
	recResult : UDINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
recResult := recipieManager.CreateRecipe(RecipeDefinitionName := 'Recipes', RecipeName := 'Automatic');
recResult := recipieManager.GetRecipeNames('Recipes', ADR(recipeName),1,0);
recResult := recipieManager.LoadAndWriteRecipe(RecipeDefinitionName := 'Recipes', RecipeName := 'Automatic');
