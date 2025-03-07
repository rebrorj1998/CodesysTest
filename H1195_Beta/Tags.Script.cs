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
    
    
    public partial class Tags
    {	
		void IO_Page_Index_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			switch(Globals.Tags.IO_Page_Index.Value.Int)
			{
				case 1:
					IO_Alias_Title.Value = "Inputs I0:";
					break;
				case 2:
					IO_Alias_Title.Value = "Outputs I0:";
					break;
				case 3:
					IO_Alias_Title.Value = "Inputs I1:";
					break;
			}	
			
			
		}
		
		void Fault_Instance_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			if(Fault_Instance.Value > 49)
			{
				Fault_Instance.SetAnalog(0);
				}			
			if(Fault_Instance.Value < 0)
			{
				Fault_Instance.SetAnalog(49);
			}
			if(49 > Fault_Instance.Value >0)
			{
				Globals.Faults["Page_"+Fault_Instance.Value.ToString()].Show();
			}
			
		}
		
		void commsLoss_ValueOn(System.Object sender, System.EventArgs e)
		{
			//Globals.CommLoss.Show();
			
		}
		
		void commsLoss_ValueOff(System.Object sender, System.EventArgs e)
		{
			//Globals.CommLoss.Close();
		}
		

    }
}
