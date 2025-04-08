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
	using System.Linq;
	using System.Collections.Generic;
    
    public partial class Status
    {
		System.Collections.Generic.IEnumerable<Neo.ApplicationFramework.Interfaces.Tag.IBasicTag> ActiveTagList;
		System.Collections.Generic.IEnumerable<Neo.ApplicationFramework.Interfaces.Tag.IBasicTag> AllTagList;
		int skipCount = 0;
		int skipTot = 0;
		int indexCount = 0;
		
		void Status_Opened(System.Object sender, System.EventArgs e)
		{
			Globals.Tags.StatusInstance.ValueChange += Status_Instance_ValueChange;
//			AllTagList = Helper.GetAllComponentTags();
			HIDEME.Visible = false;			
			Hook_Up_Tags();
		}
		void Hook_Up_Tags()
		{
			skipCount = 0;
			indexCount = 0;
			skipTot = (Globals.Tags.StatusInstance.Value.Int-1)*6;
			ActiveTagList = null;
			ActiveTagList = Helper.GetActiveComponentTags();
			//MessageBox.Show(skipTot.ToString());
			try
			{
				List<string> indexList = new List<string>();
				//MessageBox.Show("made a list Good");
				foreach (IBasicTag tag in ActiveTagList)
				{
					string endostr = tag.Name.Split('_').Last();
					if (! indexList.Contains(endostr))
					{
						if (endostr.Length < 4)
						{
							indexList.Add(endostr);
						}
					}
				}
				Globals.Tags.Application_GlobalObjects_CollectionOfComponents_TotalObjects.SetAnalog(indexList.Count());
				//MessageBox.Show(skipTot.ToString());
				foreach (string index in indexList)
				{
					if(skipCount >= skipTot)
					{ 
						if (indexCount < 6)
						{
							//MessageBox.Show("made into for loop " + index);
							IBasicTag tempName = ActiveTagList.Single(item => item.Name.EndsWith("ObjNames_"+index));
							//MessageBox.Show("tempName Good");
							IBasicTag tempStatus = ActiveTagList.Single(item => item.Name.EndsWith("ActiveState_"+index));
							//MessageBox.Show("tempStatus Good");
							IBasicTag tempReady = ActiveTagList.Single(item => item.Name.EndsWith("Ready_"+index));
							//MessageBox.Show("tempReady Good");
						
							switch(indexCount)
							{
								case 0:
									tempName.ValueChange += Row_0_Name_ValueChange;
									tempStatus.ValueChange += Row_0_Status_ValueChange;
									tempReady.ValueChange += Row_0_Ready_ValueChange;
									Name_0.Text = tempName.Value.ToString();
									Status_0.Text = tempStatus.Value.ToString();
									Ready_0.Text = tempReady.Value.ToString();
									break;
								case 1:
									tempName.ValueChange += Row_1_Name_ValueChange;
									tempStatus.ValueChange += Row_1_Status_ValueChange;
									tempReady.ValueChange += Row_1_Ready_ValueChange;
									Name_1.Text = tempName.Value.ToString();
									Status_1.Text = tempStatus.Value.ToString();
									Ready_1.Text = tempReady.Value.ToString();
									break;
								case 2:
									tempName.ValueChange += Row_2_Name_ValueChange;
									tempStatus.ValueChange += Row_2_Status_ValueChange;
									tempReady.ValueChange += Row_2_Ready_ValueChange;
									Name_2.Text = tempName.Value.ToString();
									Status_2.Text = tempStatus.Value.ToString();
									Ready_2.Text = tempReady.Value.ToString();
									break;
								case 3:
									tempName.ValueChange += Row_3_Name_ValueChange;
									tempStatus.ValueChange += Row_3_Status_ValueChange;
									tempReady.ValueChange += Row_3_Ready_ValueChange;
									Name_3.Text = tempName.Value.ToString();
									Status_3.Text = tempStatus.Value.ToString();
									Ready_3.Text = tempReady.Value.ToString();
									break;
								case 4:
									tempName.ValueChange += Row_4_Name_ValueChange;
									tempStatus.ValueChange += Row_4_Status_ValueChange;
									tempReady.ValueChange += Row_4_Ready_ValueChange;
									Name_4.Text = tempName.Value.ToString();
									Status_4.Text = tempStatus.Value.ToString();
									Ready_4.Text = tempReady.Value.ToString();
									break;
								case 5:
									tempName.ValueChange += Row_5_Name_ValueChange;
									tempStatus.ValueChange += Row_5_Status_ValueChange;
									tempReady.ValueChange += Row_5_Ready_ValueChange;
									Name_5.Text = tempName.Value.ToString();
									Status_5.Text = tempStatus.Value.ToString();
									Ready_5.Text = tempReady.Value.ToString();
									break;
								default:
									break;
							}
							indexCount +=1;
						}
						
					}
					else
					{
						skipCount += 1;
						indexCount = 0;
					}
					//MessageBox.Show(index);
				}
			}
			catch (Exception e)
			{
				MessageBox.Show(e.Message);
				//continue;
			}
		}
		void unHook_Tags()
		{
			
			foreach (IBasicTag tag in ActiveTagList)
			{
				tag.ValueChange -= Row_0_Name_ValueChange;
				tag.ValueChange -= Row_0_Status_ValueChange;
				tag.ValueChange -= Row_0_Ready_ValueChange;
				tag.ValueChange -= Row_1_Name_ValueChange;
				tag.ValueChange -= Row_1_Status_ValueChange;
				tag.ValueChange -= Row_1_Ready_ValueChange;
				tag.ValueChange -= Row_2_Name_ValueChange;
				tag.ValueChange -= Row_2_Status_ValueChange;
				tag.ValueChange -= Row_2_Ready_ValueChange;
				tag.ValueChange -= Row_3_Name_ValueChange;
				tag.ValueChange -= Row_3_Status_ValueChange;
				tag.ValueChange -= Row_3_Ready_ValueChange;
				tag.ValueChange -= Row_4_Name_ValueChange;
				tag.ValueChange -= Row_4_Status_ValueChange;
				tag.ValueChange -= Row_4_Ready_ValueChange;
				tag.ValueChange -= Row_5_Name_ValueChange;
				tag.ValueChange -= Row_5_Status_ValueChange;
				tag.ValueChange -= Row_5_Ready_ValueChange;
				Name_0.Text = "";
				Status_0.Text = "";
				Ready_0.Text = "";
				Name_1.Text = "";
				Status_1.Text = "";
				Ready_1.Text = "";
				Name_2.Text = "";
				Status_2.Text = "";
				Ready_2.Text = "";
				Name_3.Text = "";
				Status_3.Text = "";
				Ready_3.Text = "";
				Name_4.Text = "";
				Status_4.Text = "";
				Ready_4.Text = "";
				Name_5.Text = "";
				Status_5.Text = "";
				Ready_5.Text = "";
			}

		}
		void Status_Closing(System.Object sender, System.ComponentModel.CancelEventArgs e)
		{
			unHook_Tags();
			Globals.Tags.StatusInstance.ValueChange -= Status_Instance_ValueChange;
		}
		
		void Status_Closed(System.Object sender, System.EventArgs e)
		{
			unHook_Tags();
			Globals.Tags.StatusInstance.ValueChange -= Status_Instance_ValueChange;
		}
		void Status_Instance_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			//MessageBox.Show("stat int Val change");
			unHook_Tags();
			Hook_Up_Tags();
		}
		void Row_0_Name_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Name_0.Text = e.Value.ToString();
		}
		void Row_0_Status_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Status_0.Text = e.Value.ToString();
		}
		void Row_0_Ready_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Ready_0.Text = e.Value.ToString();
		}
		void Row_1_Name_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Name_1.Text = e.Value.ToString();
		}
		void Row_1_Status_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Status_1.Text = e.Value.ToString();
		}
		void Row_1_Ready_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Ready_1.Text = e.Value.ToString();
		}
		void Row_2_Name_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Name_2.Text = e.Value.ToString();
		}
		void Row_2_Status_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Status_2.Text = e.Value.ToString();
		}
		void Row_2_Ready_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Ready_2.Text = e.Value.ToString();
		}
		void Row_3_Name_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Name_3.Text = e.Value.ToString();
		}
		void Row_3_Status_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Status_3.Text = e.Value.ToString();
		}
		void Row_3_Ready_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Ready_3.Text = e.Value.ToString();
		}
		void Row_4_Name_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Name_4.Text = e.Value.ToString();
		}
		void Row_4_Status_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Status_4.Text = e.Value.ToString();
		}
		void Row_4_Ready_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Ready_4.Text = e.Value.ToString();
		}
		void Row_5_Name_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Name_5.Text = e.Value.ToString();
		}
		void Row_5_Status_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Status_5.Text = e.Value.ToString();
		}
		void Row_5_Ready_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			Ready_5.Text = e.Value.ToString();
		}
		void TotObs_ValueChange(System.Object sender, Core.Api.DataSource.ValueChangedEventArgs e)
		{
			
		}
		
		void Button2_Click(System.Object sender, System.EventArgs e)
		{
			if (Globals.Tags.StatusInstance.Value -1  > 0)
			{
				Globals.Tags.StatusInstance.DecrementAnalog(1);
			}

			
		}
		
		void Button3_Click(System.Object sender, System.EventArgs e)
		{

			//MessageBox.Show((Globals.Tags.StatusInstance.Value * 6).ToString());
			if (Globals.Tags.StatusInstance.Value * 6 < Globals.Tags.Application_GlobalObjects_CollectionOfComponents_TotalObjects.Value)
			{
				Globals.Tags.StatusInstance.IncrementAnalog(1);
			}
		}

    }
}
