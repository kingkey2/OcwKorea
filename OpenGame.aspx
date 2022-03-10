<%@ Page Language="C#" %>

<%

    RedisCache.SessionContext.SIDInfo SI;
    string GameBrand = Request["GameBrand"];
    string SID = Request["SID"];
    string Lang = Request["Lang"];
    string CurrencyType = Request["CurrencyType"];
    string GameName = Request["GameName"];
    string HomeUrl = Request["HomeUrl"];
    string DemoPlay = string.IsNullOrEmpty(Request["DemoPlay"]) ? "0" : Request["DemoPlay"]; //不支援DEMO直接最外層判斷

    SI = RedisCache.SessionContext.GetSIDInfo(SID);

    if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
        if (GameBrand == "EWin" && GameName == "EWinGaming") {
            if (DemoPlay == "0") {
                Response.Redirect(EWinWeb.EWinGameUrl + "/Game/Login.aspx?CT=" + HttpUtility.UrlEncode(SI.EWinCT) + "&Lang=" + Lang);
            } else {
                Response.Write("NotSupportDemo");
                Response.Flush();
                Response.End();
            }
        } else {
            Response.Redirect(EWinWeb.EWinUrl + "/API/GamePlatformAPI/" + GameBrand + "/UserLogin.aspx?SID=" + SI.EWinSID + "&Language=" + Lang + "&CurrencyType=" + CurrencyType + "&GameName=" + GameName + "&HomeUrl=" + HomeUrl + "&DemoPlay=" + DemoPlay);
        }
    } else {
        if (DemoPlay == "1") {
            Response.Redirect(EWinWeb.EWinUrl + "/API/GamePlatformAPI/" + GameBrand + "/UserLogin.aspx?Language=" + Lang + "&CurrencyType=" + CurrencyType + "&GameName=" + GameName + "&HomeUrl=" + HomeUrl + "&DemoPlay=" + DemoPlay);
        } else {
            Response.Write("LoginStateExpire");
            Response.Flush();
            Response.End();
        }
    }
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maharaja</title>
</head>

<body>
    <div class="loader-container">
        <div class="loader-box">
            <div class="loader-spinner">
                <div></div>
            </div>
            <div class="loader-text">Loading...</div>
        </div>
        <div class="loader-backdrop"></div>
    </div>
</body>
</html>
