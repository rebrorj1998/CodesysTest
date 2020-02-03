(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION SaveValues : DWORD
VAR
	recipieManager : Recipe_Management.RecipeManCommands;
	recipeName : STRING;
	recResult : DWORD;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
recResult := recipieManager.CreateRecipe(RecipeDefinitionName := 'Recipes', RecipeName := 'Automatic');
recResult := recipieManager.ReadAndSaveRecipe(RecipeDefinitionName := 'Recipes', RecipeName := recipeName);