using Microsoft.CSharp.RuntimeBinder;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Payment 的摘要描述
/// </summary>
public class Payment {
    public Payment() {
        //
        // TODO: 在這裡新增建構函式邏輯
        //
    }

    public static class PayPal {
        public static string SettingFile = "PayPalSetting.json";

        public static dynamic PayPalSetting;
        public static dynamic ExchangeRateSetting;

        public static APIResult CreatePayPalPayment(string CurrencyType, decimal Amount, string Lang, string OrderNumber) {
            PayPalSetting = LoadSetting();
            APIResult result = new APIResult();
            APIResult result_token = new APIResult();
            string PayPalToken;

            result_token = GetToken();

            if (result_token.ResultState==  APIResult.enumResultCode.OK) {
                PayPalToken = result_token.Message;
                result = CreatePayment(CurrencyType, Amount, PayPalToken, Lang, OrderNumber);
            } else {
                result.ResultState = APIResult.enumResultCode.ERR;
                result.Message = result_token.Message;
            }

            return result;
        }

        private static APIResult GetToken() {
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

        private static APIResult CreatePayment(string CurrencyType, decimal Amount, string PaypalToken, string Lang, string OrderNumber) {
            PayPalSetting = LoadSetting();
            APIResult result = new APIResult() { ResultState = APIResult.enumResultCode.ERR};
            JObject returnResult;
            JObject jsonContent = new JObject();
            JObject application_context = new JObject();
            JArray purchase_units = new JArray();
            JObject amount = new JObject();
            JObject amount1 = new JObject();
            JObject returnMsg = new JObject();
            string PayPalLang;

            switch (Lang) {
                case "CHT":
                    PayPalLang = "zh-TW";
                    break;
                case "CHS":
                    PayPalLang = "zh-CN";
                    break;
                case "JPN":
                    PayPalLang = "ja-JP";
                    break;
                default:
                    PayPalLang = "ja-JP";
                    break;
            }

            string GetTokenURL = PayPalSetting.ApiUrl + "/v2/checkout/orders";

            amount1.Add("currency_code", CurrencyType);
            amount1.Add("value", (int)(Math.Ceiling(Amount)));
            amount.Add("amount", amount1);
            purchase_units.Add(amount);

            application_context.Add("locale", PayPalLang);
            application_context.Add("landing_page", "BILLING");
            application_context.Add("user_action", "CONTINUE");
            application_context.Add("return_url", EWinWeb.CasinoWorldUrl + "/Payment/PayPal/PaymentSuccessCallback.aspx?OrderNumber=" + OrderNumber);
            application_context.Add("cancel_url", EWinWeb.CasinoWorldUrl + "/Payment/PayPal/PaymentCancelCallback.aspx?OrderNumber=" + OrderNumber);

            jsonContent.Add("intent", "CAPTURE");
            jsonContent.Add("purchase_units", purchase_units);
            jsonContent.Add("application_context", application_context);

            returnResult = CodingControl.GetWebJSONContent(GetTokenURL, "POST", jsonContent.ToString(), GetHeaderString(PaypalToken));

            try {
                if (returnResult["id"] != null) {
                    string TransactionID = returnResult["id"].ToString();
                    var ret_jobject = JObject.Parse(returnResult.ToString());

                    if (ret_jobject["links"] != null) {

                        var link_jarray = JArray.FromObject(ret_jobject["links"]);

                        for (int i = 0; i < link_jarray.Count; i++) {
                            if (link_jarray[i]["rel"].ToString() == "approve") {
                                result.ResultState = APIResult.enumResultCode.OK;
                                returnMsg["PayPalTransactionID"] = TransactionID;
                                returnMsg["href"] = link_jarray[i]["href"].ToString();
                                result.Message = returnMsg.ToString();
                            }
                        }

                    } else {
                        result.ResultState = APIResult.enumResultCode.ERR;
                        result.Message = "CreatePayment Return Data err";
                    }

                } else {
                    result.ResultState = APIResult.enumResultCode.ERR;
                    result.Message = "No id";
                }
            } catch (RuntimeBinderException) {

                result.ResultState = APIResult.enumResultCode.ERR;
                result.Message = "CreatePayment Error";
            }

            return result;
        }

        public static APIResult CheckPaymentState(string PayPalOrderID, string PaypalToken) {
            APIResult result = new APIResult();
            APIResult ConfirmEWinPaymentresult = new APIResult();
            Newtonsoft.Json.Linq.JObject returnResult;
            string GetTokenURL = PayPalSetting.ApiUrl + "/v2/checkout/orders/" + PayPalOrderID;

            returnResult = CodingControl.GetWebJSONContent(GetTokenURL, "GET", "", GetHeaderString(PaypalToken));

            try {
                if (returnResult["id"] != null) {
                    string TransactionID = returnResult["id"].ToString();

                    if (TransactionID == PayPalOrderID) {
                        result.ResultState = APIResult.enumResultCode.OK;
                        result.Message = returnResult.ToString();
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

        public static APIResult CapturePayment(string PayPalOrderID, string PaypalToken) {
            APIResult result = new APIResult();
            APIResult ConfirmEWinPaymentresult = new APIResult();
            Newtonsoft.Json.Linq.JObject returnResult;
            string GetTokenURL = PayPalSetting.ApiUrl + "/v2/checkout/orders/" + PayPalOrderID + "/capture";

            returnResult = CodingControl.GetWebJSONContent(GetTokenURL, "POST", "", GetHeaderString(PaypalToken));

            try {
                if (returnResult["id"] != null) {
                    string TransactionID = returnResult["id"].ToString();

                    if (TransactionID == PayPalOrderID) {

                        if (returnResult["status"].ToString() == "COMPLETED") {
                            result.ResultState = APIResult.enumResultCode.OK;
                            result.Message = returnResult.ToString();
                        } else {
                            result.ResultState = APIResult.enumResultCode.ERR;
                            result.Message = "用戶未付款";
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

        private static string GetTokenHeaderString(string Username, string Password) {
            string Ret;
            string HeaderStr = CodingControl.Base64URLEncode(Username + ":" + Password);

            Ret = "Authorization:Basic " + HeaderStr;
            return Ret;
        }

        private static string GetHeaderString(string HeaderStr) {
            string Ret;

            Ret = "Authorization:Bearer " + HeaderStr;
            return Ret;
        }

        private static dynamic LoadSetting() {
            dynamic o = null;
            string Filename;

            if (EWinWeb.IsTestSite) {
                Filename = HttpContext.Current.Server.MapPath("/App_Data/PayPal/Test_" + SettingFile);
            } else {
                Filename = HttpContext.Current.Server.MapPath("/App_Data/PayPal/Formal_" + SettingFile);
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

    }

    public class APIResult {
        public enum enumResultCode {
            OK = 0,
            ERR = 1
        }

        public enumResultCode ResultState { get; set; }
        public string GUID { get; set; }
        public string Message { get; set; }
    }
}