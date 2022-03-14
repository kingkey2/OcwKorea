<%@ WebService Language="C#" Class="MgmtAPI" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Collections;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using System.Linq;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允許使用 ASP.NET AJAX 從指令碼呼叫此 Web 服務，請取消註解下列一行。
// [System.Web.Script.Services.ScriptService]
[System.ComponentModel.ToolboxItem(false)]
[System.Web.Script.Services.ScriptService]
public class MgmtAPI : System.Web.Services.WebService {

    //[WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    //public string GetUserAccountSummary2(string a) {
    //    return EWinWeb.GetToken();
    //}

    [WebMethod]
    public void RefreshRedis(string password) {
        if (CheckPassword(password)) {
            System.Data.DataTable DT;
            RedisCache.PaymentCategory.UpdatePaymentCategory();
            RedisCache.PaymentMethod.UpdatePaymentMethodByCategory("Paypal");
            RedisCache.PaymentMethod.UpdatePaymentMethodByCategory("Crypto");

            DT = EWinWebDB.PaymentMethod.GetPaymentMethod();

            if (DT != null) {
                if (DT.Rows.Count > 0) {
                    for (int i = 0; i < DT.Rows.Count; i++) {
                        RedisCache.PaymentMethod.UpdatePaymentMethodByID((int)DT.Rows[i]["PaymentMethodID"]);
                    }
                }
            }


            EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
            var R = lobbyAPI.GetCompanyGameCode(EWinWeb.GetToken(), System.Guid.NewGuid().ToString()); 
            RedisCache.Company.UpdateCompanyGameCode(Newtonsoft.Json.JsonConvert.SerializeObject(R.GameCodeList));
        }
    }


    [WebMethod]
    public UserAccountSummaryResult GetUserAccountSummary(string password, string LoginAccount, DateTime SummaryDate) {

        UserAccountSummaryResult R = new UserAccountSummaryResult() { Result = enumResult.ERR };
        System.Data.DataTable DT;
        if (CheckPassword(password)) {
            DT = RedisCache.UserAccountSummary.GetUserAccountSummary(LoginAccount, SummaryDate);
            if (DT != null && DT.Rows.Count > 0) {
                R.SummaryGUID = (string)DT.Rows[0]["SummaryGUID"];
                R.SummaryDate = (DateTime)DT.Rows[0]["SummaryDate"];
                R.LoginAccount = (string)DT.Rows[0]["LoginAccount"];
                R.DepositCount = (int)DT.Rows[0]["DepositCount"];
                R.DepositRealAmount = (decimal)DT.Rows[0]["DepositRealAmount"];
                R.DepositAmount = (decimal)DT.Rows[0]["DepositAmount"];
                R.WithdrawalCount = (int)DT.Rows[0]["WithdrawalCount"];
                R.WithdrawalRealAmount = (decimal)DT.Rows[0]["WithdrawalRealAmount"];
                R.WithdrawalAmount = (decimal)DT.Rows[0]["WithdrawalAmount"];
                R.Result = enumResult.OK;
            } else {
                SetResultException(R, "NoData");
            }
        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }


    [WebMethod]
    public UserAccountTotalSummaryResult GetUserAccountTotalSummary(string password, string LoginAccount) {

        UserAccountTotalSummaryResult R = new UserAccountTotalSummaryResult() { Result = enumResult.ERR };
        System.Data.DataTable DT;
        if (CheckPassword(password)) {
            DT = RedisCache.UserAccountTotalSummary.GetUserAccountTotalSummaryByLoginAccount(LoginAccount);
            if (DT != null && DT.Rows.Count > 0) {
                R.LoginAccount = (string)DT.Rows[0]["LoginAccount"];
                R.LastDepositDate = (DateTime)DT.Rows[0]["LastDepositDate"];
                R.LastWithdrawalDate = (DateTime)DT.Rows[0]["LastWithdrawalDate"];
                R.LoginAccount = (string)DT.Rows[0]["LoginAccount"];
                R.DepositCount = (int)DT.Rows[0]["DepositCount"];
                R.DepositRealAmount = (decimal)DT.Rows[0]["DepositRealAmount"];
                R.DepositAmount = (decimal)DT.Rows[0]["DepositAmount"];
                R.WithdrawalCount = (int)DT.Rows[0]["WithdrawalCount"];
                R.WithdrawalRealAmount = (decimal)DT.Rows[0]["WithdrawalRealAmount"];
                R.WithdrawalAmount = (decimal)DT.Rows[0]["WithdrawalAmount"];
                R.FingerPrint = (string)DT.Rows[0]["FingerPrint"];
                R.Result = enumResult.OK;
            } else {
                SetResultException(R, "NoData");
            }
        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public APIResult OpenSite(string Password) {
        APIResult R = new APIResult() { Result = enumResult.ERR };

        dynamic o = null;
        string Filename;

        if (CheckPassword(Password)) {
            Filename = HttpContext.Current.Server.MapPath("/App_Data/Setting.json");

            if (System.IO.File.Exists(Filename)) {
                string SettingContent;

                SettingContent = System.IO.File.ReadAllText(Filename);

                if (string.IsNullOrEmpty(SettingContent) == false) {
                    try {
                        o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent);
                        o.InMaintenance = 0;

                        System.IO.File.WriteAllText(Filename, Newtonsoft.Json.JsonConvert.SerializeObject(o));
                        R.Result = enumResult.OK;
                    } catch (Exception ex) { }
                }
            }

        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public APIResult MaintainSite(string Password, string Message) {
        APIResult R = new APIResult() { Result = enumResult.ERR };

        dynamic o = null;
        string Filename;

        if (CheckPassword(Password)) {
            Filename = HttpContext.Current.Server.MapPath("/App_Data/Setting.json");

            if (System.IO.File.Exists(Filename)) {
                string SettingContent;

                SettingContent = System.IO.File.ReadAllText(Filename);

                if (string.IsNullOrEmpty(SettingContent) == false) {
                    try {
                        o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent);
                        o.InMaintenance = 1;

                        if (string.IsNullOrEmpty(Message) == false) {
                            o.MaintainMessage = Message;
                        }

                        System.IO.File.WriteAllText(Filename, Newtonsoft.Json.JsonConvert.SerializeObject(o));
                        R.Result = enumResult.OK;
                    } catch (Exception ex) { }
                }
            }

        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public APIResult EnableWithdrawlTemporaryMaintenance(string Password) {
        APIResult R = new APIResult() { Result = enumResult.ERR };

        dynamic o = null;
        string Filename;

        if (CheckPassword(Password)) {
            Filename = HttpContext.Current.Server.MapPath("/App_Data/Setting.json");

            if (System.IO.File.Exists(Filename)) {
                string SettingContent;

                SettingContent = System.IO.File.ReadAllText(Filename);

                if (string.IsNullOrEmpty(SettingContent) == false) {
                    try {
                        o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent);
                        o.WithdrawlTemporaryMaintenance = 1;

                        System.IO.File.WriteAllText(Filename, Newtonsoft.Json.JsonConvert.SerializeObject(o));
                        R.Result = enumResult.OK;
                    } catch (Exception ex) { }
                }
            }

        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public APIResult DisableWithdrawlTemporaryMaintenance(string Password) {
        APIResult R = new APIResult() { Result = enumResult.ERR };

        dynamic o = null;
        string Filename;

        if (CheckPassword(Password)) {
            Filename = HttpContext.Current.Server.MapPath("/App_Data/Setting.json");

            if (System.IO.File.Exists(Filename)) {
                string SettingContent;

                SettingContent = System.IO.File.ReadAllText(Filename);

                if (string.IsNullOrEmpty(SettingContent) == false) {
                    try {
                        o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent);
                        o.WithdrawlTemporaryMaintenance = 0;

                        System.IO.File.WriteAllText(Filename, Newtonsoft.Json.JsonConvert.SerializeObject(o));
                        R.Result = enumResult.OK;
                    } catch (Exception ex) { }
                }
            }

        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public APIResult UpdateAnnouncement(string Password, string Announcement) {
        APIResult R = new APIResult() { Result = enumResult.ERR };

        dynamic o = null;
        string Filename;

        if (CheckPassword(Password)) {
            Filename = HttpContext.Current.Server.MapPath("/App_Data/Setting.json");

            if (System.IO.File.Exists(Filename)) {
                string SettingContent;

                SettingContent = System.IO.File.ReadAllText(Filename);

                if (string.IsNullOrEmpty(SettingContent) == false) {
                    try {
                        o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent);
                        o.LoginMessage["Message"] = Announcement;
                        o.LoginMessage["Version"] = (decimal)o.LoginMessage["Version"] + 1;

                        System.IO.File.WriteAllText(Filename, Newtonsoft.Json.JsonConvert.SerializeObject(o));
                        R.Result = enumResult.OK;
                    } catch (Exception ex) { }
                }
            }

        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public PaymentValueReslut CalculatePaymentValue(string Password, string PaymentSerial) {
        PaymentValueReslut R = new PaymentValueReslut() { Result = enumResult.ERR };

        if (CheckPassword(Password)) {
            System.Data.DataTable DT = EWinWebDB.UserAccountPayment.GetPaymentByPaymentSerial(PaymentSerial);


            if (DT != null && DT.Rows.Count > 0) {
                var row = DT.Rows[0];

                if ((int)row["FlowStatus"] != 0) {
                    decimal totalThresholdValue = 0;
                    decimal totalPointValue = 0;
                    string paymentDesc = "";
                    List<string> activityStrs = new List<string>();
                    string activityDataStr = (string)row["ActivityData"];

                    if (!string.IsNullOrEmpty(activityDataStr)) {
                        Newtonsoft.Json.Linq.JArray activityDatas = Newtonsoft.Json.Linq.JArray.Parse(activityDataStr);

                        foreach (var item in activityDatas) {
                            string desc = item["ActivityName"].ToString() + "_BnousValue_" + ((decimal)item["BonusValue"]).ToString() + "_ThresholdValue_" + ((decimal)item["ThresholdValue"]).ToString();
                            totalThresholdValue += (decimal)item["ThresholdValue"];
                            //totalPointValue += (decimal)item["BonusValue"];
                            activityStrs.Add(desc);
                        }
                    }



                    paymentDesc = "ThresholdValue=" + ((decimal)row["ThresholdValue"]).ToString() + ",ThresholdRate=" + ((decimal)row["ThresholdRate"]).ToString();

                    totalThresholdValue += (decimal)row["ThresholdValue"];
                    totalPointValue = (decimal)row["PointValue"];

                    R.TotalThresholdValue = totalThresholdValue;
                    R.TotalPointValue = totalPointValue;
                    R.LoginAccount = (string)row["LoginAccount"];
                    R.Amount = (decimal)row["Amount"];
                    R.PaymentSerial = (string)row["PaymentSerial"];
                    R.PaymentCode = (string)row["PaymentCode"];
                    R.PaymentDescription = paymentDesc;
                    R.ActivityDescription = activityStrs;
                    R.Result = enumResult.OK;
                } else {
                    SetResultException(R, "StatusError");
                }
            } else {
                SetResultException(R, "NoData");
            }
        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    private bool CheckPassword(string Hash) {
        string key = EWinWeb.PrivateKey;

        bool Ret = false;
        int index = Hash.IndexOf('_');
        string tempStr1 = Hash.Substring(0, index);
        string tempStr2 = Hash.Substring(index + 1);
        string checkHash = "";
        DateTime CreateTime;
        DateTime TargetTime;
        if (index > 0) {
            if (DateTime.TryParse(tempStr1, out CreateTime)) {
                if (CreateTime.AddMinutes(15) >= DateTime.Now.AddSeconds(1)) {
                    TargetTime = RoundUp(CreateTime, TimeSpan.FromMinutes(15));
                    checkHash = CodingControl.GetMD5(TargetTime.ToString("yyyy/MM/dd HH:mm:ss") + key, false).ToLower();
                    if (checkHash.ToLower() == tempStr2) {
                        Ret = true;
                    }
                }
            }
        }

        return Ret;

    }

    private DateTime RoundUp(DateTime dt, TimeSpan d) {
        return new DateTime((dt.Ticks + d.Ticks - 1) / d.Ticks * d.Ticks, dt.Kind);
    }

    private void SetResultException(APIResult R, string Msg) {
        if (R != null) {
            R.Result = enumResult.ERR;
            R.Message = Msg;
        }
    }

    [WebMethod]
    public APIResult UpdateBulletinBoardState(string Password, int BulletinBoardID, int State) {
        APIResult R = new APIResult() { Result = enumResult.ERR };
        string SS;
        System.Data.SqlClient.SqlCommand DBCmd;
        int RetValue = 0;

        if (CheckPassword(Password)) {

            SS = " UPDATE BulletinBoard WITH (ROWLOCK) SET State=@State " +
                      " WHERE BulletinBoardID=@BulletinBoardID";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@State", System.Data.SqlDbType.Int).Value = State;
            DBCmd.Parameters.Add("@BulletinBoardID", System.Data.SqlDbType.Int).Value = BulletinBoardID;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            if (RetValue > 0) {
                RedisCache.BulletinBoard.UpdateBulletinBoard();
                R.Result = enumResult.OK;
            }
        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }

    [WebMethod]
    public APIResult InsertBulletinBoard(string Password, string BulletinTitle, string BulletinContent) {
        APIResult R = new APIResult() { Result = enumResult.ERR };
        string SS;
        System.Data.SqlClient.SqlCommand DBCmd;
        int RetValue = 0;

        if (CheckPassword(Password)) {

            SS = " INSERT INTO BulletinBoard (BulletinTitle, BulletinContent) " +
                      " VALUES (@BulletinTitle, @BulletinContent) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@BulletinTitle", System.Data.SqlDbType.NVarChar).Value = BulletinTitle;
            DBCmd.Parameters.Add("@BulletinContent", System.Data.SqlDbType.NVarChar).Value = BulletinContent;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            if (RetValue > 0) {
                RedisCache.BulletinBoard.UpdateBulletinBoard();
                R.Result = enumResult.OK;
            }
        } else {
            SetResultException(R, "InvalidPassword");
        }

        return R;
    }


    public class APIResult {
        public enumResult Result { get; set; }
        public string GUID { get; set; }
        public string Message { get; set; }
    }

    public enum enumResult {
        OK = 0,
        ERR = 1
    }

    public class PaymentValueReslut : APIResult {
        public string LoginAccount { get; set; }
        public string PaymentCode { get; set; }
        public string PaymentSerial { get; set; }
        public decimal Amount { get; set; }
        public decimal TotalPointValue { get; set; }
        public decimal TotalThresholdValue { get; set; }
        public List<string> ActivityDescription { get; set; }
        public string PaymentDescription { get; set; }
    }

    public class UserAccountSummaryResult : APIResult {
        public string SummaryGUID { get; set; }
        public DateTime SummaryDate { get; set; }
        public string LoginAccount { get; set; }
        public int DepositCount { get; set; }
        public decimal DepositRealAmount { get; set; }
        public decimal DepositAmount { get; set; }
        public int WithdrawalCount { get; set; }
        public decimal WithdrawalRealAmount { get; set; }
        public decimal WithdrawalAmount { get; set; }
    }

    public class UserAccountTotalSummaryResult : APIResult {
        public string LoginAccount { get; set; }
        public int DepositCount { get; set; }
        public decimal DepositRealAmount { get; set; }
        public decimal DepositAmount { get; set; }
        public int WithdrawalCount { get; set; }
        public decimal WithdrawalRealAmount { get; set; }
        public decimal WithdrawalAmount { get; set; }
        public DateTime LastDepositDate { get; set; }
        public DateTime LastWithdrawalDate { get; set; }
        public string FingerPrint { get; set; }
    }

    public class BulletinBoardResult : APIResult {
        public int BulletinBoardID { get; set; }
        public string BulletinTitle { get; set; }
        public string BulletinContent { get; set; }
        public DateTime CreateDate { get; set; }
        public int State { get; set; }

    }
}