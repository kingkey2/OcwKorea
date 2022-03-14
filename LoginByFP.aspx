<%@ Page Language="C#" %>

<%
    string Token;
    string SID;
    int RValue;
    Random R = new Random();
    string Version = EWinWeb.Version;
    System.Data.DataTable DT;
    string OldFingerPrint;
    Newtonsoft.Json.Linq.JObject obj_FingerPrint = new Newtonsoft.Json.Linq.JObject();
    Newtonsoft.Json.Linq.JArray arr_FingerPrint = new Newtonsoft.Json.Linq.JArray();

    if (CodingControl.FormSubmit()) {
        string FingerPrint = Request["FingerPrint"];
        string ValidCode = Request["ValidCode"];

        string JsonStr = RedisCache.FingerPrint.GetFingerPrint(FingerPrint);

        if (string.IsNullOrEmpty(JsonStr) == false) {
            Newtonsoft.Json.Linq.JObject jObject = Newtonsoft.Json.Linq.JObject.Parse(JsonStr);

            if (jObject != null) {
                if (jObject["ValidateCode"].ToString() == ValidCode) {

                    DT = RedisCache.UserAccountTotalSummary.GetUserAccountTotalSummaryByLoginAccount(jObject["LoginAccount"].ToString());

                    if (DT != null && DT.Rows.Count > 0) {
                        OldFingerPrint = DT.Rows[0]["FingerPrints"].ToString();
                        if (!string.IsNullOrEmpty(OldFingerPrint)) {
                            arr_FingerPrint = Newtonsoft.Json.Linq.JArray.Parse(OldFingerPrint);
                        }
                    } else {
                        OldFingerPrint = "";
                    }

                    if (OldFingerPrint.IndexOf(FingerPrint) < 0) {
                        obj_FingerPrint.Add("FingerPrintName", FingerPrint);
                        arr_FingerPrint.Add(obj_FingerPrint);
                    }

                    if (EWinWebDB.UserAccountTotalSummary.UpdateFingerPrint(Newtonsoft.Json.JsonConvert.SerializeObject(arr_FingerPrint), jObject["LoginAccount"].ToString()) == 0) {
                        EWinWebDB.UserAccountTotalSummary.InsertUserAccountTotalSummary(Newtonsoft.Json.JsonConvert.SerializeObject(arr_FingerPrint), jObject["LoginAccount"].ToString());
                    }

                    RedisCache.UserAccountTotalSummary.UpdateUserAccountTotalSummaryByLoginAccount(jObject["LoginAccount"].ToString());

                    Response.SetCookie(new HttpCookie("RecoverToken", jObject["RecoverToken"].ToString()) { Expires = System.DateTime.Parse("2038/12/31") });
                    Response.SetCookie(new HttpCookie("LoginAccount", jObject["LoginAccount"].ToString()) { Expires = System.DateTime.Parse("2038/12/31") });
                    Response.SetCookie(new HttpCookie("SID", jObject["SID"].ToString()));
                    Response.SetCookie(new HttpCookie("CT", jObject["CT"].ToString()));

                    Response.Redirect("RefreshParent.aspx?index.aspx");
                } else {
                    Response.Write("<script>var defaultError = function(){ window.parent.API_ShowMessageOK('', mlp.getLanguageKey('驗證碼錯誤'))}</script>");
                }
            } else {
                Response.Write("<script>var defaultError = function(){ window.parent.API_ShowMessageOK('', mlp.getLanguageKey('驗證碼錯誤'))}</script>");
            }
        } else {
            Response.Write("<script>var defaultError = function(){ window.parent.API_ShowMessageOK('', mlp.getLanguageKey('驗證碼錯誤'))}</script>");
        }
    }
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Casino World</title>

    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="css/icons.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/global.css?<%:Version%>" type="text/css" />
</head>

<script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
<script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="Scripts/OutSrc/js/script.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/libphonenumber.js"></script>
<script type="text/javascript" src="/Scripts/fingerprint.js"></script>
<script type="text/javascript">      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var c = new common();
    var ui = new uiControl();
    var mlp;
    var lang;
    var WebInfo;
    var LoginType = 1; //0=信箱登入，1=電話登入
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();
    var v = "<%:Version%>";
    var visitorId;


    function updateBaseInfo() {
    }

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        } 

        WebInfo = window.parent.API_GetWebInfo();
        lang = window.parent.API_GetLang();

        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            FingerprintJS.load().then(fp => {
                // The FingerprintJS agent is ready.
                // Get a visitor identifier when you'd like to.
                fp.get().then(result => {
                    // This is the visitor identifier:
                    visitorId = result.visitorId;
                    var form = document.getElementById("idFormFingerPrint");
                    form.FingerPrint.value = visitorId;

                    window.parent.API_LoadingEnd();

                    if (WebInfo.UserLogined == true) {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("您已登入"), function () {
                            window.parent.API_Home();
                        });
                    } else {
                        if (typeof (defaultError) != 'undefined') {
                            defaultError();
                        }
                    }
                });
            });
        });
    }

    function onBtnSendLogin() {
        var form = document.getElementById("idFormFingerPrint");
        var ValiCode = idFormFingerPrint.ValidCode.value;

        if (ValiCode != '') {
            form.action = "LoginByFP.aspx";
            form.submit();
        } else {
            window.parent.API_ShowMessageOK("", mlp.getLanguageKey("錯誤") + " " + mlp.getLanguageKey("請輸入驗證碼"));
        }
    }

    function EWinEventNotify(eventName, isDisplay, param) {
        switch (eventName) {
            case "LoginState":
                //updateBaseInfo();

                break;
            case "BalanceChange":
                break;

            case "SetLanguage":
                var lang = param;

                mlp.loadLanguage(lang);
                break;
        }
    }

    window.onload = init;
</script>
<body>
    <div class="layout-full-screen sign-container" data-form-group="signContainer">

        <!-- <div class="logo" data-click-btn="backToHome">
            <img src="images/assets/logo-icon.png">
        </div> -->

        <!-- 側邊影像 -->
        <div class="feature-panel"></div>

        <!-- 主內容框 -->
        <div class="main-panel">

            <div class="form-container" data-form-group="signIn" id="idCheckFPContent">
                <div class="heading-title">
                    <h3 class="language_replace">裝置驗證</h3>
                </div>

                <div class="form-content">
                    <form method="post" id="idFormFingerPrint">
                        <div class="form-group">
                            <span class="language_replace">已偵測到您使用不同的裝置登入，請使用註冊的手機接收驗證碼並填入送出</span>
                        </div>
                        <input type="hidden" name="FingerPrint" value="" />
                        <div class="ValidateDiv form-group">
                            <label class="form-title language_replace">驗證碼</label>
                            <div class="input-group">
                                <input type="text" class="form-control custom-style" name="ValidCode" language_replace="placeholder" placeholder="輸入驗證碼" autocomplete="off" maxlength="4">
                            </div>
                        </div>

                        <div class="btn-container mt-2">
                            <button type="button" class="btn btn-primary" onclick="onBtnSendLogin()"><span class="language_replace">送出</span></button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
