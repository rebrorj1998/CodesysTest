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
    
    
    public partial class IO_P1
    {
		
		void Button_Click(System.Object sender, System.EventArgs e)
		{
			if(Globals.Tags.IO_Page_Index.Value<2)
			{
				Globals.Tags.IO_Page_Index.IncrementAnalog(1);
			}
			else
			{
				Globals.Tags.IO_Page_Index.Value = 1;
			}
			switch(Globals.Tags.IO_Page_Index.Value.Int)
			{
				case 1:
					Globals.IO_P1.Inputs0.Show();
					break;
				case 2:
					Globals.IO_P1.Outputs0.Show();
					break;

				case 3
					:
					Globals.IO_P1.Inputs1.Show();
					break;
			}		
			
		}
		
		void Button1_Click(System.Object sender, System.EventArgs e)
		{
			if(Globals.Tags.IO_Page_Index.Value>1)
			{
				Globals.Tags.IO_Page_Index.DecrementAnalog(1);
			}
			else
			{
				Globals.Tags.IO_Page_Index.Value = 2;
			}

			switch(Globals.Tags.IO_Page_Index.Value.Int)
			{
				case 1:
					Globals.IO_P1.Inputs0.Show();
					break;
				case 2:
					Globals.IO_P1.Outputs0.Show();
					break;

				case 3
					:
					Globals.IO_P1.Inputs1.Show();
					break;
			}		
		}
		
		void IO_P1_Opened(System.Object sender, System.ComponentModel.CancelEventArgs e)
		{
			
		}
		
    }
}
