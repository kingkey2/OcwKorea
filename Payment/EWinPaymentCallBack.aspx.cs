using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Payment_EWinPaymentCallBack : System.Web.UI.Page
{

    public bool CheckResetThreshold(decimal PoinValue) {
        Newtonsoft.Json.Linq.JObject settingJObj = EWinWeb.GetSettingJObj();
        bool R = false;
        decimal limitValue;

        if (settingJObj != null) {
            limitValue = (decimal)settingJObj["ThresholdBaseValue"];

            if (limitValue >= PoinValue) {
                R = true;
            }                       
        }

        return R;
    }

    public string GetToken()
    {
        string Token;
        int RValue;
        Random R = new Random();
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        return Token;
    }

    public void SetResultException(PaymentCallbackResult R, string Msg)
    {
        if (R != null) {
            R.Result = 1;
            R.Message = Msg;
        }
    }

    public class PaymentCallbackInfo
    {
        public string Action { get; set; }   //Action => Create,Finished,Cancel,Reject,Accept
        public string DirectionType { get; set; }
        public string PaymentSerial { get; set; }
        public string ClientOrderNumber { get; set; }
        public int PaymentType { get; set; }
        public string LoginAccount { get; set; }
        public string PersonCode { get; set; }
        public string CurrencyType { get; set; }
        public decimal Amount { get; set; }
        public decimal BeforeBalance { get; set; }
        public string Description { get; set; }
        public string TagInfo { get; set; }
        public int PointStatus { get; set; }
        public decimal PointValue { get; set; }
        public string UserIP { get; set; }
        public string CreateDate { get; set; }
    }

    public class EWinTagInfoData
    {
        public int PaymentMethodID { get; set; }
        public string PaymentCode { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
        public bool IsJoinDepositActivity { get; set; }
        public List<EWinTagInfoActivityData> ActivityDatas { get; set; }
    }

    public class EWinTagInfoActivityData
    {
        public string ActivityName { get; set; }
        public decimal BonusRate { get; set; }
        public decimal BonusValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
    }

    public class PaymentCallbackResult
    {
        public int Result { get; set; }
        public string Message { get; set; }
    }
}