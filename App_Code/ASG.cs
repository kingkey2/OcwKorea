using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// EWin 的摘要描述
/// </summary>
public static class ASG
{
    public static string CompanyCode = System.Configuration.ConfigurationManager.AppSettings["CompanyCode"];
    public static string APIKey = System.Configuration.ConfigurationManager.AppSettings["APIKey"];
    public static string PrivateKey = System.Configuration.ConfigurationManager.AppSettings["PrivateKey"];

    public static string CreateToken(string PrivateKey, string ApiKey, string RandomValue) {
        string Token;

        Token = RandomValue + "_" + ApiKey + "_" + CalcURLToken(PrivateKey, ApiKey, RandomValue);

        return Token;
    }

    public static string CalcURLToken(string PrivateKey, string ApiKey, string RandomValue)
    {
        System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create();
        byte[] hash = null;
        string Source = RandomValue + ":" + ApiKey + ":" + PrivateKey.ToUpper();
        System.Text.StringBuilder RetValue = new System.Text.StringBuilder();

        hash = md5.ComputeHash(System.Text.Encoding.Default.GetBytes(Source));
        md5 = null;

        foreach (byte EachByte in hash)
        {
            string ByteStr = EachByte.ToString("x");

            ByteStr = new string('0', 2 - ByteStr.Length) + ByteStr;
            RetValue.Append(ByteStr);
        }

        return RetValue.ToString();
    }

    public static void AlertMessage(string Content, string ReturnURL = "")
    {
        bool IsJS = false;
        string JSCode = "";

        HttpContext.Current.Response.ClearContent();
        HttpContext.Current.Response.Write("<Script Language=\"JavaScript\">");
        HttpContext.Current.Response.Write("alert(\"" + CodingControl.JSEncodeString(Content) + "\");");

        if (ReturnURL.Length >= 11)
        {
            if (ReturnURL.Substring(0, 11).ToUpper() == "JavaScript:".ToUpper())
            {
                IsJS = true;
                JSCode = ReturnURL.Substring(11);
            }
        }

        if (IsJS == false)
        {
            if (string.IsNullOrEmpty(ReturnURL))
            {
                HttpContext.Current.Response.Write("window.history.back (1);");
            }
            else
            {
                HttpContext.Current.Response.Write("window.location.href=\"" + ReturnURL + "\";");
            }
        }
        else
        {
            HttpContext.Current.Response.Write(JSCode);
        }

        HttpContext.Current.Response.Write("</Script>");
        HttpContext.Current.Response.Flush();
        HttpContext.Current.Response.End();
    }

}