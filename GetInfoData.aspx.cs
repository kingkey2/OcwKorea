using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using System.Collections;

public partial class GetInfoData : System.Web.UI.Page
{
    public string GetInfoData2(string InfoID)
    {
        int AppID = 0;
        InfoData iInfoData;
        string JsonStr = string.Empty;
        string ReturnStr = string.Empty;
        string InfoDataStr = string.Empty;
        string InfoAccountStr = string.Empty;
        string InfoAccount = string.Empty;
        string[] InfoDataStrArr;
        string[] InfoAccountArr;
        string[] stringSeparators = new string[] { "\r\n" };
        DateTime InfoDate = DateTime.Now.AddHours(9);
        ArrayList RetInfoArr = new ArrayList();
        Random rnd = new Random();
        Newtonsoft.Json.Linq.JObject Jobj = new Newtonsoft.Json.Linq.JObject();

        if (System.IO.Directory.Exists(Server.MapPath("/Files/InfoData")) == false)
        {
            Application["AppID"] = 0;
            Application["AppDate"] = DateTime.Now.ToString("yyyy/MM/dd");
        }


        try
        {
            if (Application["AppDate"].ToString() != DateTime.Now.ToString("yyyy/MM/dd"))
            {
                Application["AppID"] = 0;
                Application["AppDate"] = DateTime.Now.ToString("yyyy/MM/dd");
                System.IO.File.Delete(Server.MapPath("/Files/InfoData") + "/InfoData.txt");
            }

            
        }
        catch (Exception ex)
        {
            Application["AppID"] = 0;
            Application["AppDate"] = DateTime.Now.ToString("yyyy/MM/dd");
            System.IO.File.Delete(Server.MapPath("/Files/InfoData") + "/InfoData.txt");

        }

        if (System.IO.Directory.Exists(Server.MapPath("/Files/InfoData")) == false)
        {
            System.IO.Directory.CreateDirectory(Server.MapPath("/Files/InfoData"));
        }

        Application.Lock();
        try
        {
            if (System.IO.File.Exists(Server.MapPath("/Files/InfoData") + "/InfoData.txt") == false)
            {
                InfoID = "0";

                InfoAccountStr = System.IO.File.ReadAllText(Server.MapPath("/App_Data") + "/InfoAccount.txt");
                InfoAccountArr = InfoAccountStr.Split(stringSeparators, StringSplitOptions.None);
                for (var i = 0; i < 2500; i++)
                {

                    AppID++;

                    InfoAccount = InfoAccountArr[rnd.Next(0, InfoAccountArr.Length - 1)];
                    InfoAccount = InfoAccount + "**" + rnd.Next(0, 9);

                    iInfoData = new InfoData();
                    iInfoData.InfoID = AppID;
                    iInfoData.InfoDate = InfoDate.ToString("yyyy/MM/dd HH:mm:ss");
                    iInfoData.InfoAccount = InfoAccount;
                    iInfoData.InfoAmount = Convert.ToInt32(rnd.Next(10, 100).ToString() + "00000");

                    InfoDataStr += Newtonsoft.Json.JsonConvert.SerializeObject(iInfoData) + Environment.NewLine;
                    InfoDate = InfoDate.AddSeconds(rnd.Next(20, 60));
                }

                System.IO.File.AppendAllText(Server.MapPath("/Files/InfoData") + "/InfoData.txt", InfoDataStr);

            }

        }
        catch (Exception ex) { }
        finally
        {
            Application.UnLock();
        }




        if (System.IO.File.Exists(Server.MapPath("/Files/InfoData") + "/InfoData.txt") == true)
        {
            InfoDataStr = string.Empty;
            InfoDataStr = System.IO.File.ReadAllText(Server.MapPath("/Files/InfoData") + "/InfoData.txt");

            InfoDataStrArr = InfoDataStr.Split(stringSeparators, StringSplitOptions.None);

            if (InfoDataStrArr.Length > (Convert.ToInt32(InfoID) + 1))
            {
                for (var i = (InfoDataStrArr.Length - 1); i >= 0; i--)
                {
                    if (Convert.ToInt32(InfoID) == 0)
                    {
                        JsonStr = InfoDataStrArr[i];
                        if (string.IsNullOrEmpty(JsonStr) == false)
                        {
                            Jobj = Newtonsoft.Json.Linq.JObject.Parse(JsonStr);

                            if (Convert.ToDateTime(Jobj["InfoDate"]) < DateTime.Now.AddHours(9))
                            {
                                iInfoData = new InfoData();
                                iInfoData.InfoID = Convert.ToInt32(Jobj["InfoID"]);
                                iInfoData.InfoDate = Jobj["InfoDate"].ToString();
                                iInfoData.InfoAccount = Jobj["InfoAccount"].ToString();
                                iInfoData.InfoAmount = Convert.ToInt32(Jobj["InfoAmount"]);

                                RetInfoArr.Add(iInfoData);
                                

                                if (RetInfoArr.Count > 2) {
                                    break;
                                }
                            }
                        }

                    }
                    else
                    {
                        if (i >= Convert.ToInt32(InfoID))
                        {
                            JsonStr = InfoDataStrArr[i];
                            if (string.IsNullOrEmpty(JsonStr) == false)
                            {
                                Jobj = Newtonsoft.Json.Linq.JObject.Parse(JsonStr);

                                if (Convert.ToInt32(Jobj["InfoID"]) > Convert.ToInt32(InfoID))
                                {
                                    if (Convert.ToDateTime(Jobj["InfoDate"]) < DateTime.Now.AddHours(9))
                                    {
                                        iInfoData = new InfoData();
                                        iInfoData.InfoID = Convert.ToInt32(Jobj["InfoID"]);
                                        iInfoData.InfoDate = Jobj["InfoDate"].ToString();
                                        iInfoData.InfoAccount = Jobj["InfoAccount"].ToString();
                                        iInfoData.InfoAmount = Convert.ToInt32(Jobj["InfoAmount"]);

                                        RetInfoArr.Add(iInfoData);
                                    }
                                }
                            }
                        }
                        else
                        {
                            break;
                        }

                    }
                }
            }
            else
            {
                iInfoData = new InfoData();
                iInfoData.InfoID = 0;

                RetInfoArr.Add(iInfoData);
            }
        }

        if (RetInfoArr.Count > 0)
        {
            ReturnStr = Newtonsoft.Json.JsonConvert.SerializeObject(RetInfoArr);
        }

        return ReturnStr;
    }


}

public class InfoData
{
    public int InfoID { get; set; }
    public string InfoDate { get; set; }
    public string InfoAccount { get; set; }
    public int InfoAmount { get; set; }
}
