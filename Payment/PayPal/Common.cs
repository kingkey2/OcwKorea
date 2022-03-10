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
    public static string SettingFile = "PayPalSetting.json";

    public dynamic PayPalSetting;
    public dynamic ExchangeRateSetting;

    public Common()
    {
        //
        // TODO: 在這裡新增建構函式邏輯
        //
    }

    public APIResult GetPaypalToken()
    {
        PayPalSetting = LoadSetting();
        APIResult result = new APIResult();
        Newtonsoft.Json.Linq.JObject returnResult;
        JObject jsonContent = new JObject();
        string GetTokenURL = PayPalSetting.ApiUrl + "/v1/oauth2/token";

        jsonContent.Add("grant_type", "client_credentials");

        returnResult = CodingControl.GetWebJSONContent(GetTokenURL, "POST", "grant_type=client_credentials", GetTokenHeaderString(PayPalSetting.Username.ToString(), PayPalSetting.Password.ToString()), "application/x-www-form-urlencoded");

        try {
            if (returnResult["access_token"] != null) {
                result.ResultState = APIResult.enumResultCode.OK;
                result.Message = returnResult["access_token"].ToString();
            } else {
                result.ResultState = APIResult.enumResultCode.ERR;
                result.Message = "No token";
            }
        } catch (RuntimeBinderException) {

            result.ResultState = APIResult.enumResultCode.ERR;
            result.Message = "GetToken Error";
        }

        return result;
    }

    public PaypalStatusResult CheckPaypalStatus(string PayPalOrderID, string PaypalToken)
    {
        PaypalStatusResult result = new PaypalStatusResult();
        Newtonsoft.Json.Linq.JObject returnResult;
        string GetTokenURL = PayPalSetting.ApiUrl + "/v2/checkout/orders/" + PayPalOrderID;

        returnResult = CodingControl.GetWebJSONContent(GetTokenURL, "GET", "", GetHeaderString(PaypalToken));

        try {
            if (returnResult["id"] != null) {
                string TransactionID = returnResult["id"].ToString();

                if (TransactionID == PayPalOrderID) {
                    JArray PaymenDetail = JArray.FromObject(returnResult["purchase_units"]);
                    decimal OrderAmount = (decimal)PaymenDetail[0]["amount"].SelectToken("value");
                    string OrderDate = DateTime.Parse(returnResult["create_time"].ToString()).AddHours(8).ToString();

                    if (returnResult["status"].ToString() == "COMPLETED") {
                        result.ResultState = APIResult.enumResultCode.OK;
                        result.OrderAmount = OrderAmount;
                        result.OrderDate = OrderDate;
                        result.IsSuccess = true;
                    } else {
                        result.ResultState = APIResult.enumResultCode.OK;
                        result.OrderAmount = OrderAmount;
                        result.OrderDate = OrderDate;
                        result.IsSuccess = false;
                    }
                } else {
                    result.ResultState = APIResult.enumResultCode.ERR;
                    result.Message = "PayPalOrderID err";
                }
            } else {
                result.ResultState = APIResult.enumResultCode.ERR;
                result.Message = "No id";
            }
        } catch (RuntimeBinderException) {

            result.ResultState = APIResult.enumResultCode.ERR;
            result.Message = "CheckPaymentState Error";
        }

        return result;
    }

    public PaypalStatusResult CapturePayment(string PayPalOrderID, string PaypalToken) {
        PaypalStatusResult result = new PaypalStatusResult();
        PaypalStatusResult ConfirmEWinPaymentresult = new PaypalStatusResult();
        Newtonsoft.Json.Linq.JObject returnResult;
        string GetTokenURL = PayPalSetting.ApiUrl + "/v2/checkout/orders/" + PayPalOrderID + "/capture";

        returnResult = CodingControl.GetWebJSONContent(GetTokenURL, "POST", "", GetHeaderString(PaypalToken));

        try {
            if (returnResult["id"] != null) {
                string TransactionID = returnResult["id"].ToString();

                if (TransactionID == PayPalOrderID) {
                    JArray PaymenDetail = JArray.FromObject(returnResult["purchase_units"]);
                    decimal OrderAmount = (decimal)PaymenDetail[0]["payments"].SelectToken("captures")[0]["amount"]["value"];
                    string OrderDate = DateTime.Parse(PaymenDetail[0]["payments"].SelectToken("captures")[0]["update_time"].ToString()).AddHours(8).ToString();

                    if (returnResult["status"].ToString() == "COMPLETED") {

                        result.ResultState = PaypalStatusResult.enumResultCode.OK;
                        result.Message = returnResult.ToString();
                        result.OrderAmount = OrderAmount;
                        result.OrderDate = OrderDate;
                        result.IsSuccess = true;
                    } else {
                        result.ResultState = PaypalStatusResult.enumResultCode.ERR;
                        result.Message = "用戶未付款";
                    }
                } else {
                    result.ResultState = PaypalStatusResult.enumResultCode.ERR;
                    result.Message = "PayPalOrderID err";
                }
            } else {
                result.ResultState = PaypalStatusResult.enumResultCode.ERR;
                result.Message = "No id";
            }
        } catch (RuntimeBinderException) {

            result.ResultState = PaypalStatusResult.enumResultCode.ERR;
            result.Message = "CheckPaymentState Error";
        }

        return result;
    }

    private string GetTokenHeaderString(string Username, string Password)
    {
        string Ret;
        string HeaderStr = CodingControl.Base64URLEncode(Username + ":" + Password);

        Ret = "Authorization:Basic " + HeaderStr;
        return Ret;
    }

    private string GetHeaderString(string HeaderStr)
    {
        string Ret;

        Ret = "Authorization:Bearer " + HeaderStr;
        return Ret;
    }

    private string GetEWinToken()
    {
        string Token;
        int RValue;
        Random R = new Random();
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        return Token;
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