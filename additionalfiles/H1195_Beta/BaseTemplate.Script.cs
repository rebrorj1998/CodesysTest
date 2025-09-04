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

    
	
    
    public partial class BaseTemplate
    {
		int mouse_last_x = 0;
		int mouse_last_y =0 ;
		int count=0;
		bool t_out_start = false;
		void BaseTemplate_Opened(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.SystemTagSecond.ValueChange += new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(TimeOut);

		}

		void TimeOut(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{	

			if(System.Math.Abs(Control.MousePosition.X-mouse_last_x)>1 || System.Math.Abs(Control.MousePosition.Y-mouse_last_y)>1 )
			{
				mouse_last_x =Control.MousePosition.X;
				mouse_last_y=Control.MousePosition.Y;
				count =0;
			}
			else
			{
				Globals.Tags.watch_me.Value= count;
				if(Globals.Tags.SystemTagCurrentUser.Value.ToString() != "")
				{
					if(t_out_start)
					{
						count+=1;
						
						if(count >= Globals.Tags.logout_delay.Value)
						{
						//	Globals.Security.Logout(false);
							t_out_start = false;
							mouse_last_y = 0;
							mouse_last_x = 0;
						}
					}
					else
					{

						t_out_start = true;
						count =0;
					}
				}
				else
				{
					count = 0;
				}
			}
		}
		
		void BaseTemplate_Closing(System.Object sender, System.ComponentModel.CancelEventArgs e)
		{
			Globals.Tags.SystemTagSecond.ValueChange -= new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(TimeOut);
		}
		
		void BaseTemplate_Closed(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.SystemTagSecond.ValueChange -= new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(TimeOut);
		}
		
		void Button4_Click(System.Object sender, System.EventArgs e)
		{
			
		}
		

    }
}
