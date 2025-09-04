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
	using Neo.ApplicationFramework.Interfaces.Tag;
    
	
    public partial class Dashboard
    {
		int testint = 0;
		
		void test()
		{
			//Globals.Tags.Application_GlobalObjects_CollectionofComponents_ActiveState_0.Value.Bool
		}
		
		void Button4_Click(System.Object sender, System.EventArgs e)
		{
			Globals.Status.Show();
		}
		
		
		void Dashboard_Opened(System.Object sender, System.EventArgs e)

		{

			if (Globals.Tags.LangStartup.Value == false)

			{
			
				var lang = Globals.Tags.Language_Selector.Value;

				Globals.Tags.Language_Selector.Value = 0;

				Globals.Tags.Language_Selector.Value = lang;

				Globals.Tags.LangStartup.Value = true;
				
			}

		}
    }
}
