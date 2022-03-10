<%@ Page Language="C#" AutoEventWireup="true" EnableSessionState="False" CodeFile="AuthCommon.cs" Inherits="AuthCommon" %>

<%
//string CODE;
//string State;
//Newtonsoft.Json.Linq.JObject o = null;
//string Content;
//string LineAppKeyFile;
//RedisCache.UserAccountBinding.UserAccountBindingType BindingType = RedisCache.UserAccountBinding.UserAccountBindingType.Line;
//int dt = 0;
//string MainCurrencyType = EWinWeb.MainCurrencyType;
//EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();

////http://ewin.dev.mts.idv.tw/Apps/Auth/LineAuthCallback.aspx?code=o3zhgl66sCKEph3833ux&state=12345abcde
//if (string.IsNullOrEmpty(Request["code"]) == false) {
//    CODE = Request["code"];
//    State = Request["state"];

//    if (string.IsNullOrEmpty(CODE) == false) {
//        LineAppKeyFile = Server.MapPath("/App_Data/LineLogin.json");

//        if (System.IO.File.Exists(LineAppKeyFile)) {
//            Content = System.IO.File.ReadAllText(LineAppKeyFile);

//            try {
//                o = Newtonsoft.Json.Linq.JObject.Parse(Content);
//            } catch (Exception ex) {
//            }

//            if (o != null) {
//                string ChannelID;
//                string Secret;
//                string CallbackURL;
//                string API_URL;
//                string API_POST;
//                string Info_URL;
//                string AccessToken;
//                string IdToken = string.Empty;
//                string UniqueID = string.Empty;
//                string Nickname = string.Empty;
//                string HeadImg = string.Empty;
//                Newtonsoft.Json.Linq.JObject Token_O = null;
//                Newtonsoft.Json.Linq.JObject Info_O = null;
//                RedisCache.AppLogin.TokenContent TC;

//                TC = RedisCache.AppLogin.GetToken(State);

//                if (TC != null) {
//                    ChannelID = EWinWeb.GetJValue(o, "ChannelID");
//                    Secret = EWinWeb.GetJValue(o, "Secret");
//                    CallbackURL = EWinWeb.GetJValue(o, "CallbackURL");

//                    // 取得 Access_token
//                    API_URL = "https://api.line.me/oauth2/v2.1/token";
//                    API_POST = "grant_type=authorization_code&code=" + CODE + "&redirect_uri=" + Server.UrlEncode(CallbackURL) + "&client_id=" + ChannelID + "&client_secret=" + Secret;
//                    Content = CodingControl.GetWebTextContent(API_URL, "POST", API_POST);
//                    if (string.IsNullOrEmpty(Content) == false) {
//                        try {
//                            Token_O = Newtonsoft.Json.Linq.JObject.Parse(Content);
//                        } catch (Exception ex) {
//                        }

//                        if (Token_O != null) {
//                            if (string.IsNullOrEmpty(EWinWeb.GetJValue(Token_O, "error"))) {
//                                string UserInfoContent = string.Empty;
//                                string[] JWTArray;

//                                AccessToken = EWinWeb.GetJValue(Token_O, "access_token");
//                                IdToken = EWinWeb.GetJValue(Token_O, "id_token");

//                                JWTArray = IdToken.Split('.');
//                                if (JWTArray.Length >= 2) {
//                                    string EachJWT = JWTArray[1];

//                                    if (string.IsNullOrEmpty(EachJWT) == false) {
//                                        string JSONContent = null;

//                                        // JWT base64 使用 base64urlencode
//                                        // 轉換表: '-' -> '+'
//                                        //         '_' -> '/'
//                                        //         c -> c
//                                        try { JSONContent = CodingControl.Base64URLDecode(EachJWT); } catch (Exception ex) { }

//                                        //Response.Write(EachJWT.Length + ":" + (EachJWT + new string('=', EachJWT.Length % 4)) + "<br>");

//                                        if (string.IsNullOrEmpty(JSONContent) == false) {
//                                            JSONContent = JSONContent.Trim();

//                                            if ((JSONContent.Substring(0, 1) == "{") && (JSONContent.Substring(JSONContent.Length - 1, 1) == "}")) {
//                                                // is JSON text
//                                                if (JSONContent.IndexOf("\"iss\"") != -1) {
//                                                    UserInfoContent = JSONContent;

//                                                    try {
//                                                        Info_O = Newtonsoft.Json.Linq.JObject.Parse(JSONContent);
//                                                    } catch (Exception ex) {
//                                                        Response.Write(ex.ToString());
//                                                        Response.Flush();
//                                                        Response.End();
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }

//                                if (Info_O != null) {
//                                    int CompanyID = 0;
//                                    System.Data.DataTable CompanyDT;

//                                    UniqueID = EWinWeb.GetJValue(Info_O, "sub");
//                                    Nickname = EWinWeb.GetJValue(Info_O, "name");
//                                    HeadImg = EWinWeb.GetJValue(Info_O, "picture");


//                                    if ((CompanyID != 0) && (string.IsNullOrEmpty(UniqueID) == false)) {
//                                        RedisCache.UserAccountBinding.UserAccountBingingInfo UBInfo;
//                                        bool CreateNewAccount = false;
//                                        string LoginAccount = null;
//                                        bool AllowLogin = false;
//                                        int UserAccountState = 0;
//                                        string ParentPCode = "";

//                                        UBInfo = RedisCache.UserAccountBinding.GetUBInfo((RedisCache.UserAccountBinding.UserAccountBindingType)BindingType, UniqueID);
//                                        if (UBInfo != null) {
//                                            LoginAccount = UBInfo.LoginAccount;
//                                            ParentPCode = UBInfo.ParentPersonCode;
//                                            UserAccountState = UBInfo.UserAccountState;
//                                        } else {
//                                            CreateNewAccount = true;
//                                        }

//                                        if (CreateNewAccount) {
//                                            RedisCache.AppLogin.UpdateUserCreateType(TC.AppToken, RedisCache.AppLogin.TokenContent.enumUserCreateType.NewUser);

//                                            if (String.IsNullOrEmpty(TC.BindingLoginAccount)) {
//                                                EWin.Lobby.APIResult result;                   
//                                                result = lobbyAPI.CreateAccount(GetToken(), System.Guid.NewGuid(), LoginAccount, )

//                                                // 強制綁定帳戶
//                                                string SS;
//                                                string BindingInfo;
//                                                System.Data.SqlClient.SqlCommand DBCmd = null;

//                                                DBAccess.ExecuteTransDB(EWin.DBConnStr, (DBAccess.TransactionDB T) => {
//                                                    // 強制綁定主帳戶
//                                                    EWinDB.UserAccount.DBAddUserAccountBinding(TC.BindingUserAccountID, BindingType, UniqueID, Nickname, HeadImg, UserInfoContent);

//                                                    // 產生綁定資訊
//                                                    BindingInfo = EWin.GetUserAccountBindingInfo(TC.BindingUserAccountID);

//                                                    SS = "UPDATE UserAccount SET BindingInfo=@BindingInfo WHERE UserAccountID=@UserAccountID";
//                                                    DBCmd = new System.Data.SqlClient.SqlCommand();
//                                                    DBCmd.CommandText = SS;
//                                                    DBCmd.CommandType = System.Data.CommandType.Text;
//                                                    DBCmd.Parameters.Add("@BindingInfo", System.Data.SqlDbType.VarChar).Value = BindingInfo;
//                                                    DBCmd.Parameters.Add("@UserAccountID", System.Data.SqlDbType.Int).Value = TC.BindingUserAccountID;
//                                                    DBAccess.ExecuteDB(EWin.DBConnStr, DBCmd);

//                                                    RedisCache.UserAccount.UpdateUserAccountByID(TC.BindingUserAccountID);
//                                                    T.Commit();

//                                                    AllowLogin = true;
//                                                });
//                                            } else {

//                                            }
//                                        } else {
//                                            // 不用建立新帳戶
//                                            // 直接登入
//                                            RedisCache.AppLogin.UpdateUserCreateType(TC.AppToken, RedisCache.AppLogin.TokenContent.enumUserCreateType.ExistUser);

//                                            if (TC.ParentUserAccountID != pID)
//                                                dt = -1;

//                                            if (UserAccountState == 0)
//                                                AllowLogin = true;
//                                        }


//                                        if (AllowLogin) {
//                                            if (TC.BindingUserAccountID == 0) {
//                                                if (string.IsNullOrEmpty(LoginAccount) == false) {
//                                                    string SID = null;
//                                                    string Token = null;
//                                                    string ApiKey = null;
//                                                    Random R = new Random();
//                                                    int RandomValue;
//                                                    System.Data.DataTable ApiKeyDT;
//                                                    bool isGuestAccount = false;

//                                                    if (string.IsNullOrEmpty((string)CompanyDT.Rows[0]["GuestAccount"]) == false) {
//                                                        if (LoginAccount.ToUpper() == ((string)CompanyDT.Rows[0]["GuestAccount"]).ToUpper()) {
//                                                            isGuestAccount = true;
//                                                        }
//                                                    }

//                                                    ApiKeyDT = EWinDB.ApiKey.DBGetApiKeyByCompanyID(CompanyID);
//                                                    if (ApiKeyDT != null) {
//                                                        if (ApiKeyDT.Rows.Count > 0) {
//                                                            ApiKey = (string)ApiKeyDT.Rows[0]["ApiKey"];
//                                                        }
//                                                    }

//                                                    SID = RedisCache.SessionContext.CreateSID((string)CompanyDT.Rows[0]["CompanyCode"], LoginAccount, true, CodingControl.GetUserIP(), isGuestAccount, string.Empty);
//                                                    RedisCache.SessionContext.BindingUID(SID, 1, UniqueID, Nickname, HeadImg);

//                                                    RandomValue = R.Next(1, 999999);
//                                                    // 重建 Token
//                                                    if (ApiKeyDT != null) {
//                                                        if (ApiKeyDT.Rows.Count > 0) {
//                                                            Token = RandomValue + "_" + ApiKey + "_" + CodingControl.GetMD5(RandomValue + ":" + ApiKey + ":" + ((string)ApiKeyDT.Rows[0]["PrivateKey"]).ToUpper(), false);
//                                                        }
//                                                    }

//                                                    if ((string.IsNullOrEmpty(Token) == false) && (string.IsNullOrEmpty(SID) == false)) {
//                                                        string CT = EWin.GetClientToken(Token, SID);

//                                                        if (string.IsNullOrEmpty(TC.CallbackURL) == false)
//                                                            Response.Redirect(TC.CallbackURL + "?Result=Success&AppToken=" + Server.UrlEncode(TC.AppToken) + "&CT=" + Server.UrlEncode(CT));
//                                                    }
//                                                } else {
//                                                    // 無產生帳號, 系統錯誤
//                                                }
//                                            } else {
//                                                // 強制綁定, 返回首頁
//                                                Response.Redirect("index.aspx?dt=1");
//                                            }
//                                        } else {
//                                            // 無法登入
//                                            Response.Redirect("index.aspx?dt=-2");
//                                        }
//                                    }
//                                } else {
//                                    Response.Write("Exception 1<br>" + Content);
//                                    Response.Flush();
//                                    Response.End();
//                                }
//                            } else {
//                                Response.Write(Content + "<br>" + "POST Data:" + API_POST);
//                                Response.Flush();
//                                Response.End();
//                            }
//                        } else {
//                            Response.Write("Exception 2");
//                            Response.Flush();
//                            Response.End();
//                        }
//                    }
//                } else {
//                    Response.Write("InvalidToken");
//                    Response.Flush();
//                    Response.End();
//                }
//            } else {
//                Response.Write("KeyFileInvalid");
//                Response.Flush();
//                Response.End();
//            }
//        } else {
//            Response.Write("KeyFileInvalid");
//            Response.Flush();
//            Response.End();
//        }
//    } else {
//        // 用戶取消
//    }
//}
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
