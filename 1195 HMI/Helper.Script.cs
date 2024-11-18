//--------------------------------------------------------------
// Press F1 to get help about using script.
// To access an object that is not located in the current class, start the call with Globals.
// When using events and timers be cautious not to generate memoryleaks,
// please see the help for more information.
//---------------------------------------------------------------

namespace Neo.ApplicationFramework.Generated
{
	using System.Windows.Forms;
	using System;
	using System.Drawing;
	using Neo.ApplicationFramework.Tools;
	using Neo.ApplicationFramework.Common.Graphics.Logic;
	using Neo.ApplicationFramework.Controls;
	using Neo.ApplicationFramework.Interfaces;
	using System.Reflection;
	using Neo.ApplicationFramework.Tools.OpcClient;
	using Neo;
	using System.Linq;
	using Neo.ApplicationFramework.Interfaces.Tag;
    
    
	public partial class Helper
	{
		
		public static System.Collections.Generic.IEnumerable<Neo.ApplicationFramework.Interfaces.Tag.IBasicTag> GetActiveComponentTags()
		{   
			string[] stringList = GetAllComponentID();
			var tagList = from tag in Globals.Tags.GetType().GetFields()
			where tag.Name.ToString().ToLower().Contains("component") && stringList.Any(x => tag.Name.ToString().EndsWith(x)) 
			select (IBasicTag)tag.GetValue(Globals.Tags);
			return tagList;
			}

		public static string[] GetAllComponentID()
		{	
			var tagList = from theElement in Globals.Tags.GetType().GetFields()
					where theElement.Name.ToString().ToLower().Contains("component") && theElement.Name.ToString().ToLower().Contains("inuse") && ((IBasicTag)theElement.GetValue(Globals.Tags)).Value.ToString().ToLower() == "true" && (theElement.FieldType.ToString().Contains("LightweightTag") ||  theElement.FieldType.ToString().Contains("GlobalDataItem"))
					select "_"+theElement.Name.ToString().Split('_').Last();
			return tagList.Cast<string>().ToArray();
		}

	}
}
