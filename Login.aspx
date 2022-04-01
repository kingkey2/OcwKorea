<%@ Page Language="C#" %>

<%
    string Token;
    string WebSID = null;
    int RValue;
    Random R = new Random();
    string Version = EWinWeb.Version;

    if (CodingControl.FormSubmit()) {
        string LoginGUID = Request["LoginGUID"];
        string LoginPassword = Request["LoginPassword"];
        string ValidImg = Request["ValidImg"];
        string LoginAccount = Request["LoginAccount"];
        string PhonePrefix = Request["PhonePrefix"];
        string PhoneNumber = Request["PhoneNumber"];
        string LoginType = Request["LoginType"];
        string NewFingerPrint = Request["FingerPrint"];
        bool IsOldFingerPrint = false;
        string UserAgent = Request["UserAgent"];

        Newtonsoft.Json.Linq.JObject obj_FingerPrint = new Newtonsoft.Json.Linq.JObject();
        Newtonsoft.Json.Linq.JArray arr_FingerPrint = new Newtonsoft.Json.Linq.JArray();
        string UserIP = CodingControl.GetUserIP();
        System.Data.DataTable DT;

        EWin.Login.LoginResult LoginAPIResult;
        EWin.Login.LoginAPI LoginAPI = new EWin.Login.LoginAPI();


        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        LoginAPIResult = LoginAPI.UserLogin(Token, LoginGUID, LoginAccount, LoginPassword, EWinWeb.CompanyCode, ValidImg, UserIP);

        if (LoginAPIResult.ResultState == EWin.Login.enumResultState.OK) {

            WebSID = RedisCache.SessionContext.CreateSID(EWinWeb.CompanyCode, LoginAccount, UserIP, false, LoginAPIResult.SID, LoginAPIResult.CT);

            if (string.IsNullOrEmpty(WebSID) == false)
            {
                DT = RedisCache.UserAccountFingerprint.GetUserAccountFingerprint(LoginAccount);

                if (DT != null && DT.Rows.Count > 0)
                {
                    for (int i = 0; i < DT.Rows.Count; i++)
                    {
                        if (DT.Rows[i]["FingerprintID"].ToString() == NewFingerPrint)
                        {
                            IsOldFingerPrint = true;
                            break;
                        }
                    }
                }

                if (LoginType == "0")
                {
                    if (IsOldFingerPrint == false)
                    {
                        EWinWebDB.UserAccountFingerprint.InsertUserAccountFingerprint(LoginAccount, NewFingerPrint, UserAgent);
                        RedisCache.UserAccountFingerprint.UpdateUserAccountFingerprint(LoginAccount);
                    }
                }

                Response.SetCookie(new HttpCookie("RecoverToken", LoginAPIResult.RecoverToken) { Expires = System.DateTime.Parse("2038/12/31") });
                Response.SetCookie(new HttpCookie("LoginAccount", LoginAccount) { Expires = System.DateTime.Parse("2038/12/31") });
                Response.SetCookie(new HttpCookie("SID", WebSID));
                Response.SetCookie(new HttpCookie("CT", LoginAPIResult.CT));

                Response.Redirect("RefreshParent.aspx?index.aspx");

            }
            else
            {
                Response.Write("<script> var defaultError = function(){ window.parent.showMessageOK('', mlp.getLanguageKey('登入失敗') ,function () { })};</script>");
            }

        } else {
            Response.Write("<script>var defalutLoginAccount = '" + LoginAccount + "'; var defaultError = function(){ window.parent.showMessageOK('', mlp.getLanguageKey('登入失敗') + ' ' +  mlp.getLanguageKey('" + LoginAPIResult.Message + "'),function () { })};</script>");
            //Response.Write("<script>var defalutLoginAccount = '" + LoginAccount +"'; var defaultError = function(){ window.parent.showMessageOK('', mlp.getLanguageKey('登入失敗'),function () { })};</script>");
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

    //function checkDevice() {
    //    window.parent.API_LoadPage("LoginByFP", "LoginByFP.aspx")
    //}

    function updateBaseInfo() {
    }

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        if (typeof (defalutLoginAccount) != 'undefined') {
            var form = document.getElementById("idFormUserLogin");
            form.LoginAccount.value = defalutLoginAccount;
            form.LoginPassword.value = "";
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

                    var form = document.getElementById("idFormUserLogin");
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

        CreateLoginValidateCode();
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

    function CreateLoginValidateCode() {
        var iURL;
        var now = new Date();

        iURL = "/GetValidateImage.aspx?" + "time=" + now.getTime();

        c.callService(iURL, null, function (success, text) {
            if (success == true) {
                var o = c.getJSON(text);

                if (o.Result == 0) {
                    var idValidImage = document.getElementById("idLoginValidImage");
                    var idFormUserLogin = document.getElementById("idFormUserLogin");

                    idFormUserLogin.LoginGUID.value = o.LoginGUID;

                    if (idValidImage != null) {
                        idValidImage.src = o.Image;
                    }
                }
            }
        });
    }

    function CheckAccountPhoneExist() {

        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");

        idPhoneNumber.setCustomValidity("");
        idPhonePrefix.setCustomValidity("");

        if (idPhonePrefix.value == "") {
            idPhonePrefix.setCustomValidity(mlp.getLanguageKey("請輸入國碼"));
            return;
        } else if (idPhoneNumber.value == "") {
            idPhoneNumber.setCustomValidity(mlp.getLanguageKey("請輸入電話"));
            return;
        } else {
            var phoneValue = idPhonePrefix.value + idPhoneNumber.value;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    idPhoneNumber.setCustomValidity(mlp.getLanguageKey("電話格式有誤"));
                    return;
                }
            } catch (e) {
                idPhoneNumber.setCustomValidity(mlp.getLanguageKey("電話格式有誤"));
                return;
            }
        }
    }

    function onBtnSendLogin() {
        var form = document.getElementById("idFormUserLogin");

        initValid(form);

        if (form.checkValidity()) {
            if (form.LoginAccount.value.trim() == "") {
                form.LoginAccount.setCustomValidity(mlp.getLanguageKey("請輸入帳號"));
            } else if (form.LoginPassword.value.trim() == "") {
                form.LoginPassword.setCustomValidity(mlp.getLanguageKey("請輸入密碼"));
            } else if (form.ValidImg.value.trim() == "") {
                form.ValidImg.setCustomValidity(mlp.getLanguageKey("請輸入驗證碼"));
            }
        }
     



        //else if (form.LoginAccount.value != "") {
        //    if (!IsEmail(form.LoginAccount.value)) {
        //        form.LoginAccount.setCustomValidity(mlp.getLanguageKey("請填寫正確的E-MAIL格式"));
        //    }
        //}

        form.reportValidity();

        if (form.checkValidity()) {
            form.action = "Login.aspx";
            form.submit();
        }
    }

    function onBtnForgotPassword() {
        window.parent.API_LoadPage("ForgotPassword", "ForgotPassword.aspx")
    }

    function onBtnRegister() {
        window.parent.API_LoadPage("Register", "Register.aspx")
    }

    function showPassword(btn) {
        var x = document.getElementById(btn);
        var iconEye = event.currentTarget.querySelector("i");

        if (x.type === "password") {
            x.type = "text";
            if (iconEye) {
                iconEye.classList.remove("icon-eye-off");
                iconEye.classList.add("icon-eye");
            }
        } else {
            x.type = "password";
            if (iconEye) {
                iconEye.classList.add("icon-eye-off");
                iconEye.classList.remove("icon-eye");
            }
        }
    }

    function initValid(form) {
        if (form.tagName.toUpperCase() == "FORM") {
            var formInputs = form.getElementsByTagName("input");
            for (var i = 0; i < formInputs.length; i++) {
                formInputs[i].setCustomValidity('');
            }
        }
    }

    function IsEmail(email) {
        var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (!regex.test(email)) {
            return false;
        } else {
            return true;
        }
    }

    function onChangePhonePrefix() {
        var value = event.currentTarget.value;
        if (value && typeof (value) == "string" && value.length > 0) {
            if (value[0] != "+") {
                event.currentTarget.value = "+" + value;
            }
        }
    }

    window.onload = init;
</script>
<body>
    <div class="layout-full-screen sign-container" data-form-group="signContainer">

        <!-- <div class="logo" data-click-btn="backToHome">
            <img src="images/assets/logo-icon.png">
        </div> -->

        <div class="btn-back is-hide" data-click-btn="backToSign">
            <div></div>
        </div>

        <!-- 側邊影像 -->
        <div class="feature-panel"></div>

        <!-- 主內容框 -->
        <div class="main-panel">

            <!-- 會員登入 -->
            <div class="form-container" data-form-group="signIn" id="idLoginContent">
                <div class="heading-title">
                    <h3 class="language_replace">會員登入</h3>
                </div>
                <div class="identity_login slideButton-menu-container">
                  <%--  <div class="slideButton-menu-wraper">
                        <button onclick="setLoginType(1)" class="btn menu-item active" id="btnPhone"><i class="icon icon-casinoworld-smartphone"></i><span class="language_replace">電話登入</span></button>
                        <button onclick="setLoginType(0)" class="btn menu-item " id="btnMail"><i class="icon icon-casinoworld-mail"></i><span class="language_replace">信箱登入</span></button>
                        <div class="tracking-bar"></div>
                    </div>--%>
                </div>
                <div class="form-content">
                    <form method="post" id="idFormUserLogin">
                        <input type="hidden" name="FingerPrint" value="" />
                        <input type="hidden" name="LoginGUID" value="" />
                        <input id="idLoginType" type="hidden" name="LoginType" value="1" />
                        <div id="idMailLoginGroup" class="form-group">
                            <label class="form-title language_replace">帳號</label>
                            <div class="input-group">
                                <input type="text" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入帳號"  name="LoginAccount">
                                <div class="invalid-feedback language_replace">請輸入帳號</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-title language_replace">密碼</label>
                            <div class="input-group">
                                <input id="LoginPassword" type="password" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入密碼" name="LoginPassword">
                                <div class="invalid-feedback language_replace">請輸入密碼</div>
                            </div>
                            <button class="btn btn-icon" type="button" onclick="showPassword('LoginPassword')">
                                <i class="icon-eye-off"></i>
                            </button>
                            <a class="text-link underline" data-click-btn="restPassword" onclick="onBtnForgotPassword()">
                                <span class="language_replace">忘記密碼？</span>
                            </a>
                        </div>

                        <div class="ValidateDiv form-group">
                            <label class="form-title language_replace">驗證碼</label>
                            <div class="input-group">
                                <input type="text" class="form-control custom-style" name="ValidImg" language_replace="placeholder" placeholder="輸入驗證碼" autocomplete="off">
                                <div class="invalid-feedback language_replace">請輸入驗證碼</div>
                            </div>
                            <div class="ValidateImg">
                                <img id="idLoginValidImage" alt="" />
                            </div>
                        </div>

                        <div class="form-row my-2 my-md-5" style="display: none;">
                            <div class="form-group col-12">
                                <button class="btn btn-outline-primary btn-full btn-icon-custom icon-before icon-google" type="button" onclick="">
                                    <span class="language_replace">Sign in with Google</span>
                                </button>
                            </div>
                            <div class="form-group col-12">
                                <button class="btn btn-outline-primary btn-full btn-icon-custom icon-before icon-apple" type="button" onclick="">
                                    <span class="language_replace">Sign in with Apple</span>
                                </button>
                            </div>

                        </div>



                        <div class="btn-container mt-2">
                            <button type="button" class="btn btn-primary" onclick="onBtnSendLogin()"><span class="language_replace">登入</span></button>
                        </div>
                    </form>
                </div>
                <div class="get-start-header">
                    <div class="language_replace">還沒有帳號嗎?</div>
                    <button type="button" class="btn btn-outline-primary btn-sm" onclick="onBtnRegister()">
                        <span class="language_replace">前往註冊</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
