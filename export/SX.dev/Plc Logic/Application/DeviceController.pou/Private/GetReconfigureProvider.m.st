(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE GetReconfigureProvider : DED.INode
VAR_INPUT
	itfNode		: DED.INode;
END_VAR
VAR
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF itfNode <> 0 THEN
	REPEAT
		(* search to top until a IReconfigureProvider is found*)
		IF DED.CanReconfigure(itfNode) THEN
			GetReconfigureProvider := itfNode;
			EXIT;
		END_IF
		
		itfNode := itfNode.ParentNode;
		
	UNTIL
		itfNode = 0
	END_REPEAT
END_IF