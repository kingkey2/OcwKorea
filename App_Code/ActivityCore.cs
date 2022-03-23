using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// CryptoExpand 的摘要描述
/// </summary>
public static class ActivityCore
{
    public static string BasicFile = "/App_Data/Activity.json";

    //儲值相關活動

    //暫時未使用到
    public static DepositActivitiesInfoResult GetDepositInfo(decimal Amount, string PaymentCode, string LoginAccount)
    {
        DepositActivitiesInfoResult R = new DepositActivitiesInfoResult()
        {
            InfoDataList = new List<DepositActivityInfoData>()
        };
        JObject InProgressActivity;

        InProgressActivity = GetInProgressActivity();

        foreach (var item in InProgressActivity["Deposit"])
        {
            DepositActivityInfoData InfoResult;
            string DetailPath = null;
            string MethodName = null;

            DetailPath = InProgressActivity["BasicPath"] + item["Path"].ToString();
            MethodName = item["InfoMethodName"].ToString();

            InfoResult = (DepositActivityInfoData)(typeof(ActivityExpand.DepositInfo).GetMethod(MethodName).Invoke(null, new object[] { DetailPath, Amount, PaymentCode, LoginAccount }));

            InfoResult.ActivityName = (string)item["Name"];

            R.InfoDataList.Add(InfoResult);
        }

        R.Result = enumActResult.OK;
        R.Message = "";

        return R;
    }

    public static DepositActivityResult GetDepositResult(string ActiviyName, decimal Amount, string PaymentCode, string LoginAccount)
    {
        DepositActivityResult R = new DepositActivityResult() { Result = enumActResult.ERR };
        JObject InProgressActivity;


        bool IsInProgress = false;
        string DetailPath = null;
        string MethodName = null;

        InProgressActivity = GetInProgressActivity();

        foreach (var item in InProgressActivity["Deposit"])
        {
            if (item["Name"].ToString().ToUpper() == ActiviyName.ToUpper())
            {
                IsInProgress = true;
                DetailPath = InProgressActivity["BasicPath"] + item["Path"].ToString();
                MethodName = item["MethodName"].ToString();
                break;
            }
        }

        if (IsInProgress)
        {
            var DR = (DepositActivityResult)(typeof(ActivityExpand.Deposit).GetMethod(MethodName).Invoke(null, new object[] { DetailPath, Amount, PaymentCode, LoginAccount }));

            if (DR.Result == enumActResult.OK)
            {
                R.Result = enumActResult.OK;
                R.Data = DR.Data;
                R.Data.ActivityName = ActiviyName;
            }
            else
            {
                SetResultException(R, "GetActivityFailure,Msg=" + DR.Message);
            }
        }
        else
        {
            SetResultException(R, "ActivityIsExpired");
        }

        return R;
    }

    public static DepositActivitiesResult GetDepositAllResult(decimal Amount, string PaymentCode, string LoginAccount)
    {
        DepositActivitiesResult R = new DepositActivitiesResult()
        {
            DataList = new List<DepositActivityData>()
        };
        JObject InProgressActivity;

        InProgressActivity = GetInProgressActivity();
        string DetailPath = null;
        string MethodName = null;

        foreach (var item in InProgressActivity["Deposit"])
        {
            DepositActivityResult DataReslut;
            DetailPath = InProgressActivity["BasicPath"] + item["Path"].ToString();
            MethodName = item["MethodName"].ToString();

            DataReslut = (DepositActivityResult)(typeof(ActivityExpand.Deposit).GetMethod(MethodName).Invoke(null, new object[] { DetailPath, Amount, PaymentCode, LoginAccount }));

            if (DataReslut.Result == enumActResult.OK)
            {
                DataReslut.Data.ActivityName = item["Name"].ToString();
                R.DataList.Add(DataReslut.Data);
            }
        }

        R.Result = enumActResult.OK;
        R.Message = "";

        return R;
    }

    //上線獎勵(下線儲值完成，強制參加)
    //初期先LoginAccount(可能會有該LoginAccount貢獻等等)，高機率上下線資訊都需要，再以LoginAccount去撈取
    public static IntroActivitiesResult GetAllParentBonusAfterDepositResult(string LoginAccount)
    {
        IntroActivitiesResult R = new IntroActivitiesResult()
        {
            DataList = new List<IntroActivityData>()
        };
        JObject InProgressActivity;

        InProgressActivity = GetInProgressActivity();
        string DetailPath = null;
        string MethodName = null;

        foreach (var item in InProgressActivity["ParentBonusAfterDeposit"])
        {
            IntroActivityResult DataReslut;
            DetailPath = InProgressActivity["BasicPath"] + item["Path"].ToString();
            MethodName = item["MethodName"].ToString();

            DataReslut = (IntroActivityResult)(typeof(ActivityExpand.ParentBonusAfterDeposit).GetMethod(MethodName).Invoke(null, new object[] { DetailPath, LoginAccount }));


            if (DataReslut.Result == enumActResult.OK)
            {
                DataReslut.Data.ActivityName = item["Name"].ToString();
                R.DataList.Add(DataReslut.Data);
            }
        }

        R.Result = enumActResult.OK;
        R.Message = "";

        return R;
    }

    private static JObject GetInProgressActivity()
    {
        JObject o = null;
        string Filename;

        Filename = HttpContext.Current.Server.MapPath(BasicFile);

        if (System.IO.File.Exists(Filename))
        {
            string SettingContent;

            SettingContent = System.IO.File.ReadAllText(Filename);

            if (string.IsNullOrEmpty(SettingContent) == false)
            {
                try { o = JObject.Parse(SettingContent); } catch (Exception ex) { }
            }
        }

        return o;
    }

    public static void SetResultException(ActResult R, string Msg)
    {
        if (R != null)
        {
            R.Result = enumActResult.ERR;
            R.Message = Msg;
        }
    }

    public class ActResult
    {
        public enumActResult Result { get; set; }
        public string GUID { get; set; }
        public string Message { get; set; }
    }

    public enum enumActResult
    {
        OK = 0,
        ERR = 1
    }

    public class ActivityData
    {
        public string ActivityName { get; set; }
        public decimal BonusRate { get; set; }
        public decimal BonusValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
        public string Title { get; set; }
        public string SubTitle { get; set; }
        public int JoinCount { get; set; }
    }

    public class ActivityInfoData
    {
        public string ActivityName { get; set; }
        public string Title { get; set; }
        public string SubTitle { get; set; }
    }

    public class DepositActivityResult : ActResult
    {
        public DepositActivityData Data { get; set; }
    }

    public class DepositActivitiesInfoResult : ActResult
    {
        public List<DepositActivityInfoData> InfoDataList { get; set; }
    }

    public class DepositActivitiesResult : ActResult
    {
        public List<DepositActivityData> DataList { get; set; }
    }

    public class DepositActivityInfoData : ActivityInfoData
    {
        public bool IsCanJoin { get; set; }
        public string CanNotJoinDescription { get; set; }
    }

    public class DepositActivityData : ActivityData
    {
        public string PaymentCode { get; set; }
        public decimal Amount { get; set; }
    }


    //Intro
    public class IntroActivityResult : ActResult
    {
        public IntroActivityData Data { get; set; }
    }

    public class IntroActivitiesResult : ActResult
    {
        public List<IntroActivityData> DataList { get; set; }
    }

    public class IntroActivityData : ActivityData
    {
        public string ParentLoginAccount { get; set; }
        public string LoginAccount { get; set; }
    }
}