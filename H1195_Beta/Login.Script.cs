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
    
    
    public partial class Login
    {
		void Login_Opened(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.Password.SetAnalog(0);
			Globals.Tags.Password.ValueChange += new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(attemptLogin);
		}
		void Button_Click(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.Password.ValueChange -= new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(attemptLogin);
			Globals.Tags.Password.SetAnalog(0);
			this.Close();
		}
		void attemptLogin(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Globals.Tags.Password.ValueChange -= new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(attemptLogin);
			Globals.Security.Login(TouchComboBox.Text, Globals.Tags.Password.Value, false, true);
			Globals.Tags.Password.SetAnalog(0);
			this.Close();
		}
		
		void Login_Closed(System.Object sender, System.EventArgs e)
		{
			
			Globals.Tags.Password.ValueChange -= new System.EventHandler<Core.Api.DataSource.ValueChangedEventArgs>(attemptLogin);
			Globals.Tags.Password.SetAnalog(0);
		}
		

    }
}
