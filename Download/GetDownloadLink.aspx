<%@Page Language="C#"%>
<%
    string Tag;
    int UserDeviceType = 0; // 0=Unknow, 1=Android, 2=iOS

    Tag = Request["Tag"];

    if (string.IsNullOrEmpty(Request["Type"]))
    {
        if (Request.UserAgent.IndexOf("Android") != -1)
        {
            UserDeviceType = 1;
        }
        else
        {
            if (Request.UserAgent.IndexOf("iOS") != -1)
            {
                UserDeviceType = 2;
            }
            else if (Request.UserAgent.IndexOf("iPhone") != -1)
            {
                UserDeviceType = 2;
            }
            else if (Request.UserAgent.IndexOf("iPad") != -1)
            {
                UserDeviceType = 2;
            }
        }
    }
    else
    {
        UserDeviceType = Convert.ToInt32(Request["Type"]);
    }

    if (UserDeviceType == 0) {
        //Response.Redirect((string)DT.Rows[0]["PCLink"]);
    } else if (UserDeviceType == 1) {
        Response.Redirect(EWinWeb.CasinoWorldUrl + "/Download/MaharajaAgent.apk");
    } else if (UserDeviceType == 2) {
        Response.Redirect("https://erff.top:10121/896ac6d9");
    }
%>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Content-Language" content="zh-tw">
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body style="width: 100%; padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px">
</body>
</html>