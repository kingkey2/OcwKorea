using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// EWin 的摘要描述
/// </summary>
public static class EWinWebDB
{
    public static class UserAccountPayment
    {
        public enum FlowStatus
        {
            Create = 0,
            InProgress = 1,
            Success = 2,
            Cancel = 3,
            Reject = 4,
            Accept = 5
        }

        public static int InsertPayment(string OrderNumber, int PaymentType, int BasicType, string LoginAccount, decimal Amount, decimal HandingFeeRate, int HandingFeeAmount, decimal ThresholdRate, decimal ThresholdValue, int forPaymentMethodID, string FromInfo, string ToInfo, string DetailData, int ExpireSecond)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;

            SS = "INSERT INTO UserAccountPayment (OrderNumber, PaymentType, BasicType, LoginAccount, Amount, HandingFeeRate, HandingFeeAmount, ThresholdRate, ThresholdValue, forPaymentMethodID, FromInfo, ToInfo, DetailData, ExpireSecond) " +
                 "                VALUES (@OrderNumber, @PaymentType, @BasicType, @LoginAccount, @Amount, @HandingFeeRate, @HandingFeeAmount, @ThresholdRate, @ThresholdValue, @forPaymentMethodID, @FromInfo, @ToInfo, @DetailData, @ExpireSecond)";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@PaymentType", System.Data.SqlDbType.Int).Value = PaymentType;
            DBCmd.Parameters.Add("@BasicType", System.Data.SqlDbType.Int).Value = BasicType;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@FlowStatus", System.Data.SqlDbType.Int).Value = 0;
            DBCmd.Parameters.Add("@Amount", System.Data.SqlDbType.Decimal).Value = Amount;
            DBCmd.Parameters.Add("@HandingFeeRate", System.Data.SqlDbType.Decimal).Value = HandingFeeRate;
            DBCmd.Parameters.Add("@HandingFeeAmount", System.Data.SqlDbType.Decimal).Value = HandingFeeAmount;
            DBCmd.Parameters.Add("@ThresholdRate", System.Data.SqlDbType.Decimal).Value = ThresholdRate;
            DBCmd.Parameters.Add("@ThresholdValue", System.Data.SqlDbType.Decimal).Value = ThresholdValue;
            DBCmd.Parameters.Add("@forPaymentMethodID", System.Data.SqlDbType.Int).Value = forPaymentMethodID;
            DBCmd.Parameters.Add("@FromInfo", System.Data.SqlDbType.NVarChar).Value = FromInfo;
            DBCmd.Parameters.Add("@ToInfo", System.Data.SqlDbType.NVarChar).Value = ToInfo;
            DBCmd.Parameters.Add("@DetailData", System.Data.SqlDbType.NVarChar).Value = DetailData;
            DBCmd.Parameters.Add("@ExpireSecond", System.Data.SqlDbType.Int).Value = ExpireSecond;

            return DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
        }

        public static System.Data.DataTable GetPaymentByOtherOrderNumber(string OtherOrderNumber)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = "SELECT P.*, PC.CategoryName, PM.PaymentCode, PaymentName , PM.PaymentMethodID, PM.EWinCryptoWalletType " +
               "FROM UserAccountPayment AS P WITH (NOLOCK) " +
               "LEFT JOIN PaymentMethod AS PM WITH (NOLOCK) ON P.forPaymentMethodID = PM.PaymentMethodID " +
               "LEFT JOIN PaymentCategory AS PC WITH (NOLOCK) ON PM.PaymentCategoryCode = PC.PaymentCategoryCode " +
               "WHERE P.OtherOrderNumber=@OtherOrderNumber";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OtherOrderNumber", System.Data.SqlDbType.VarChar).Value = OtherOrderNumber;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable UpdateOtherOrderNumberByOrderNumber(string OrderNumber, string OtherOrderNumber)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " UPDATE UserAccountPayment WITH (ROWLOCK) SET OtherOrderNumber=@OtherOrderNumber " +
                      " WHERE OrderNumber=@OrderNumber";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@OtherOrderNumber", System.Data.SqlDbType.VarChar).Value = OtherOrderNumber;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetPaymentByPaymentSerial(string PaymentSerial)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = "SELECT P.*, PC.CategoryName, PM.PaymentCode, PaymentName  , PM.PaymentMethodID, PM.EWinCryptoWalletType " +
                 "FROM UserAccountPayment AS P WITH (NOLOCK) " +
                 "LEFT JOIN PaymentMethod AS PM WITH (NOLOCK) ON P.forPaymentMethodID = PM.PaymentMethodID " +
                 "LEFT JOIN PaymentCategory AS PC WITH (NOLOCK) ON PM.PaymentCategoryCode = PC.PaymentCategoryCode " +
                 "WHERE P.PaymentSerial=@PaymentSerial";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@PaymentSerial", System.Data.SqlDbType.VarChar).Value = PaymentSerial;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetPaymentByOrderNumber(string OrderNumber)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = "SELECT P.*, PC.CategoryName, PM.PaymentCode, PaymentName, PM.PaymentMethodID, PM.EWinCryptoWalletType " +
               "FROM UserAccountPayment AS P WITH (NOLOCK) " +
               "LEFT JOIN PaymentMethod AS PM WITH (NOLOCK) ON P.forPaymentMethodID = PM.PaymentMethodID " +
               "LEFT JOIN PaymentCategory AS PC WITH (NOLOCK) ON PM.PaymentCategoryCode = PC.PaymentCategoryCode " +
               "WHERE P.OrderNumber=@OrderNumber";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static int ConfirmPayment(string OrderNumber, string ToInfo)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;

            SS = "UPDATE UserAccountPayment WITH (ROWLOCK) SET FlowStatus=@FlowStatus, ToInfo=@ToInfo " +
                 "         WHERE  OrderNumber=@OrderNumber AND FlowStatus=0  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@FlowStatus", System.Data.SqlDbType.Int).Value = 1;
            DBCmd.Parameters.Add("@ToInfo", System.Data.SqlDbType.NVarChar).Value = ToInfo;

            return DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
        }

        public static int ConfirmPayment(string OrderNumber, string ToInfo, string PaymentSerial, decimal PointValue, string ActivityData)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;

            SS = "UPDATE UserAccountPayment WITH (ROWLOCK) SET FlowStatus=@FlowStatus, ToInfo=@ToInfo, PaymentSerial=@PaymentSerial, PointValue=@PointValue, ActivityData=@ActivityData " +
                 "         WHERE  OrderNumber=@OrderNumber AND FlowStatus=0  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@FlowStatus", System.Data.SqlDbType.Int).Value = 1;
            DBCmd.Parameters.Add("@PointValue", System.Data.SqlDbType.Decimal).Value = PointValue;
            DBCmd.Parameters.Add("@ToInfo", System.Data.SqlDbType.NVarChar).Value = ToInfo;
            DBCmd.Parameters.Add("@PaymentSerial", System.Data.SqlDbType.VarChar).Value = PaymentSerial;

            if (string.IsNullOrEmpty(ActivityData))
            {
                DBCmd.Parameters.Add("@ActivityData", System.Data.SqlDbType.VarChar).Value = "";
            }
            else
            {
                DBCmd.Parameters.Add("@ActivityData", System.Data.SqlDbType.VarChar).Value = ActivityData;
            }


            return DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
        }

        public static int ConfirmPayment(string OrderNumber, string ToInfo, string PaymentSerial, string OtherOrderNumber, decimal PointValue, string ActivityData)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;

            SS = "UPDATE UserAccountPayment WITH (ROWLOCK) SET FlowStatus=@FlowStatus, ToInfo=@ToInfo, PaymentSerial=@PaymentSerial, OtherOrderNumber=@OtherOrderNumber, PointValue=@PointValue, ActivityData=@ActivityData " +
                 "         WHERE  OrderNumber=@OrderNumber AND FlowStatus=0  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@FlowStatus", System.Data.SqlDbType.Int).Value = 1;
            DBCmd.Parameters.Add("@PointValue", System.Data.SqlDbType.Decimal).Value = PointValue;
            DBCmd.Parameters.Add("@ToInfo", System.Data.SqlDbType.NVarChar).Value = ToInfo;
            DBCmd.Parameters.Add("@PaymentSerial", System.Data.SqlDbType.VarChar).Value = PaymentSerial;
            DBCmd.Parameters.Add("@OtherOrderNumber", System.Data.SqlDbType.VarChar).Value = OtherOrderNumber;
            DBCmd.Parameters.Add("@ActivityData", System.Data.SqlDbType.VarChar).Value = ActivityData;

            return DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
        }

        public static int FinishPaymentFlowStatus(string OrderNumber, FlowStatus FlowStatus, string PaymentSerial)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;

            SS = "spSetPaymentFlowStatus";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.StoredProcedure;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@FlowStatus", System.Data.SqlDbType.Int).Value = FlowStatus;
            DBCmd.Parameters.Add("@PaymentSerial", System.Data.SqlDbType.VarChar).Value = PaymentSerial;
            DBCmd.Parameters.Add("@RETURN", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;
            DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return Convert.ToInt32(DBCmd.Parameters["@RETURN"].Value);
        }

        public static int ResumePaymentFlowStatus(string OrderNumber, string PaymentSerial)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;

            SS = "spSetPaymentFlowStatusByResume";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.StoredProcedure;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DBCmd.Parameters.Add("@FlowStatus", System.Data.SqlDbType.Int).Value = 1;
            DBCmd.Parameters.Add("@PaymentSerial", System.Data.SqlDbType.VarChar).Value = PaymentSerial;
            DBCmd.Parameters.Add("@RETURN", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;
            DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return Convert.ToInt32(DBCmd.Parameters["@RETURN"].Value);
        }

        /// <summary>
        /// 取得當天進行中與完成的訂單
        /// </summary>
        /// <param name="LoginAccount"></param>
        /// <param name="PaymentType"></param>
        /// <returns></returns>
        public static System.Data.DataTable GetTodayPaymentByLoginAccount(string LoginAccount, int PaymentType)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                      " FROM   UserAccountPayment " +
                      " WHERE  LoginAccount = @LoginAccount " +
                      "        AND CreateDate >= dbo.Getreportdate(Getdate()) " +
                      "        AND CreateDate < dbo.Getreportdate(Dateadd (day, 1, Getdate())) " +
                      "        AND FlowStatus IN ( 1, 2 ) " +
                      "        AND PaymentType = @PaymentType ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@PaymentType", System.Data.SqlDbType.Int).Value = PaymentType;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetInProgressPaymentByLoginAccount(string LoginAccount, int PaymentType)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT *, convert(varchar,CreateDate,120) CreateDate1  " +
                      " FROM   UserAccountPayment " +
                      " WHERE  LoginAccount = @LoginAccount " +
                      "        AND FlowStatus = 1 " +
                      "        AND PaymentType = @PaymentType ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@PaymentType", System.Data.SqlDbType.Int).Value = PaymentType;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetInProgressPaymentByLoginAccountPaymentMethodID(string LoginAccount, int PaymentType, int PaymentMethodID)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT *, convert(varchar,CreateDate,126) CreateDate1  " +
                      " FROM   UserAccountPayment " +
                      " WHERE  LoginAccount = @LoginAccount " +
                      "        AND FlowStatus = 1 " +
                      "        AND PaymentType = @PaymentType " +
                      "        AND forPaymentMethodID = @PaymentMethodID ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@PaymentType", System.Data.SqlDbType.Int).Value = PaymentType;
            DBCmd.Parameters.Add("@PaymentMethodID", System.Data.SqlDbType.Int).Value = PaymentMethodID;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }
    }

    public static class UserAccountTotalSummary
    {
        public static int UpdateFingerPrint(string FingerPrints, string LoginAccount)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountTotalSummary WITH (ROWLOCK) SET FingerPrints=@FingerPrints " +
                      " WHERE LoginAccount=@LoginAccount";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@FingerPrints", System.Data.SqlDbType.VarChar).Value = FingerPrints;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int InsertUserAccountTotalSummary(string FingerPrints, string LoginAccount)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO UserAccountTotalSummary (LoginAccount, FingerPrints) " +
                      " VALUES (@LoginAccount, @FingerPrints) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@FingerPrints", System.Data.SqlDbType.VarChar).Value = FingerPrints;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

    }

    public static class BulletinBoard
    {
        public static System.Data.DataTable GetBulletinBoard()
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = "SELECT * " +
               "FROM BulletinBoard AS BB WITH (NOLOCK) " +
               "WHERE BB.State=0";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }
    }

    public static class PaymentMethod
    {

        public static System.Data.DataTable GetPaymentMethod()
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = "SELECT * " +
                      "FROM PaymentMethod ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }
    }

    public static class UserAccountEventBonusHistory
    {

        public enum EventType
        {
            Deposit = 0,
            Login = 1
        }

        public static int InsertEventBonusHistory(string LoginAccount, string ActivityName, string RelationID, decimal BonusRate, decimal BonusValue, decimal ThresholdRate, decimal ThresholdValue, EventType EventType)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int EventBonusHistoryID = 0;

            SS = "INSERT INTO UserAccountEventBonusHistory (LoginAccount, BonusRate, BonusValue, ThresholdRate, ThresholdValue, ActivityName, RelationID, EventType) " +
                 "                VALUES (@LoginAccount, @BonusRate, @BonusValue, @ThresholdRate, @ThresholdValue, @ActivityName, @RelationID, @EventType)" +
                " SELECT @@IDENTITY";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@BonusRate", System.Data.SqlDbType.Decimal).Value = BonusRate;
            DBCmd.Parameters.Add("@BonusValue", System.Data.SqlDbType.Decimal).Value = BonusValue;
            DBCmd.Parameters.Add("@ThresholdRate", System.Data.SqlDbType.Decimal).Value = ThresholdRate;
            DBCmd.Parameters.Add("@ThresholdValue", System.Data.SqlDbType.Decimal).Value = ThresholdValue;
            DBCmd.Parameters.Add("@ActivityName", System.Data.SqlDbType.VarChar).Value = ActivityName;
            DBCmd.Parameters.Add("@RelationID", System.Data.SqlDbType.VarChar).Value = RelationID;
            DBCmd.Parameters.Add("@EventType", System.Data.SqlDbType.Int).Value = EventType;

            EventBonusHistoryID = Convert.ToInt32(DBAccess.GetDBValue(EWinWeb.DBConnStr, DBCmd));
            return EventBonusHistoryID;
        }

    }

    public static class UserAccountFingerprint
    {
        public static System.Data.DataTable GetUserAccountFingerprintByLoginAccount(string LoginAccount)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                      " FROM   UserAccountFingerprint " +
                      " WHERE  LoginAccount = @LoginAccount ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetUserAccountFingerprintByLoginAccountFingerprintID(string LoginAccount, string FingerprintID)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                      " FROM   UserAccountFingerprint " +
                      " WHERE  LoginAccount = @LoginAccount " +
                      "     AND FingerprintID = @FingerprintID ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@FingerprintID", System.Data.SqlDbType.VarChar).Value = FingerprintID;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static int InsertUserAccountFingerprint(string LoginAccount, string FingerprintID, string UserAgent)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO UserAccountFingerprint (LoginAccount, FingerprintID, UserAgent) " +
                      " VALUES (@LoginAccount, @FingerprintID, @UserAgent) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@FingerprintID", System.Data.SqlDbType.VarChar).Value = FingerprintID;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@UserAgent", System.Data.SqlDbType.VarChar).Value = UserAgent;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

    }

    public static class NotifyMsg
    {
        public static int InsertNotifyMsg(string Title, string NotifyContent, string URL)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int NotifyMsgID = 0;

            SS = "INSERT INTO NotifyMsg (Title, NotifyContent, URL) " +
                      "                VALUES (@Title, @NotifyContent, @URL) " +
                      " SELECT @@IDENTITY";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@Title", System.Data.SqlDbType.NVarChar).Value = Title;
            DBCmd.Parameters.Add("@NotifyContent", System.Data.SqlDbType.NVarChar).Value = NotifyContent;
            DBCmd.Parameters.Add("@URL", System.Data.SqlDbType.VarChar).Value = URL;
            NotifyMsgID = Convert.ToInt32(DBAccess.GetDBValue(EWinWeb.DBConnStr, DBCmd));

            return NotifyMsgID;
        }
    }

    public static class UserAccountNotifyMsg
    {
        public static int InsertUserAccountNotifyMsg(int NotifyMsgID, int MessageReadStatus, string LoginAccount)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO UserAccountNotifyMsg (forNotifyMsgID, LoginAccount, MessageReadStatus) " +
                                  " VALUES (@forNotifyMsgID, @LoginAccount, @MessageReadStatus) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@forNotifyMsgID", System.Data.SqlDbType.Int).Value = NotifyMsgID;
            DBCmd.Parameters.Add("@MessageReadStatus", System.Data.SqlDbType.Int).Value = MessageReadStatus;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int UpdateUserAccountNotifyMsgStatus(int forNotifyMsgID, string LoginAccount, int MessageReadStatus)
        {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountNotifyMsg WITH (ROWLOCK) SET MessageReadStatus=@MessageReadStatus " +
                      " WHERE LoginAccount=@LoginAccount AND forNotifyMsgID=@forNotifyMsgID";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@forNotifyMsgID", System.Data.SqlDbType.Int).Value = forNotifyMsgID;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@MessageReadStatus", System.Data.SqlDbType.Int).Value = MessageReadStatus;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }
    }
}