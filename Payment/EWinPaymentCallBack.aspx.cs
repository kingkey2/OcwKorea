using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Payment_EWinPaymentCallBack : System.Web.UI.Page
{

    public PaymentCommonData CovertFromRow(System.Data.DataRow row) {
        string DetailDataStr = "";
        string ActivityDataStr = "";

        if (!Convert.IsDBNull(row["DetailData"])) {
            DetailDataStr = row["DetailData"].ToString();
        }

        if (!Convert.IsDBNull(row["ActivityData"])) {
            ActivityDataStr = row["ActivityData"].ToString();
        }



        if (string.IsNullOrEmpty(DetailDataStr)) {
            PaymentCommonData result = new PaymentCommonData() {
                PaymentType = (int)row["PaymentType"],
                BasicType = (int)row["BasicType"],
                LoginAccount = (string)row["LoginAccount"],
                OrderNumber = (string)row["OrderNumber"],
                Amount = (decimal)row["Amount"],
                HandingFeeRate = (decimal)row["HandingFeeRate"],
                //ReceiveTotalAmount = (decimal)row["ReceiveTotalAmount"],
                ThresholdValue = (decimal)row["ThresholdValue"],
                ThresholdRate = (decimal)row["ThresholdRate"],
                CreateDate = ((DateTime)row["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss"),
                LimitDate = ((DateTime)row["CreateDate"]).AddSeconds((int)row["ExpireSecond"]).ToString("yyyy/MM/dd HH:mm:ss"),
                ExpireSecond = (int)row["ExpireSecond"],
                PaymentMethodID = (int)row["PaymentMethodID"],
                PaymentMethodName = (string)row["PaymentName"],
                PaymentCode = (string)row["PaymentCode"]
            };

            return result;
        } else {
            PaymentCommonData result = new PaymentCommonData() {
                PaymentType = (int)row["PaymentType"],
                BasicType = (int)row["BasicType"],
                LoginAccount = (string)row["LoginAccount"],
                OrderNumber = (string)row["OrderNumber"],
                Amount = (decimal)row["Amount"],
                HandingFeeRate = (decimal)row["HandingFeeRate"],
                //ReceiveTotalAmount = (decimal)row["ReceiveTotalAmount"],
                ThresholdValue = (decimal)row["ThresholdValue"],
                ThresholdRate = (decimal)row["ThresholdRate"],
                CreateDate = ((DateTime)row["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss"),
                LimitDate = ((DateTime)row["CreateDate"]).AddSeconds((int)row["ExpireSecond"]).ToString("yyyy/MM/dd HH:mm:ss"),
                ExpireSecond = (int)row["ExpireSecond"],
                PaymentMethodID = (int)row["PaymentMethodID"],
                PaymentMethodName = (string)row["PaymentName"],
                PaymentCode = (string)row["PaymentCode"],
                ToWalletAddress = (string)row["ToInfo"],
                WalletType = (int)row["EWinCryptoWalletType"],
            };

            result.PaymentCryptoDetailList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<CryptoDetail>>(DetailDataStr);

            if (!string.IsNullOrEmpty(ActivityDataStr)) {
                result.ActivityDatas = Newtonsoft.Json.JsonConvert.DeserializeObject<List<EWinTagInfoActivityData>>(ActivityDataStr);
            }

            return result;
        }
    }

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

    public class PaymentCommonData {
        public int PaymentType { get; set; } // 0=入金,1=出金
        public int BasicType { get; set; } // 0=一般/1=銀行卡/2=區塊鏈
        public int PaymentFlowType { get; set; } // 0=建立/1=進行中/2=成功/3=失敗
        public string LoginAccount { get; set; }
        public string PaymentSerial { get; set; }
        public string OrderNumber { get; set; }
        public string ReceiveCurrencyType { get; set; }
        public decimal Amount { get; set; }
        public decimal PointValue { get; set; }
        public decimal HandingFeeRate { get; set; }
        public int HandingFeeAmount { get; set; }
        public decimal ReceiveTotalAmount { get; set; }
        public decimal ThresholdValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public int ExpireSecond { get; set; }
        public int PaymentMethodID { get; set; }
        public string PaymentMethodName { get; set; }
        public string PaymentCode { get; set; }
        public string CreateDate { get; set; }
        public string FinishDate { get; set; }
        public string LimitDate { get; set; }
        public int WalletType { get; set; } // 0=ERC,1=XRP
        public string ToWalletAddress { get; set; }
        public List<CryptoDetail> PaymentCryptoDetailList { get; set; }
        public List<EWinTagInfoActivityData> ActivityDatas { get; set; }
        public string ActivityData { get; set; }
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

    public class CryptoDetail {
        public string TokenCurrencyType { get; set; }
        public string TokenContractAddress { get; set; }
        public decimal ReceiveAmount { get; set; }
        public decimal ExchangeRate { get; set; }
        public decimal PartialRate { get; set; }
    }

}