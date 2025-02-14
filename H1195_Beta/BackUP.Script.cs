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
    
    
	public partial class BackUp
	{
		
		public static System.Collections.Generic.IEnumerable<Neo.ApplicationFramework.Interfaces.Tag.IBasicTag> GetActiveComponentTags()
		{   var properties = GetProperties(Globals.Tags.GlobalDataItems);
			//genMessage(properties);
			var properties2 = GetProperties(Globals.Tags);
			//genMessage(properties2);
			string test = "";
			System.Collections.Generic.IEnumerable<Neo.ApplicationFramework.Interfaces.Tag.IBasicTag> tagList = GetAllComponentTags();
			//var outputtaglist = tagList;
			//MessageBox.Show(tagList.GetType().ToString());
			foreach (IBasicTag bark in  tagList)
			{
				if (bark.Name.ToLower().Contains("inuse"))
				{
					bark.Read();
					if (bark.Value.ToString().ToLower() == "false")
					{
						string elementID = bark.Name.Split('_').Last();
						tagList = from tag in tagList
								where !(tag.Name.EndsWith("_" + elementID))
								select tag;
						test = test + "will be removed "+bark.Name + " " + bark.Value.ToString()+ " type: "  + bark.Value.GetType().ToString() + Environment.NewLine;
					}
				}
				
			}
			foreach (IBasicTag temp in tagList)
			{
				test = test +temp.Name + " " + temp.Value.ToString()+ " type: "  + temp.Value.GetType().ToString() + Environment.NewLine;
			}
			
			//MessageBox.Show(test);
			return tagList;
		}
		public static System.Collections.Generic.IEnumerable<Neo.ApplicationFramework.Interfaces.Tag.IBasicTag> GetAllComponentTags()
		{   var properties = GetProperties(Globals.Tags.GlobalDataItems);
			var properties2 = GetProperties(Globals.Tags);
			string test = "";
			var tagList = from theElement in Globals.Tags.GetType().GetFields()
					where theElement.Name.ToString().Contains("Component") && (theElement.FieldType.ToString().Contains("LightweightTag") ||  theElement.FieldType.ToString().Contains("GlobalDataItem"))
					select (IBasicTag)theElement.GetValue(Globals.Tags);
			return tagList;
		}

		private static PropertyInfo[] GetProperties(object obj)
		{
			return obj.GetType().GetProperties();
		}
		private void genMessage(PropertyInfo[] z)
		{
			string output = "";
			foreach (var p in z)
			{
				output = output+ "Name: " + p.Name.ToString() + Environment.NewLine +", memType: "+ p.MemberType.ToString() + ", decType: " + p.DeclaringType+ Environment.NewLine + ", Attributes: " + p.Attributes.ToString() + Environment.NewLine + Environment.NewLine;
			}
			//Console.WriteLine(output);
			//MessageBox.Show(output);
		}
	}
}
