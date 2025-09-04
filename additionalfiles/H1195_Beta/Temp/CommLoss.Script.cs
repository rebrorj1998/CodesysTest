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
    
    
    public partial class CommLoss
    {
		
		void CommLoss_Opened(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.commsLoss.ValueChange += commLoss;	
		}
		void commLoss(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			if((bool)e.Value)
			{
				Globals.Tags.commsLoss.ValueChange -= commLoss;
				this.Close();
			}
		}
		
		void CommLoss_Closing(System.Object sender, System.ComponentModel.CancelEventArgs e)
		{
			Globals.Tags.commsLoss.ValueChange -= commLoss;
			Globals.Tags.commsLossdelay.SetAnalog(0);
			Globals.Tags.commsLoss.ResetTag();
		}
		
		void CommLoss_Closed(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.commsLoss.ValueChange -= commLoss;
			Globals.Tags.commsLossdelay.SetAnalog(0);
			Globals.Tags.commsLoss.ResetTag();
		}
    }
}
