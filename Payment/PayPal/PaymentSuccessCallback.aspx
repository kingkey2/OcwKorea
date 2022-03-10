<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Common.cs" Inherits="Common" %>

<%
    string OrderNumber = Request["OrderNumber"];
    string PaypalID = "";

    System.Data.DataTable PaymentOrderDT;
    APIResult R = new APIResult() { ResultState = APIResult.enumResultCode.ERR };
    APIResult GetTokenResult;
    string RedirectUrl;
    PaypalStatusResult StatusResult;

    if (OrderNumber != null) {
        PaymentOrderDT = EWinWebDB.UserAccountPayment.GetPaymentByOrderNumber(OrderNumber);

        if (PaymentOrderDT != null && PaymentOrderDT.Rows.Count > 0) {
            GetTokenResult = GetPaypalToken();
            if (GetTokenResult.ResultState == APIResult.enumResultCode.OK) {
                PaypalID = PaymentOrderDT.Rows[0]["OtherOrderNumber"].ToString();
                StatusResult = CapturePayment(PaypalID, GetTokenResult.Message);

                if (StatusResult.ResultState == APIResult.enumResultCode.OK) {
                    if (StatusResult.IsSuccess) {
                        EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                        var finishResult = paymentAPI.FinishedPayment(EWinWeb.GetToken(), System.Guid.NewGuid().ToString(), (string)PaymentOrderDT.Rows[0]["PaymentSerial"]);

                        if (finishResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                            R.ResultState = APIResult.enumResultCode.OK;
                            RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositSuccess.aspx?Amount=" + StatusResult.OrderAmount.ToString() + "&OrderDate=" + StatusResult.OrderDate;
                        } else {
                            R.ResultState = APIResult.enumResultCode.ERR;
                            R.Message = "FinishResultError,Msg=" + finishResult.ResultMessage;
                            RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositFail.aspx?TranID=" + PaypalID + "&Amount=" + StatusResult.OrderAmount.ToString() + "&TranDate=" + StatusResult.OrderDate;
                        }
                    } else {
                        R.ResultState = APIResult.enumResultCode.ERR;
                        R.Message = "UnCompleted";
                        RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositFail.aspx?TranID=" + PaypalID + "&Amount=" + StatusResult.OrderAmount.ToString() + "&TranDate=" + StatusResult.OrderDate;
                    }
                } else {
                    R.ResultState = APIResult.enumResultCode.ERR;
                    R.Message = "CheckPaypalStatusFail,Msg=" + StatusResult.Message;
                    RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositFail.aspx?TranID=" + PaypalID;
                }
            } else {
                R.ResultState = APIResult.enumResultCode.ERR;
                R.Message = "GetTokenError,Msg=" + GetTokenResult.Message;
                RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositFail.aspx?TranID=" + PaypalID;
            }
        } else {
            R.ResultState = APIResult.enumResultCode.ERR;
            R.Message = "OtherOrderNumberNotFound";
            RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositFail.aspx?TranID=" + PaypalID;
        }
    } else {
        R.ResultState = APIResult.enumResultCode.ERR;
        R.Message = "OtherOrderNumberNotFound";
        RedirectUrl = EWinWeb.CasinoWorldUrl + "/DepositFail.aspx?TranID=" + PaypalID;
    }

    Response.Redirect(RedirectUrl);
%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
    <title></title>
</head>
<script>
<%--    var Url = "<%:RedirectUrl%>";

    if (self == top) {
        window.location.href = Url;
    } else {
        window.top.API_LoadPage("PayPal", Url);
    }--%>

</script>
<body>
    <form id="form1" runat="server">
        <div>
        </div>
    </form>
</body>
</html>

