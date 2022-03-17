<%@ Page Language="C#" %>

<%
//r
//string Token;
//int RValue;
//Random R = new Random();


//RValue = R.Next(100000, 9999999);

//Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());
   string Version=EWinWeb.Version;

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
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script>      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var c = new common();
    var LobbyAPIUrl = "<%=EWinWeb.EWinUrl %>" + "/API/LobbyAPI.asmx";
    var mlp;
    var lang;
    var WebInfo;
    var p;
    var isSent = false;
    var v ="<%:Version%>";
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();


    function BackLogin() {
        window.parent.API_LoadPage("Login", "Login.aspx");
    }

    function SendPhone() {

        if (isSent) {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("已發送驗證碼，短時間內請勿重複發送"));
            return;
        }
       
        var GUID = Math.uuid();
        var ValidateType = 0;
        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");


        if (idPhonePrefix.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入國碼"));
            return;
        } else if (idPhoneNumber.value == "") {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入電話"));
            return;
        } else {
            var phoneValue = idPhonePrefix.value + idPhoneNumber.value;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));
                    return;
                }
            } catch (e) {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("電話格式有誤"));            
                return;
            }
        }


        p.CheckAccountExistByContactPhoneNumber(Math.uuid(), idPhonePrefix.value, idPhoneNumber.value, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    p.SetUserMail(GUID, 1, 1, "", idPhonePrefix.value, idPhoneNumber.value, mlp.getLanguageKey("您的驗證碼為 ({0})\r\n請您於2分鐘內驗證，如超過時間，請重新發送驗證碼。"), function (success, o) {
                        if (success) {
                            if (o.Result == 0) {
                                isSent = true;
                                startCountDown(120);
                                window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("已寄送認證碼"));
                            } else {
                                window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("發送失敗，請重新發送"));
                            }
                        } else {
                            window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路錯誤") + ":" + mlp.getLanguageKey(o.Message));
                        }
                    });
                } else {
                    window.parent.showMessageOK("", mlp.getLanguageKey("電話不存在"));
                }
            }
        });

    }

    function SetNewPassword(validCode, newPassword) {


        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");
        var GUID = Math.uuid();
        var ValidateType = 1;
        var EMail = '';
        var ValidateCode = validCode;
        var NewPassword = newPassword;


        //c.callService(LobbyAPIUrl + "/SetUserPasswordByValidateCode", postObj, function (success, content) {
        p.SetUserPasswordByValidateCode(GUID, ValidateType, EMail, idPhonePrefix.value, idPhoneNumber.value, ValidateCode, NewPassword, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    window.parent.showMessageOK("", mlp.getLanguageKey("已成功修改密碼！"), function () {
                        window.parent.API_LoadPage("Login", "Login.aspx");
                    });
                } else {
                    window.parent.showMessageOK("", mlp.getLanguageKey("錯誤") + ":" + mlp.getLanguageKey(o.Message));
                }
            } else {
                window.parent.showMessageOK("", mlp.getLanguageKey("發送失敗，請重新發送"));
            }
        });
    }

    function formSubmitCheck() {
        if (isSent) {

            let ValidCode = document.getElementById("idValidCode");
            let Password = document.getElementById("idNewPassword");

            if (ValidCode.value == "") {
                ValidCode.setCustomValidity(mlp.getLanguageKey("錯誤, 請輸入認證碼"));
                ValidCode.reportValidity();

                return;
            } else if (Password.value == "") {
                Password.setCustomValidity(mlp.getLanguageKey("錯誤, 請輸入新密碼"));
                Password.reportValidity();

                return
            } else {
                ValidCode.setCustomValidity("");
                Password.setCustomValidity("");
            }

            SetNewPassword(ValidCode.value, Password.value);
        } else {
            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請先取得驗證碼"));
        }

    }

    function SetBtnSend() {
        let BtnSend = document.getElementById("btnSend");
        BtnSend.querySelector("span").innerText = mlp.getLanguageKey("取得驗證碼");
        isSent = false;
    }

    function startCountDown(duration) {

        let secondsRemaining = duration;
        let min = 0;
        let sec = 0;

        let countInterval = setInterval(function () {
            let BtnSend = document.getElementById("btnSend");

            //min = parseInt(secondsRemaining / 60);
            //sec = parseInt(secondsRemaining % 60);
            BtnSend.querySelector("span").innerText = secondsRemaining + "s"

            secondsRemaining = secondsRemaining - 1;
            if (secondsRemaining < 0) {
                clearInterval(countInterval);
                SetBtnSend();
            };

        }, 1000);
    }

    function IsEmail(email) {
        var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (!regex.test(email)) {
            return false;
        } else {
            return true;
        }
    }

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        lang = window.parent.API_GetLang();
        WebInfo = window.parent.API_GetWebInfo();
        p = window.parent.API_GetLobbyAPI();
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();
        });
    }

    function showPassword(input) {
        var x = document.getElementById(input);
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

    function EWinEventNotify(eventName, isDisplay, param) {
        switch (eventName) {
            case "LoginState":
                //updateBaseInfo();

                break;
            case "BalanceChange":
                break;
            case "SetLanguage":
                lang = param;
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

        <div class="btn-back is-hide" data-click-btn="backToSign">
            <div></div>
        </div>

        <!-- 側邊影像 -->
        <div class="feature-panel"></div>

        <!-- 主內容框 -->
        <div class="main-panel">


            <!-- 重設密碼 -->
            <div id="restPassword" class="form-container" data-form-group="restPassword">
                <div class="heading-title">
                    <h3 class="language_replace">重設密碼</h3>
                </div>

                <div class="heading-sub-desc text-wrap">
                    <h6 class="language_replace">忘記密碼？</h6>
                    <p class="language_replace">請輸入電話，會將驗證碼發送至您的電話。</p>
                </div>

                <div class="form-content">
                    <div id="idPhoneLoginGroup" class="form-row">
                        <div class="form-group col-3">
                            <label class="form-title language_replace">國碼</label>
                            <div class="input-group">
                                <input name="PhonePrefix" id="idPhonePrefix" type="text" class="form-control custom-style" placeholder="+82" inputmode="decimal" value="+82">
                                <div class="invalid-feedback language_replace">請輸入國碼</div>
                            </div>
                        </div>
                        <div class="form-group col-9">
                            <label class="form-title language_replace">手機電話號碼</label>
                            <div class="input-group">
                                <input name="PhoneNumber" id="idPhoneNumber" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="000-0000-0000 (最前面的00請勿輸入)" inputmode="decimal">
                                <div class="invalid-feedback language_replace">請輸入正確電話</div>
                            </div>
                        </div>
                        <div class="form-group btn-container ">
                            <button type="button" class="btn btn-primary" id="btnSend" onclick="SendPhone()"><span class="language_replace">取得驗證碼</span></button>
                        </div>
                    </div>



                </div>
                <div class="form-content">
                    <div class="form-group">
                        <label class="form-title language_replace">驗證碼</label>
                        <div class="input-group">
                            <input id="idValidCode" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入驗證碼" inputmode="email">
                            <div class="invalid-feedback language_replace">提示</div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-title language_replace">新密碼</label>
                        <div class="input-group">
                            <input id="idNewPassword" type="password" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入新密碼" inputmode="email">
                            <div class="invalid-feedback language_replace">提示</div>
                        </div>
                        <button type="button" class="btn btn-icon" type="button" onclick="showPassword('idNewPassword')">
                            <i class="icon-eye-off"></i>
                        </button>
                    </div>

                    <div class="btn-container">
                        <button type="button" class="btn btn-primary"  onclick="formSubmitCheck()"><span class="language_replace">重設密碼</span></button>
                    </div>
                </div>
            </div>

            <!-- 重設密碼 發送完成 -->
            <div id="mailSend" class="form-container is-hide">
                <div class="heading-title text-center">
                    <h3 class="language_replace">發送完成！</h3>
                </div>

                <div class="heading-sub-desc text-wrap text-center mb-5">
                    <p class="language_replace">已將重設密碼的信送至您輸入的電話，請至該電話確認。</p>
                </div>

                <div class="btn-container">
                    <a class="btn btn-primary" data-click-btn="signIn" onclick="BackLogin()"><span class="language_replace">重新登入</span></a>
                </div>
            </div>

        </div>
    </div>

</body>
</html>
