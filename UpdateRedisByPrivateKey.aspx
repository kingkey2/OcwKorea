<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UpdateRedisByPrivateKey.aspx.cs" Inherits="UpdateRedisByPrivateKey" %>

<!DOCTYPE html>

<% 
    string PrivateKey = Request["PrivateKey"];
    System.Data.DataTable DT;

    if (!string.IsNullOrEmpty(PrivateKey)) {
        if (PrivateKey == EWinWeb.PrivateKey) {
            RedisCache.UpdateRedisByPrivateKey();

            DT = EWinWebDB.PaymentMethod.GetPaymentMethod();

            if (DT != null) {
                if (DT.Rows.Count > 0) {
                    for (int i = 0; i < DT.Rows.Count; i++) {
                        RedisCache.PaymentMethod.UpdatePaymentMethodByID((int)DT.Rows[i]["PaymentMethodID"]);
                    }
                }
            }

        } else {
            Response.Write("PrivateKey Is Err");
            Response.Flush();
            Response.End();
        }
    } else {
        Response.Write("PrivateKey Is Null");
        Response.Flush();
        Response.End();
    }
%>

<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Content-Language" content="zh-cn">
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body style="width: 100%">
</body>
</html>
