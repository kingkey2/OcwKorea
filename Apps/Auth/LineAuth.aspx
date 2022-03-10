<%@ Page Language="C#" %>
<%
    string Token;
    string LineAppKeyFile;

    LineAppKeyFile = Server.MapPath("/App_Data/LineLogin.json");

    Token = Request["Token"];
    if (string.IsNullOrEmpty(Token) == false)
    {
        if (RedisCache.AppLogin.CheckTokenExist(Token))
        {
            if (System.IO.File.Exists(LineAppKeyFile))
            {
                string Content;
                Newtonsoft.Json.Linq.JObject o = null;

                Content = System.IO.File.ReadAllText(LineAppKeyFile);

                try
                {
                    o = Newtonsoft.Json.Linq.JObject.Parse(Content);
                }
                catch (Exception ex)
                {
                }

                if (o != null)
                {
                    string ChannelID;
                    string Secret;
                    string CallbackURL;
                    string URL;

                    ChannelID = EWinWeb.GetJValue(o, "ChannelID");
                    Secret = EWinWeb.GetJValue(o, "Secret");
                    CallbackURL = EWinWeb.GetJValue(o, "CallbackURL");

                    URL = "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=" + ChannelID + "&redirect_uri=" + Server.UrlEncode(CallbackURL) + "&state=" + Server.UrlEncode(Token) + "&scope=openid%20profile";

                    Response.Redirect(URL);
                    Response.Flush();
                    Response.End();
                }
                else
                {
                    Response.Write("KeyFileInvalid");
                    Response.Flush();
                    Response.End();
                }
            }
            else
            {
                Response.Write("KeyFileInvalid");
                Response.Flush();
                Response.End();
            }
        }
        else
        {
            Response.Write("InvalidToken");
            Response.Flush();
            Response.End();
        }
    }
    else
    {
        Response.Write("InvalidToken");
        Response.Flush();
        Response.End();
    }
%>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>

</head>
<body>
</body>
</html>
