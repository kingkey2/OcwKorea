<%@ Page Language="C#" %>

<%
    /*
    Req:
        Token
    Resp:
        {
            "Image": "xxxxxx",
            "LoginGUID": "cccccc"
        }
    */

    Random R = new Random();
    int RValue = R.Next(100000, 9999999);
    string Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());
    string LoginGUID = null;
    dynamic Resp = new System.Dynamic.ExpandoObject();
    EWin.Login.LoginAPI LoginAPI = new EWin.Login.LoginAPI();

    Resp.Result = 1;
    Resp.Message = "Other";

    LoginGUID = LoginAPI.CreateLoginGUID(Token);
    if (string.IsNullOrEmpty(LoginGUID) == false) {
        byte[] ImageContent;

        ImageContent = LoginAPI.GetValidateImage(Token, LoginGUID);
        if (ImageContent != null) {
            Resp.Result = 0;
            Resp.Message = string.Empty;

            // image is PNG
            Resp.Image = "data:image/png;base64," + Convert.ToBase64String(ImageContent);
            Resp.LoginGUID = LoginGUID;
        }
    }

    Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(Resp));
    Response.Flush();
    Response.End();
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
