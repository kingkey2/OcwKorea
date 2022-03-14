using Microsoft.CSharp.RuntimeBinder;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Common 的摘要描述
/// </summary>
public partial class Common : System.Web.UI.Page
{
    public static string SettingFile = "EPAYSetting.json";

    public static dynamic EPaySetting;
 
    public Common()
    {
        //
        // TODO: 在這裡新增建構函式邏輯
        //
    }

    public static dynamic ParseData(string PostBody) {
        dynamic BodyObj=null;
        try { BodyObj = Newtonsoft.Json.JsonConvert.DeserializeObject(PostBody); } catch (Exception ex) { }
        return BodyObj;
    }

    public static bool CheckInIP(string CheckIP) {
        bool checkbool = false;
        EPaySetting = LoadSetting();
        var ProviderIP = (Newtonsoft.Json.Linq.JArray)EPaySetting.ProviderIP;
        if (ProviderIP.Contains(CheckIP))
        {
            checkbool = true;
        }
        return checkbool;
    }

    public static bool CheckSign(dynamic Data)
    {
        bool checkbool = false;
        EPaySetting = LoadSetting();
        string Sign= GetGPaySign((string)Data.OrderID,decimal.Parse((string)Data.PayingAmount),(DateTime)Data.OrderDate, (string)Data.Service, (string)Data.Currency, (string)EPaySetting.CompanyCode, (string)EPaySetting.ApiKey);

        if (Sign== (string)Data.Sign)
        {
            checkbool = true;
        }
        return checkbool;
    }

    public static string GetSHA256(string DataString, bool Base64Encoding = true)
    {
        return GetSHA256(System.Text.Encoding.UTF8.GetBytes(DataString), Base64Encoding);
    }

    public static string GetSHA256(byte[] Data, bool Base64Encoding = true)
    {
        System.Security.Cryptography.SHA256 SHA256Provider = new System.Security.Cryptography.SHA256CryptoServiceProvider();
        byte[] hash;
        System.Text.StringBuilder RetValue = new System.Text.StringBuilder();

        hash = SHA256Provider.ComputeHash(Data);
        SHA256Provider = null;

        if (Base64Encoding)
        {
            RetValue.Append(System.Convert.ToBase64String(hash));
        }
        else
        {
            foreach (byte EachByte in hash)
            {
                // => .ToString("x2")
                string ByteStr = EachByte.ToString("x");

                ByteStr = new string('0', 2 - ByteStr.Length) + ByteStr;
                RetValue.Append(ByteStr);
            }
        }


        return RetValue.ToString();
    }

    public static string GetGPaySign(string OrderID, decimal OrderAmount, DateTime OrderDateTime, string ServiceType, string CurrencyType, string CompanyCode, string CompanyKey)
    {
        string sign;
        string signStr = "ManageCode=" + CompanyCode;
        signStr += "&Currency=" + CurrencyType;
        signStr += "&Service=" + ServiceType;
        signStr += "&OrderID=" + OrderID;
        signStr += "&OrderAmount=" + OrderAmount.ToString("#.##");
        signStr += "&OrderDate=" + OrderDateTime.ToString("yyyy-MM-dd HH:mm:ss");
        signStr += "&CompanyKey=" + CompanyKey;

        sign = GetSHA256(signStr, false).ToUpper();

        return sign;
    }
    
    private static dynamic LoadSetting()
    {
        dynamic o = null;
        string Filename;

        if (EWinWeb.IsTestSite) {
            Filename = HttpContext.Current.Server.MapPath("Test_" + SettingFile);
        } else {
            Filename = HttpContext.Current.Server.MapPath("Formal_" + SettingFile);
        }

        if (System.IO.File.Exists(Filename)) {
            string SettingContent;

            SettingContent = System.IO.File.ReadAllText(Filename);

            if (string.IsNullOrEmpty(SettingContent) == false) {
                try { o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent); } catch (Exception ex) { }
            }
        }

        return o;
    }

    public class PaypalStatusResult : APIResult
    {
        public decimal OrderAmount { get; set; }
        public string OrderDate { get; set; }
        public bool IsSuccess { get; set; }
    }

    public class APIResult
    {
        public enum enumResultCode
        {
            OK = 0,
            ERR = 1
        }

        public enumResultCode ResultState { get; set; }
        public string GUID { get; set; }
        public string Message { get; set; }
    }

}