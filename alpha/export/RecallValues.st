

FUNCTION RecallValues : DWORD
VAR
	recipieManager : Recipe_Management.RecipeManCommands;
	recipeName : STRING;
	recResult : DWORD;
END_VAR

recResult := recipieManager.GetRecipeNames('Recipes', ADR(recipeName),1,0);
recResult := recipieManager.LoadAndWriteRecipe(RecipeDefinitionName := 'Recipes', RecipeName := recipeName);