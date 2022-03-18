<%@ Page Language="C#" %>

<%
    string PCode = Request["PCode"];
    string Version = EWinWeb.Version;
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BET 파라다이스</title>

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
    var pCode = "<%=PCode%>";
    var WebInfo;
    var p;
    var mlp;
    var lang;
    var PhoneNumberUtil = libphonenumber.PhoneNumberUtil.getInstance();
    var v ="<%:Version%>";
    var isSent = false;

    function BackHome() {
        window.parent.API_Home();
    }

    function startCountDown(duration) {
        isSent = true;
        let secondsRemaining = duration;
        let min = 0;
        let sec = 0;

        let countInterval = setInterval(function () {
            let BtnSend = document.getElementById("divSendValidateCodeBtn");
            $('#divSendValidateCodeBtn>button').attr('disabled', 'disabled');
            //min = parseInt(secondsRemaining / 60);
            //sec = parseInt(secondsRemaining % 60);
            BtnSend.querySelector("span").innerText = secondsRemaining + "s"

            secondsRemaining = secondsRemaining - 1;
            if (secondsRemaining < 0) {
                $('#divSendValidateCodeBtn>button').removeAttr('disabled');
                clearInterval(countInterval);
                SetBtnSend();
            };

        }, 1000);
    }


    function CheckAccountPhoneExist(cb) {

        var idPhonePrefix = document.getElementById("idPhonePrefix");
        var idPhoneNumber = document.getElementById("idPhoneNumber");

        if (idPhonePrefix.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入國碼"));
            cb(false);
            return;
        }
        //else if (idPhonePrefix.value != "+81") {
        //    window.parent.showMessageOK("", mlp.getLanguageKey("國碼只能為+81"));
        //    cb(false);
        //    return;
        //}
        else if (idPhoneNumber.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入電話"));
            cb(false);
            return;
        } else {
            var phoneValue = idPhonePrefix.value + idPhoneNumber.value;
            var phoneObj;

            try {
                phoneObj = PhoneNumberUtil.parse(phoneValue);

                var type = PhoneNumberUtil.getNumberType(phoneObj);

                if (type != libphonenumber.PhoneNumberType.MOBILE && type != libphonenumber.PhoneNumberType.FIXED_LINE_OR_MOBILE) {
                    window.parent.showMessageOK("", mlp.getLanguageKey("電話格式有誤"));
                    cb(false);
                    return;
                }
            } catch (e) {

                window.parent.showMessageOK("", mlp.getLanguageKey("電話格式有誤"));

                cb(false);
                return;
            }
        }

        cb(true);
    }

    function CheckUserAccountExist(cb) {
        var idLoginAccount = document.getElementById("idLoginAccount");

        if (idLoginAccount.value.trim() == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入帳號"));
            cb(false);
            return;
        } else if (idLoginAccount.value.trim().length < 4) {
            window.parent.showMessageOK("", mlp.getLanguageKey("帳號長度最小為 4"));
            cb(false);
            return;
        }
        else if (idLoginAccount.value.trim().length > 12) {
            window.parent.showMessageOK("", mlp.getLanguageKey("帳號長度最大為 12 "));
            cb(false);
            return;
        }
        else if (idLoginPassword.value.trim() == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入密碼"));
            cb(false);
            return;
        }


        cb(true);
    }

    function CheckPassword() {
        var idLoginPassword = document.getElementById("idLoginPassword");
        //var rules = new RegExp('^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,12}$')
        if (idLoginPassword.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入登入密碼"));
            return false;
        }
        //else if (idLoginPassword.value.length < 6) {
        //    window.parent.showMessageOK("", mlp.getLanguageKey("請輸入登入密碼"));
        //    return false;
        //} else if (!rules.test(idLoginPassword.value)) {
        //    window.parent.showMessageOK("", mlp.getLanguageKey("請輸入半形的英文大小寫/數字，至少要有一個英文大寫與英文小寫與數字"));
        //    return false;
        //}

        return true;
    }

    function onBtnSendValidateCode() {

        CheckUserAccountExist(function (isCheck) {
            if (isCheck) {
                p.CheckAccountExist(Math.uuid(), idLoginAccount.value.trim(), function (success, o) {
                    if (success) {
                        if (o.Result != 0) {
                            if (isSent == false) {
                                var form = document.getElementById("registerStep1");
                                CheckAccountPhoneExist(function (check) {
                                    if (check) {
                                        p.CheckAccountExistByContactPhoneNumber(Math.uuid(), idPhonePrefix.value, idPhoneNumber.value, function (success, o) {
                                            if (success) {
                                                if (o.Result != 0) {
                                                    p.SetUserMail(Math.uuid(), 1, 0, $("#idLoginAccount").val().trim(), $("#idPhonePrefix").val().trim(), $("#idPhoneNumber").val().trim(), mlp.getLanguageKey("您的驗證碼為 ({0})\r\n請您於2分鐘內驗證，如超過時間，請重新發送驗證碼。"), function (success, o) {
                                                        if (success) {
                                                            if (o.Result != 0) {
                                                                window.parent.showMessageOK("", mlp.getLanguageKey("發送驗證碼失敗"));
                                                            } else {
                                                                window.parent.showMessageOK("", mlp.getLanguageKey("發送驗證碼成功"));

                                                                startCountDown(120);
                                                                //$("#divSendValidateCodeBtn").hide();
                                                                $("#divStep1Btn").show();
                                                            }
                                                        }
                                                    });
                                                } else {
                                                    window.parent.showMessageOK("", mlp.getLanguageKey("電話已存在"));
                                                    return;
                                                }
                                            }
                                        });
                                    } else {
                                        //window.parent.showMessageOK("", mlp.getLanguageKey("請輸入正確電話"));
                                    }
                                });
                            } else {
                                window.parent.showMessageOK("", mlp.getLanguageKey("已發送驗證碼，短時間內請勿重複發送"));
                            }
                        } else {
                            window.parent.showMessageOK("", mlp.getLanguageKey("帳號已存在"));
                            return;
                        }
                    }
                });
            }
        });
    }

    function SetBtnSend() {
        let BtnSend = document.getElementById("divSendValidateCodeBtn");
        BtnSend.querySelector("span").innerText = mlp.getLanguageKey("傳送驗證碼");
        isSent = false;
    }

    function onBtnUserRegisterStep1() {
        if (isSent) {
            var form = document.getElementById("registerStep1");

            if ($("#idValidateCode").val() == "") {
                window.parent.showMessageOK("", mlp.getLanguageKey("請輸入驗證碼"));
            } else {
                if (!CheckPassword()) {
                    return;
                }

                CheckUserAccountExist(function (isCheck) {
                    if (isCheck) {
                        p.CheckAccountExist(Math.uuid(), idLoginAccount.value.trim(), function (success, o) {
                            if (success) {
                                if (o.Result != 0) {
                                    CheckAccountPhoneExist(function (isCheck2) {
                                        if (isCheck2) {
                                            p.CheckAccountExistByContactPhoneNumber(Math.uuid(), idPhonePrefix.value, idPhoneNumber.value, function (success, o) {
                                                if (success) {
                                                    if (o.Result != 0) {
                                                        var PhonePrefix = $("#idPhonePrefix").val();
                                                        if (PhonePrefix.substring(0, 1) == "+") {
                                                            PhonePrefix = PhonePrefix.substring(1, PhonePrefix.length);
                                                        }
                                                        p.CheckValidateCode(Math.uuid(), 1, $("#idLoginAccount").val(), PhonePrefix, $("#idPhoneNumber").val(), $("#idValidateCode").val(), function (success, o) {
                                                            if (success) {
                                                                if (o.Result != 0) {
                                                                    window.parent.showMessageOK("", mlp.getLanguageKey("請輸入正確驗證碼"));
                                                                    return;
                                                                } else {
                                                                    document.getElementById("contentStep1").classList.add("is-hide");
                                                                    document.getElementById("contentStep2").classList.remove("is-hide");

                                                                    document.getElementById("progressStep1").classList.remove("cur");
                                                                    document.getElementById("progressStep2").classList.add("cur");
                                                                }
                                                            } else {
                                                                window.parent.showMessageOK("", mlp.getLanguageKey("驗證碼錯誤"));
                                                            }
                                                        });
                                                    } else {
                                                        window.parent.showMessageOK("", mlp.getLanguageKey("電話已存在"));
                                                        return;
                                                    }
                                                }
                                            });
                                        }
                                    });
                                } else {
                                    window.parent.showMessageOK("", mlp.getLanguageKey("帳號已存在"));
                                    return;
                                }
                            }
                        });
                    } else {
                        return;
                    }

                })




            }
        } else {
            window.parent.showMessageOK("", mlp.getLanguageKey("請先取得驗證碼"));
        }
    }

    function onBtnUserRegisterStep2() {
        //var re = /^[\s-_a-zA-Z0-9]+$/i;
        var form2 = document.getElementById("registerStep2");
        //var idNickName = document.getElementById("idNickName");
        var CurrencyList = WebInfo.RegisterCurrencyType;

        initValid(form2);

        // if (form2.PostalCode.value == "") {
        //    form2.PostalCode.setCustomValidity(mlp.getLanguageKey("請輸入郵遞區號"));
        //} else if (form2.PostalCode.value.indexOf(',') != -1) {
        //    form2.PostalCode.setCustomValidity(mlp.getLanguageKey("不可輸入 , "));
        //} else if (form2.Prefectures.value == "") {
        //    form2.Prefectures.setCustomValidity(mlp.getLanguageKey("請輸入都到縣府"));
        //} else if (form2.Prefectures.value.indexOf(',') != -1) {
        //    form2.Prefectures.setCustomValidity(mlp.getLanguageKey("不可輸入 , "));
        //} else if (form2.Address.value == "") {
        //    form2.Address.setCustomValidity(mlp.getLanguageKey("請輸入地址"));
        //} else if (form2.Address.value.indexOf(',') != -1) {
        //    form2.Address.setCustomValidity(mlp.getLanguageKey("不可輸入 , "));
        //}  
        if (form2.Name1.value == "") {
            form2.Name1.setCustomValidity(mlp.getLanguageKey("請輸入姓"));
        } else if (form2.Name2.value == "") {
            form2.Name2.setCustomValidity(mlp.getLanguageKey("請輸入名"));
        } else if (form2.NickName.value == "") {
            form2.NickName.setCustomValidity(mlp.getLanguageKey("請輸入暱稱"));
        } else if (form2.eighteenCheck.checked == false) {
            form2.eighteenCheck.setCustomValidity(mlp.getLanguageKey("請確認已年滿18歲"));
        }

        form2.reportValidity();

        if (form2.checkValidity()) {
            var LoginAccount;
            var LoginPassword = document.getElementById("idLoginPassword").value;
            var ParentPersonCode = form2.PersonCode.value;
            var PhonePrefix = document.getElementById("idPhonePrefix").value
            var PhoneNumber = document.getElementById("idPhoneNumber").value

            if (typeof (ParentPersonCode) == "string") {
                ParentPersonCode = ParentPersonCode.trim();
            }

            if (PhonePrefix.substring(0, 1) == "+") {
                PhonePrefix = PhonePrefix.substring(1, PhonePrefix.length);
            }

            var PS = [
                { Name: "RealName", Value: form2.NickName.value },
                { Name: "KYCRealName", Value: form2.Name1.value + form2.Name2.value },
                { Name: "ContactPhonePrefix", Value: PhonePrefix },
                { Name: "ContactPhoneNumber", Value: PhoneNumber },
          /*      { Name: "EMail", Value: document.getElementById("idLoginAccount").value },*/
                //{ Name: "ContactAddress", Value: form2.PostalCode.value + "," + form2.Prefectures.value + "," + form2.Address.value },
                { Name: "CountryName", Value: form2.Country.options[form2.Country.selectedIndex].text },
                { Name: "Country", Value: form2.Country.options[form2.Country.selectedIndex].value },
                { Name: "Birthday", Value: form2.BornYear.value + "/" + form2.BornMonth.options[form2.BornMonth.selectedIndex].value + "/" + form2.BornDate.options[form2.BornDate.selectedIndex].value },
            ];

            LoginAccount = $("#idLoginAccount").val();
            p.CreateAccount(Math.uuid(), LoginAccount, LoginPassword, ParentPersonCode, CurrencyList, PS, function (success, o) {
                if (success) {
                    if (o.Result == 0) {
   
                        window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("註冊成功, 請按登入按鈕進行登入"), function () {
                            document.getElementById("idRegister").classList.add("is-hide");
                            document.getElementById("contentFinish").classList.remove("is-hide");
                        });
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o.Message), function () {
                            window.parent.API_LoadPage("Register", "Register.aspx")
                        });
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey("網路異常, 請重新嘗試"), function () {
                            window.parent.API_LoadPage("Register", "Register.aspx")
                        });
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("失敗"), mlp.getLanguageKey(o), function () {
                            window.parent.API_LoadPage("Register", "Register.aspx")
                        });
                    }
                }
            });
        }
    }

    function updateBaseInfo() {

    }

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        WebInfo = window.parent.API_GetWebInfo();
        p = window.parent.API_GetLobbyAPI();
        lang = window.parent.API_GetLang();

        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();
        });

        AdjustDate();
    }

    function initValid(form) {
        if (form.tagName.toUpperCase() == "FORM") {
            var formInputs = form.getElementsByTagName("input");
            for (var i = 0; i < formInputs.length; i++) {
                formInputs[i].setCustomValidity('');
            }
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

    function AdjustDate() {
        var idBornYear = document.getElementById("idBornYear");
        var idBornMonth = document.getElementById("idBornMonth");
        var idBornDate = document.getElementById("idBornDate");
        idBornDate.options.length = 0;

        var year = idBornYear.value;
        var month = parseInt(idBornMonth.value);

        //get the last day, so the number of days in that month
        var days = new Date(year, month, 0).getDate();

        //lets create the days of that month
        for (var d = 1; d <= days; d++) {
            var dayElem = document.createElement("option");
            dayElem.value = d;
            dayElem.textContent = d;

            if (d == 1) {
                dayElem.selected = true;
            }

            idBornDate.append(dayElem);
        }
    }

    function EWinEventNotify(eventName, isDisplay, param) {
        switch (eventName) {
            case "LoginState":

                break;
            case "BalanceChange":
                break;

            case "SetLanguage":
                var lang = param;

                mlp.loadLanguage(lang);
                break;
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


    //function IsEmail(email) {
    //    var regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[^]{8,20}$/;
    //    if (!regex.test(email)) {
    //        return false;
    //    } else {
    //        return true;
    //    }
    //}

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

            <!-- 註冊 -->
            <div id="idRegister" class="form-container">
                <div class="heading-title">
                    <h3 class="language_replace">創建新帳號</h3>
                </div>

                <!-- 步驟 -->
                <div class="progress-container mb-4 pb-2">
                    <div id="progressStep1" class="progress-step cur">
                        <div class="progress-step-item"></div>
                    </div>
                    <div id="progressStep2" class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                </div>

                <!-- 註冊 step1 -->
                <div id="contentStep1" class="form-content" data-form-group="registerStep1">
                    <form id="registerStep1">
                        <div class="form-group">
                            <label class="form-title language_replace">帳號</label>
                            <div class="input-group">
                                <input id="idLoginAccount" name="LoginAccount" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="英文或數字12位以內，不分大小寫" inputmode="email">
                                <div class="invalid-feedback language_replace">請輸入正確帳號</div>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group col phonePrefix">
                                <label class="form-title language_replace">國碼</label>
                                <div class="input-group">
                                    <input id="idPhonePrefix" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="+82" inputmode="decimal" value="+82" onchange="onChangePhonePrefix()">
                                    <div class="invalid-feedback language_replace">請輸入國碼</div>
                                </div>
                            </div>
                            <div class="form-group col">
                                <label class="form-title language_replace">手機電話號碼</label>
                                <div class="input-group">
                                    <input id="idPhoneNumber" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="000-0000-0000 (最前面的0請勿輸入)" inputmode="decimal">
                                    <div class="invalid-feedback language_replace">請輸入正確電話</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-title language_replace">密碼</label>
                            <div class="input-group">
                                <input id="idLoginPassword" name="LoginPassword" type="password" class="form-control custom-style" language_replace="placeholder" placeholder="字母和數字的組合在20個字符以內" inputmode="email">
                                <div class="invalid-feedback language_replace">請輸入密碼</div>
                            </div>
                            <button class="btn btn-icon" type="button" onclick="showPassword('idLoginPassword')">
                                <i class="icon-eye-off"></i>
                            </button>
                        </div>
                        <div class="form-group">
                            <label class="form-title language_replace">驗證碼</label>
                            <div class="input-group">
                                <input id="idValidateCode" name="ValidateCode" type="text" class="form-control custom-style">
                            </div>
                        </div>

                        <div class="btn-container" id="divSendValidateCodeBtn">
                            <button type="button" class="btn btn-primary" onclick="onBtnSendValidateCode()">
                                <span class="language_replace">傳送驗證碼</span>
                            </button>
                        </div>
                        <div id="divStep1Btn" style="display: none">
                            <div class="btn-container">
                                <button type="button" class="btn btn-primary" onclick="onBtnUserRegisterStep1()">
                                    <span class="language_replace">下一步</span>
                                </button>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="form-check">
                                <label class="form-check-label language_replace">電話號碼將用於發送確認碼，請輸入可以接收短信的電話號碼。</label></br>
                               
                                <label class="form-check-label language_replace">1.請先輸入電話號碼。</label></br>

                                <label class="form-check-label language_replace">2.從註冊會員的畫面點擊發送驗證碼。</label></br>
                               
                                <label class="form-check-label language_replace">3.驗證碼將會發送到您指定的手機。</label></br>
                               
                                <label class="form-check-label language_replace">4.輸入驗證碼之後就可進行下一個步驟。</label></br>
                
                                <label class="form-check-label language_replace">5.您需要填寫您的姓名、暱稱、出生日期等。</label></br>
            
                                <!--label class="form-check-label language_replace">6.開戶後，您將通過一封簡短的電子郵件收到有關 Club Maharaja 的信息。</label></br-->
                           
                            </div>
                        </div>
                    </form>
                </div>

                <!-- 註冊 stepTwo -->
                <div id="contentStep2" class="form-content is-hide" data-form-group="registerStep2">
                    <form id="registerStep2">
                        <div class="form-row">
                            <div class="form-group col-md">
                                <label class="form-title">
                                    <span class="form-title-note language_replace">姓</span></label>
                                <div class="input-group">
                                    <input type="text" class="form-control custom-style" placeholder="" inputmode="email" name="Name1">
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
                            </div>
                            <div class="form-group col-md">
                                <label class="form-title">
                                    <span class="form-title-note language_replace">名</span></label>
                                <div class="input-group">
                                    <input type="text" class="form-control custom-style" placeholder="" inputmode="email" name="Name2">
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-title language_replace">暱稱</label>
                            <div class="input-group">
                                <input type="text" class="form-control custom-style" language_replace="placeholder" placeholder="暱稱請輸入英文與數字，長度12位元以內" inputmode="" name="NickName">
                                <div class="invalid-feedback language_replace">提示</div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-title language_replace">國家</label>
                            <div class="input-group">
                                <select class="form-control custom-style" name="Country">
                                    <option value="AF">Afghanistan</option>
                                    <option value="AX">Åland Islands</option>
                                    <option value="AL">Albania</option>
                                    <option value="DZ">Algeria</option>
                                    <option value="AS">American Samoa</option>
                                    <option value="AD">Andorra</option>
                                    <option value="AO">Angola</option>
                                    <option value="AI">Anguilla</option>
                                    <option value="AQ">Antarctica</option>
                                    <option value="AG">Antigua and Barbuda</option>
                                    <option value="AR">Argentina</option>
                                    <option value="AM">Armenia</option>
                                    <option value="AW">Aruba</option>
                                    <option value="AU">Australia</option>
                                    <option value="AT">Austria</option>
                                    <option value="AZ">Azerbaijan</option>
                                    <option value="BS">Bahamas (the)</option>
                                    <option value="BH">Bahrain</option>
                                    <option value="BD">Bangladesh</option>
                                    <option value="BB">Barbados</option>
                                    <option value="BY">Belarus</option>
                                    <option value="BE">Belgium</option>
                                    <option value="BZ">Belize</option>
                                    <option value="BJ">Benin</option>
                                    <option value="BM">Bermuda</option>
                                    <option value="BT">Bhutan</option>
                                    <option value="BO">Bolivia (Plurinational State of)</option>
                                    <option value="BQ">Bonaire, Sint Eustatius and Saba</option>
                                    <option value="BA">Bosnia and Herzegovina</option>
                                    <option value="BW">Botswana</option>
                                    <option value="BV">Bouvet Island</option>
                                    <option value="BR">Brazil</option>
                                    <option value="IO">British Indian Ocean Territory (the)</option>
                                    <option value="BN">Brunei Darussalam</option>
                                    <option value="BG">Bulgaria</option>
                                    <option value="BF">Burkina Faso</option>
                                    <option value="BI">Burundi</option>
                                    <option value="CV">Cabo Verde</option>
                                    <option value="KH">Cambodia</option>
                                    <option value="CM">Cameroon</option>
                                    <option value="CA">Canada</option>
                                    <option value="KY">Cayman Islands (the)</option>
                                    <option value="CF">Central African Republic (the)</option>
                                    <option value="TD">Chad</option>
                                    <option value="CL">Chile</option>
                                    <option value="CN">China</option>
                                    <option value="CX">Christmas Island</option>
                                    <option value="CC">Cocos (Keeling) Islands (the)</option>
                                    <option value="CO">Colombia</option>
                                    <option value="KM">Comoros (the)</option>
                                    <option value="CD">Congo (the Democratic Republic of the)</option>
                                    <option value="CG">Congo (the)</option>
                                    <option value="CK">Cook Islands (the)</option>
                                    <option value="CR">Costa Rica</option>
                                    <option value="HR">Croatia</option>
                                    <option value="CU">Cuba</option>
                                    <option value="CW">Curaçao</option>
                                    <option value="CY">Cyprus</option>
                                    <option value="CZ">Czechia</option>
                                    <option value="CI">Côte d'Ivoire</option>
                                    <option value="DK">Denmark</option>
                                    <option value="DJ">Djibouti</option>
                                    <option value="DM">Dominica</option>
                                    <option value="DO">Dominican Republic (the)</option>
                                    <option value="EC">Ecuador</option>
                                    <option value="EG">Egypt</option>
                                    <option value="SV">El Salvador</option>
                                    <option value="GQ">Equatorial Guinea</option>
                                    <option value="ER">Eritrea</option>
                                    <option value="EE">Estonia</option>
                                    <option value="SZ">Eswatini</option>
                                    <option value="ET">Ethiopia</option>
                                    <option value="FK">Falkland Islands (the) [Malvinas]</option>
                                    <option value="FO">Faroe Islands (the)</option>
                                    <option value="FJ">Fiji</option>
                                    <option value="FI">Finland</option>
                                    <option value="FR">France</option>
                                    <option value="GF">French Guiana</option>
                                    <option value="PF">French Polynesia</option>
                                    <option value="TF">French Southern Territories (the)</option>
                                    <option value="GA">Gabon</option>
                                    <option value="GM">Gambia (the)</option>
                                    <option value="GE">Georgia</option>
                                    <option value="DE">Germany</option>
                                    <option value="GH">Ghana</option>
                                    <option value="GI">Gibraltar</option>
                                    <option value="GR">Greece</option>
                                    <option value="GL">Greenland</option>
                                    <option value="GD">Grenada</option>
                                    <option value="GP">Guadeloupe</option>
                                    <option value="GU">Guam</option>
                                    <option value="GT">Guatemala</option>
                                    <option value="GG">Guernsey</option>
                                    <option value="GN">Guinea</option>
                                    <option value="GW">Guinea-Bissau</option>
                                    <option value="GY">Guyana</option>
                                    <option value="HT">Haiti</option>
                                    <option value="HM">Heard Island and McDonald Islands</option>
                                    <option value="VA">Holy See (the)</option>
                                    <option value="HN">Honduras</option>
                                    <option value="HK">Hong Kong</option>
                                    <option value="HU">Hungary</option>
                                    <option value="IS">Iceland</option>
                                    <option value="IN">India</option>
                                    <option value="ID">Indonesia</option>
                                    <option value="IR">Iran (Islamic Republic of)</option>
                                    <option value="IQ">Iraq</option>
                                    <option value="IE">Ireland</option>
                                    <option value="IM">Isle of Man</option>
                                    <option value="IL">Israel</option>
                                    <option value="IT">Italy</option>
                                    <option value="JM">Jamaica</option>
                                    <option value="JP">Japan</option>
                                    <option value="JE">Jersey</option>
                                    <option value="JO">Jordan</option>
                                    <option value="KZ">Kazakhstan</option>
                                    <option value="KE">Kenya</option>
                                    <option value="KI">Kiribati</option>
                                    <option value="KP">Korea (the Democratic People's Republic of)</option>
                                    <option value="KR" selected>Korea (the Republic of)</option>
                                    <option value="KW">Kuwait</option>
                                    <option value="KG">Kyrgyzstan</option>
                                    <option value="LA">Lao People's Democratic Republic (the)</option>
                                    <option value="LV">Latvia</option>
                                    <option value="LB">Lebanon</option>
                                    <option value="LS">Lesotho</option>
                                    <option value="LR">Liberia</option>
                                    <option value="LY">Libya</option>
                                    <option value="LI">Liechtenstein</option>
                                    <option value="LT">Lithuania</option>
                                    <option value="LU">Luxembourg</option>
                                    <option value="MO">Macao</option>
                                    <option value="MG">Madagascar</option>
                                    <option value="MW">Malawi</option>
                                    <option value="MY">Malaysia</option>
                                    <option value="MV">Maldives</option>
                                    <option value="ML">Mali</option>
                                    <option value="MT">Malta</option>
                                    <option value="MH">Marshall Islands (the)</option>
                                    <option value="MQ">Martinique</option>
                                    <option value="MR">Mauritania</option>
                                    <option value="MU">Mauritius</option>
                                    <option value="YT">Mayotte</option>
                                    <option value="MX">Mexico</option>
                                    <option value="FM">Micronesia (Federated States of)</option>
                                    <option value="MD">Moldova (the Republic of)</option>
                                    <option value="MC">Monaco</option>
                                    <option value="MN">Mongolia</option>
                                    <option value="ME">Montenegro</option>
                                    <option value="MS">Montserrat</option>
                                    <option value="MA">Morocco</option>
                                    <option value="MZ">Mozambique</option>
                                    <option value="MM">Myanmar</option>
                                    <option value="NA">Namibia</option>
                                    <option value="NR">Nauru</option>
                                    <option value="NP">Nepal</option>
                                    <option value="NL">Netherlands (the)</option>
                                    <option value="NC">New Caledonia</option>
                                    <option value="NZ">New Zealand</option>
                                    <option value="NI">Nicaragua</option>
                                    <option value="NE">Niger (the)</option>
                                    <option value="NG">Nigeria</option>
                                    <option value="NU">Niue</option>
                                    <option value="NF">Norfolk Island</option>
                                    <option value="MP">Northern Mariana Islands (the)</option>
                                    <option value="NO">Norway</option>
                                    <option value="OM">Oman</option>
                                    <option value="PK">Pakistan</option>
                                    <option value="PW">Palau</option>
                                    <option value="PS">Palestine, State of</option>
                                    <option value="PA">Panama</option>
                                    <option value="PG">Papua New Guinea</option>
                                    <option value="PY">Paraguay</option>
                                    <option value="PE">Peru</option>
                                    <option value="PH">Philippines (the)</option>
                                    <option value="PN">Pitcairn</option>
                                    <option value="PL">Poland</option>
                                    <option value="PT">Portugal</option>
                                    <option value="PR">Puerto Rico</option>
                                    <option value="QA">Qatar</option>
                                    <option value="MK">Republic of North Macedonia</option>
                                    <option value="RO">Romania</option>
                                    <option value="RU">Russian Federation (the)</option>
                                    <option value="RW">Rwanda</option>
                                    <option value="RE">Réunion</option>
                                    <option value="BL">Saint Barthélemy</option>
                                    <option value="SH">Saint Helena, Ascension and Tristan da Cunha</option>
                                    <option value="KN">Saint Kitts and Nevis</option>
                                    <option value="LC">Saint Lucia</option>
                                    <option value="MF">Saint Martin (French part)</option>
                                    <option value="PM">Saint Pierre and Miquelon</option>
                                    <option value="VC">Saint Vincent and the Grenadines</option>
                                    <option value="WS">Samoa</option>
                                    <option value="SM">San Marino</option>
                                    <option value="ST">Sao Tome and Principe</option>
                                    <option value="SA">Saudi Arabia</option>
                                    <option value="SN">Senegal</option>
                                    <option value="RS">Serbia</option>
                                    <option value="SC">Seychelles</option>
                                    <option value="SL">Sierra Leone</option>
                                    <option value="SG">Singapore</option>
                                    <option value="SX">Sint Maarten (Dutch part)</option>
                                    <option value="SK">Slovakia</option>
                                    <option value="SI">Slovenia</option>
                                    <option value="SB">Solomon Islands</option>
                                    <option value="SO">Somalia</option>
                                    <option value="ZA">South Africa</option>
                                    <option value="GS">South Georgia and the South Sandwich Islands</option>
                                    <option value="SS">South Sudan</option>
                                    <option value="ES">Spain</option>
                                    <option value="LK">Sri Lanka</option>
                                    <option value="SD">Sudan (the)</option>
                                    <option value="SR">Suriname</option>
                                    <option value="SJ">Svalbard and Jan Mayen</option>
                                    <option value="SE">Sweden</option>
                                    <option value="CH">Switzerland</option>
                                    <option value="SY">Syrian Arab Republic</option>
                                    <option value="TW">Taiwan (Province of China)</option>
                                    <option value="TJ">Tajikistan</option>
                                    <option value="TZ">Tanzania, United Republic of</option>
                                    <option value="TH">Thailand</option>
                                    <option value="TL">Timor-Leste</option>
                                    <option value="TG">Togo</option>
                                    <option value="TK">Tokelau</option>
                                    <option value="TO">Tonga</option>
                                    <option value="TT">Trinidad and Tobago</option>
                                    <option value="TN">Tunisia</option>
                                    <option value="TR">Turkey</option>
                                    <option value="TM">Turkmenistan</option>
                                    <option value="TC">Turks and Caicos Islands (the)</option>
                                    <option value="TV">Tuvalu</option>
                                    <option value="UG">Uganda</option>
                                    <option value="UA">Ukraine</option>
                                    <option value="AE">United Arab Emirates (the)</option>
                                    <option value="GB">United Kingdom of Great Britain and Northern Ireland (the)</option>
                                    <option value="UM">United States Minor Outlying Islands (the)</option>
                                    <option value="US">United States of America (the)</option>
                                    <option value="UY">Uruguay</option>
                                    <option value="UZ">Uzbekistan</option>
                                    <option value="VU">Vanuatu</option>
                                    <option value="VE">Venezuela (Bolivarian Republic of)</option>
                                    <option value="VN">Viet Nam</option>
                                    <option value="VG">Virgin Islands (British)</option>
                                    <option value="VI">Virgin Islands (U.S.)</option>
                                    <option value="WF">Wallis and Futuna</option>
                                    <option value="EH">Western Sahara</option>
                                    <option value="YE">Yemen</option>
                                    <option value="ZM">Zambia</option>
                                    <option value="ZW">Zimbabwe</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-row" style="display: none">
                            <div class="form-group col">
                                <label class="form-title language_replace">郵遞區號</label>
                                <div class="input-group">
                                    <input type="text" class="form-control custom-style" placeholder="123-4567" inputmode="numeric" name="PostalCode">
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
                            </div>
                            <div class="form-group col">
                                <label class="form-title language_replace">都道縣府<%--<span class="form-title-note language_replace">(羅馬字)</span>--%></label>
                                <div class="input-group">
                                    <input type="text" class="form-control custom-style" placeholder="Tokyo" inputmode="" name="Prefectures">
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
                            </div>
                        </div>

                        <div class="form-group" style="display: none">
                            <label class="form-title language_replace">市區町村以下的地址<%--<span class="form-title-note language_replace">(羅馬字)</span>--%></label>
                            <div class="input-group">
                                <input type="text" class="form-control custom-style" placeholder="shinjiku-ku 1-2-3" inputmode="" name="Address">
                                <div class="invalid-feedback language_replace">提示</div>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col">
                                <label class="form-title language_replace">出生年</label>
                                <div class="input-group">
                                    <input id="idBornYear" type="text" class="form-control custom-style" placeholder="1900" inputmode="numeric" name="BornYear" onchange="AdjustDate()" value="1990">
                                </div>
                            </div>
                            <div class="form-group col">
                                <label class="form-title language_replace">月</label>
                                <div class="input-group">
                                    <select id="idBornMonth" class="form-control custom-style" name="BornMonth" onchange="AdjustDate()">
                                        <option value="1" selected>1</option>
                                        <option value="2">2</option>
                                        <option value="3">3</option>
                                        <option value="4">4</option>
                                        <option value="5">5</option>
                                        <option value="6">6</option>
                                        <option value="7">7</option>
                                        <option value="8">8</option>
                                        <option value="9">9</option>
                                        <option value="10">10</option>
                                        <option value="11">11</option>
                                        <option value="12">12</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group col">
                                <label class="form-title language_replace">日</label>
                                <div class="input-group">
                                    <select id="idBornDate" class="form-control custom-style" name="BornDate">
                                    </select>
                                </div>
                            </div>
                        </div>



                        <div class="form-group">
                            <label class="form-title language_replace">推廣碼</label>
                            <div class="input-group">
                                <input type="text" class="form-control custom-style" language_replace="placeholder" placeholder="若無推廣碼可不填寫" inputmode="" name="PersonCode">
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="CheckAge" name="eighteenCheck">
                                <label class="form-check-label language_replace" for="CheckAge">我已年滿20歲，且我已了解資料僅作為本網站會員所使用，不會在其他地方使用。</label>
                            </div>
                        </div>
                        <!--div class="form-group rules-privacy text-small">
                            <p class="language_replace">點選「開設帳號」就代表理解隱私權政策，也同意利用規約還有在マハラジャ不能持有複數的帳號這個條件。</p>
                        </div-->

                        <div class="btn-container">
                            <button type="button" class="btn btn-primary" onclick="onBtnUserRegisterStep2()">
                                <span class="language_replace">註冊</span>
                            </button>
                        </div>
                    </form>
                </div>

                <div class="get-start-header">
                    <div class="language_replace">已有帳號了?</div>
                    <button type="button" class="btn btn-outline-primary btn-sm" onclick="window.parent.API_LoadPage('Login', 'Login.aspx')">
                        <span class="language_replace">前往登入</span>
                    </button>
                </div>

            </div>

            <!-- 註冊完成 -->
            <div id="contentFinish" class="form-container is-hide">
                <div class="heading-title">
                    <h1>Welcome</h1>
                </div>
                <div class="heading-sub-desc text-wrap">
                    <h5 class="mb-4 language_replace">歡迎來到 BET 파라다이스</h5>
                    <p class="language_replace">感謝您註冊我們的新會員，真正非常的感謝您 ！</p>
                    <p class="language_replace">您現在可以馬上進入遊戲裡盡情的遊玩我們為您準備的優質遊戲。</p>
                    <p class="language_replace">另外還準備了很多的特典在等待您!</p>
                    <p class="language_replace">如果有任何不清楚的地方，歡迎您利用客服與我們聯絡。</p>
                </div>

                <div class="btn-container pt-4 mb-4">
                    <button type="button" class="btn btn-primary" onclick="window.parent.API_LoadPage('Login','Login.aspx')"><span class="language_replace">立刻登入</span></button>
                </div>
                <div class="d-flex justify-content-center">
                    <a class="text-link underline" onclick="BackHome()">
                        <span class="language_replace">首頁</span>
                    </a>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
