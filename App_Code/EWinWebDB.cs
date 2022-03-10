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
public static class EWinWebDB {
    public static class UserAccountPayment {
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

        public static System.Data.DataTable GetPaymentByOtherOrderNumber(string OtherOrderNumber) {
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

        public static System.Data.DataTable UpdateOtherOrderNumberByOrderNumber(string OrderNumber, string OtherOrderNumber) {
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

            SS = "SELECT P.*, PC.CategoryName, PM.PaymentCode, PaymentName " +
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

        public static int ConfirmPayment(string OrderNumber, string ToInfo, string PaymentSerial, decimal PointValue, string ActivityData) {
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
            DBCmd.Parameters.Add("@ActivityData", System.Data.SqlDbType.VarChar).Value = ActivityData;

            return DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
        }

        public static int ConfirmPayment(string OrderNumber, string ToInfo, string PaymentSerial, string OtherOrderNumber, decimal PointValue, string ActivityData) {
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
    }

    public static class UserAccountTotalSummary{
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

    public static class PaymentMethod {

        public static System.Data.DataTable GetPaymentMethod() {
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
}