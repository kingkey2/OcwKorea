<%@ Page Language="C#" %>
<% string Version=EWinWeb.Version; %>
   
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maharaja</title>

    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="Scripts/OutSrc/lib/swiper/css/swiper-bundle.min.css" type="text/css" />

    <link rel="stylesheet" href="css/icons.css?<%:Version%>" type="text/css" /> 
    <link rel="stylesheet" href="css/global.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/member.css" type="text/css" />

</head>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
<script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="Scripts/OutSrc/lib/swiper/js/swiper-bundle.min.js"></script>

<script type="text/javascript">
    if (self != top) {
        window.parent.API_LoadingStart();
    }

    var WebInfo;
    var p;
    var lang;
    var BackCardInfo = null;
    var v = "<%:Version%>";
    var swiper;

    function cancelWalletPassword() {
        var idWalletLoginPassword = document.getElementById("idWalletLoginPassword");
        var idWalletDivNew1s = document.getElementById("idWalletDivNew1").getElementsByTagName("input");
        var idWalletDivNew2s = document.getElementById("idWalletDivNew2").getElementsByTagName("input");

        idWalletLoginPassword.value = "";

        for (var i = 0; i < idWalletDivNew2s.length; i++) {
            idWalletDivNew2s[i].value = "";
        }

        for (var i = 0; i < idWalletDivNew1s.length; i++) {
            idWalletDivNew1s[i].value = "";
        }
        document.getElementById("idPincodeStep1").classList.remove('is-hide');
        document.getElementById("idPincodeStep2").classList.add('is-hide');


        //外包css
        document.getElementById("idWalletPasswordBoxItem").classList.remove('cur');
    }


    function setWalletPasswordStep1() {
        var idWalletDivNew1s = document.getElementById("idWalletDivNew1").getElementsByTagName("input");
        for (var i = 0; i < idWalletDivNew1s.length; i++) {
            if (idWalletDivNew1s[i].value == "" && idWalletDivNew1s[i].value.length != 1) {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入四位數錢包密碼"));
                return;
            }
        }

        document.getElementById("idPincodeStep1").classList.add('is-hide');
        document.getElementById("idPincodeStep2").classList.remove('is-hide');
    }

    function setWalletPasswordStep2() {
        var idWalletLoginPassword = document.getElementById("idWalletLoginPassword");
        var idWalletDivNew1s = document.getElementById("idWalletDivNew1").getElementsByTagName("input");
        var idWalletDivNew2s = document.getElementById("idWalletDivNew2").getElementsByTagName("input");
        var walletPassword1 = "";
        var walletPassword2 = "";

        for (var i = 0; i < idWalletDivNew1s.length; i++) {
            walletPassword1 += idWalletDivNew1s[i].value;
        }

        for (var i = 0; i < idWalletDivNew2s.length; i++) {
            if (idWalletDivNew2s[i].value == "" && idWalletDivNew2s[i].value.length != 1) {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入四位數錢包密碼"));

                document.getElementById('idWalletPasswordUnSet').style.display = "none";
                return;
            }

            walletPassword2 += idWalletDivNew2s[i].value;
        }



        if (walletPassword1 != walletPassword2) {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("前後密碼不一致"));

            document.getElementById("idPincodeStep1").classList.remove('is-hide');
            document.getElementById("idPincodeStep2").classList.add('is-hide');

            return;
        } else if (idWalletLoginPassword.value == "") {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入登入密碼"));
        }

        p.SetWalletPassword(WebInfo.SID, Math.uuid(), idWalletLoginPassword.value, walletPassword2, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    cancelWalletPassword();

                    window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("錢包新密碼已設定完成"), function () {
                        window.parent.EWinWebInfo.UserInfo.IsWalletPasswordSet = true;
                        updateBaseInfo();
                    });
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));
                }
            } else {
                if (o == "Timeout") {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請重新嘗試"));
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), o);
                }
            }
        });
    }


    function updateBaseInfo() {

        var RealName = document.getElementById("idRealName");
        var Birthday = document.getElementById("idBirthday");
        var PersonCode = document.getElementById("idPersonCode");
        var Amount = document.getElementById("idAmount");
        var Phone = document.getElementById("idPhone");
        var Email = document.getElementById("idEmail");
        var LoginAccount = document.getElementById("idLoginAccount");
        //暱稱
        var RealName = document.getElementById("idRealName");
        //姓名
        var KYCRealName = document.getElementById("idKYCRealName");
        KYCRealName.innerText=
        RealName.innerText = WebInfo.UserInfo.RealName;
        LoginAccount.innerText = WebInfo.UserInfo.LoginAccount;

        Phone.innerText = WebInfo.UserInfo.ContactPhonePrefix + " " + WebInfo.UserInfo.ContactPhoneNumber;
        Amount.innerText = new BigNumber(WebInfo.UserInfo.WalletList.find(x => x.CurrencyType == window.parent.API_GetCurrency()).PointValue).toFormat();

        if (WebInfo.UserInfo.ExtraData) {
            var ExtraData = JSON.parse(WebInfo.UserInfo.ExtraData);
            for (var i = 0; i < ExtraData.length; i++) {
                if (ExtraData[i].Name == "Birthday") {
                    var Birthdays = ExtraData[i].Value.split('/');
                    Birthday.innerText = Birthdays[0] + "/" + Birthdays[1];
                }
                if (ExtraData[i].Name == "KYCRealName") {
                    KYCRealName.innerText = ExtraData[i].Value;
                }
            }
        }
        
        var ContactAddress = WebInfo.UserInfo.ContactAddress;

       

        //if (ContactAddress) {
        //    var ContactAddresss = ContactAddress.split(',');
        //    for (var i = 0; i < ContactAddresss.length; i++) {
        //        if (i == 0) {
        //            PostalCode.innerText = ContactAddresss[i].substring(0, ContactAddresss[i].length - 4) + "****";
        //        }
        //        if (i == 1) {
        //            Prefectures.innerText = ContactAddresss[i];
        //        }
        //        if (i == 2) {
        //            Address.innerText = ContactAddresss[i].substring(0, ContactAddresss[i].length - 4) + "****";
        //        }
        //    }
        //}

        //if (WebInfo.UserInfo.UserAccountType == 1) {
            $("#idPersonCodeDiv").removeClass('is-hide');
            document.getElementById("idPersonCode").innerText = WebInfo.UserInfo.PersonCode;
            $('#QRCodeimg').attr("src", `/GetQRCode.aspx?QRCode=${"<%=EWinWeb.CasinoWorldUrl %>"}/registerForQrCode.aspx?P=${WebInfo.UserInfo.PersonCode}&Download=2`);
            $("#idCopyPersonCode").text(WebInfo.UserInfo.PersonCode);
            $(".activity-container").removeClass('is-hide');
        //}
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

            if (p != null)
                updateBaseInfo();
            else
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路錯誤"), function () {
                    window.parent.location.href = "index.aspx";
                });

            if (WebInfo.UserInfo.UserLevel == 0) {
                $("#divTransfer").show();
            }

        });

        memberInit();
        changeAvatar(getCookie("selectAvatar"));

        $("#activityURL").attr("href", "https://casino-maharaja.net/lp/01/" + WebInfo.UserInfo.PersonCode);

        if (!WebInfo.UserInfo.IsWalletPasswordSet) {
            //document.getElementById('idWalletPasswordUnSet').style.display = "block";
        }
    }

    function showAvatar() {
        document.getElementById("idAvatarPopup").classList.remove('is-hide');
        document.getElementById("idAvatarPopup").classList.add('is-show');
        document.body.classList.add('body-lock');
        var avatars = document.getElementsByName("avatar");
        var selectAvatar = getCookie("selectAvatar");

        //var selectAvatar = "avatar-01";
        for (var i = 0; i < avatars.length; i++) {
            if (avatars[i].dataset.avatar_value.toLowerCase() == selectAvatar.toLowerCase()) {
                avatars[i].checked = true;
                break;
            }
        }

        swiper.update()
    }

    function closeAvatar() {
        document.getElementById("idAvatarPopup").classList.remove('is-show');
        document.getElementById("idAvatarPopup").classList.add('is-hide');
        document.body.classList.remove('body-lock');
    }

    function saveAvatar() {
        document.getElementById("idAvatarPopup").classList.remove('is-show');
        document.getElementById("idAvatarPopup").classList.add('is-hide');
        document.body.classList.remove('body-lock');
        var avatars = document.getElementsByName("avatar");
        var selectAvatar;

        for (var i = 0; i < avatars.length; i++) {
            if (avatars[i].checked) {
                selectAvatar = avatars[i].dataset.avatar_value;
                break;
            }
        }

        setCookie("selectAvatar", selectAvatar, 100000);
        window.parent.API_changeAvatarImg(selectAvatar);
        changeAvatar(selectAvatar);
    }

    function changeAvatar(avatar) {
        if (avatar) {
            document.getElementById("avatarImg").src = "images/assets/avatar/" + avatar + ".jpg"
        }
    }

    function memberInit() {
        //外包的js
        // 頭像選擇
        swiper = new Swiper("#avatar-select", {
            loop: true,
            slidesPerView: 2,
            freeMode: true,
            preventClicks: false,
            navigation: {
                nextEl: ".swiper-button-next",
                prevEl: ".swiper-button-prev"
            },

            //onSetTranslate: function (swiper, translate) {
            //    console.log(swiper);
            //    var checkedSlideIndex = $('input:checked').parents('.swiper-slide').attr('data-swiper-slide-index');
            //    var hasDuplicates = $('.swiper-slide[data-swiper-slide-index="' + checkedSlideIndex + '"]').length > 1;
            //    if (hasDuplicates) {
            //        if ($('.swiper-slide-active').attr('data-swiper-slide-index') === checkedSlideIndex) {
            //            $('.swiper-slide-active').find('input').prop('checked', true);
            //        }
            //        else {
            //            $('.swiper-slide-active').nextAll('.swiper-slide[data-swiper-slide-index="' + checkedSlideIndex + '"]').eq(0).find('input').prop('checked', true);
            //        }
            //    }
            //}


        });


        //編輯收合
        $('[data-click-btn="openPanel"]').click(function () {
            $(this).parents('.expansion').addClass('cur');
        });


        //取款密碼設定 
        var editpincodeStep2 = $('[data-click-btn="pincodeStep2"]'),
            closePanel = $('[data-click-btn="closePanel"]'),


            avatar = $('[data-form-group="avatar"]'),
            pincodeStep1 = $('[data-form-group="pincodeStep1"]'),
            pincodeStep2 = $('[data-form-group="pincodeStep2"]');

        editpincodeStep2.click(function () {
            pincodeStep1.addClass('is-hide');
            pincodeStep2.removeClass('is-hide').addClass('is-show');
        });

        closePanel.click(function () {
            $(this).parents('.box-item').removeClass('cur');
        });




        // pincode
        $('.pincode-box input').keyup(function () {
            if (this.value.length == this.maxLength) {
                $(this).next('.pincode-box input').focus();
            }
        });

    }

    function getCookie(cname) {
        var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }

    function setCookie(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    }

    function delCookie(name) {
        function getCookie(cname) {
            var name = cname + "=";
            var decodedCookie = decodeURIComponent(document.cookie);
            var ca = decodedCookie.split(';');
            for (var i = 0; i < ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(name) == 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return "";
        }

        var exp = new Date();
        exp.setTime(exp.getTime() - 1);
        var cval = getCookie(name);
        if (cval != null) document.cookie = name + "=" + cval + ";expires=" + exp.toGMTString();
    }

    function goUserTransfer() {
        if (!WebInfo.UserInfo.IsWalletPasswordSet) {
            window.parent.showMessageOK("", mlp.getLanguageKey("錯誤") + " " + mlp.getLanguageKey("請先設定錢包密碼"), function () {
            });
        } else {
            window.parent.API_LoadPage('UserTransfer', 'UserTransfer.aspx', true);
        }
    }

    function changePassword() {
        var idOldPassword = document.getElementById("idOldPassword");
        var idNewPassword = document.getElementById("idNewPassword");

        if (idOldPassword.value == "") {
            idOldPassword.setCustomValidity(mlp.getLanguageKey("請輸入舊密碼"));
            idOldPassword.reportValidity();
        } else if (idNewPassword.value == "") {
            idNewPassword.setCustomValidity(mlp.getLanguageKey("請輸入新密碼"));
            idNewPassword.reportValidity();
        } else {
            idOldPassword.setCustomValidity("");
            idNewPassword.setCustomValidity("");

            p.SetUserPassword(WebInfo.SID, Math.uuid(), idOldPassword.value, idNewPassword.value, function (success, o) {
                if (success) {
                    if (o.Result == 0) {
                        idOldPassword.value = "";
                        idNewPassword.value = "";

                        window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("帳戶新密碼已設定完成"), function () {
                            updateBaseInfo();
                        });
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請重新嘗試"));
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }
            });
        }
    }

    function changePassword() {
        var idOldPassword = document.getElementById("idOldPassword");
        var idNewPassword = document.getElementById("idNewPassword");

        if (idOldPassword.value == "") {
            idOldPassword.setCustomValidity(mlp.getLanguageKey("請輸入舊密碼"));
            idOldPassword.reportValidity();
        } else if (idNewPassword.value == "") {
            idNewPassword.setCustomValidity(mlp.getLanguageKey("請輸入新密碼"));
            idNewPassword.reportValidity();
        } else {
            idOldPassword.setCustomValidity("");
            idNewPassword.setCustomValidity("");

            p.SetUserPassword(WebInfo.SID, Math.uuid(), idOldPassword.value, idNewPassword.value, function (success, o) {
                if (success) {
                    if (o.Result == 0) {
                        idOldPassword.value = "";
                        idNewPassword.value = "";

                        window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("帳戶新密碼已設定完成"), function () {
                            updateBaseInfo();
                            document.getElementById("idLoginPasswordBox").classList.remove("cur");
                        });
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請重新嘗試"));
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), o);
                    }
                }
            });
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

    function copyText(tag) {
        var copyText = document.getElementById(tag);
        copyText.select();
        copyText.setSelectionRange(0, 99999);

        copyToClipboard(copyText.value)
            .then(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製成功")))
            .catch(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製失敗")));
        //alert("Copied the text: " + copyText.value);
    }

    function copyToClipboard(textToCopy) {
        // navigator clipboard api needs a secure context (https)
        if (navigator.clipboard && window.isSecureContext) {
            // navigator clipboard api method'
            return navigator.clipboard.writeText(textToCopy);
        } else {
            // text area method
            let textArea = document.createElement("textarea");
            textArea.value = textToCopy;
            // make the textarea out of viewport
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            return new Promise((res, rej) => {
                // here the magic happens
                document.execCommand('copy') ? res() : rej();
                textArea.remove();
            });
        }
    }

      function copyActivityUrl() {

          copyToClipboard("https://casino-maharaja.net/lp/01/" + WebInfo.UserInfo.PersonCode)
              .then(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製成功")))
              .catch(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製失敗")));
        
        //alert("Copied the text: " + copyText.value);
    }

    function copyToClipboard(textToCopy) {
        // navigator clipboard api needs a secure context (https)
        if (navigator.clipboard && window.isSecureContext) {
            // navigator clipboard api method'
            return navigator.clipboard.writeText(textToCopy);
        } else {
            // text area method
            let textArea = document.createElement("textarea");
            textArea.value = textToCopy;
            // make the textarea out of viewport
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            return new Promise((res, rej) => {
                // here the magic happens
                document.execCommand('copy') ? res() : rej();
                textArea.remove();
            });
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

    window.onload = init;
</script>
<body>
    <div class="page-container">

        <div class="page-content">
            <div class="member-container">
                <div class="aside-panel">
                    <div class="avatar-container">
                        <div class="avatar">
                            <img id="avatarImg" src="images/assets/avatar/avatar-05.jpg">
                        </div>
                         <button class="btn btn-icon circle" onclick="showAvatar()">
                            <i class="icon-photo-camera"></i>
                        </button> 
                    </div>
                    <div class="balance-info">
                        <div class="balance-info-title" style="display: none;">
                            <i class="icon-coin"></i>
                            <div>SUFFY</div>
                        </div>
                        <div id="idAmount" class="amount">9,999</div>
                    </div>
                </div>
                <div class="main-panel">
                    <div class="sec-title-wrap">
                        <div class="sec-title-inner">
                            <h3 class="title language_replace">會員中心</h3>
                        </div>
                    </div>

                    <div class="setting-container ">
                        <!-- 姓名 -->
                        <div class="box-item expansion">
                            <div class="box-item-inner tab">
                                <i class="icon-user"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title sup language_replace">帳號</div>
                                    <div id="idLoginAccount" class="box-item-desc highlight"></div>
                                </div>
                                <%-- <div class="box-item-detail">
                                    <div class="box-item-title sup language_replace">姓名</div>
                                    <div id="idNickName" class="box-item-desc highlight"></div>
                                </div>--%>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" data-toggle="modal" data-click-btn="openPanel">
                                    <span class="language_replace">檢視</span>
                                </button>
                            </div>
                            <div class="box-item-inner panel ">
                                <div class="form-content">
                                    <form>
                                      
                                     
                                       
                                        <div class="form-group info">
                                            <label class="form-title language_replace">姓名</label>
                                            <div class="input-group">
                                                <div class="form-data" id="idKYCRealName"></div>
                                            </div>
                                        </div>
                                      
                                        <div class="form-group info">
                                            <label class="form-title language_replace">暱稱</label>
                                            <div class="input-group">
                                                <div class="form-data" id="idRealName"></div>
                                            </div>
                                        </div>
                                        <div class="form-group info">
                                            <label class="form-title language_replace">電話</label>
                                            <div class="input-group">
                                                <div class="form-data" id="idPhone"></div>
                                            </div>
                                        </div>
                                         <div class="text-wrap">
                                            <p class="note primary text-s language_replace mt-2 mb-3">※會員資料若需要修改，請與客服聯繫。</p>
                                        </div>
                                        <div class="btn-container">
                                            <button type="button" class="btn btn-outline-primary btn-md" data-click-btn="closePanel"><span class="language_replace">取消</span></button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <!-- 生日 -->
                        <%--  <div class="box-item">
                            <div class="box-item-inner tab">
                                <i class="icon-birth"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title sup language_replace">生日</div>
                                    <div id="idBirthday" class="box-item-desc highlight"></div>
                                </div>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" data-toggle="modal" data-target="#alertContact">
                                    <span class="language_replace">編輯</span>
                                </button>
                            </div>
                        </div>--%>

                        <!-- 登入密碼 -->
                        <div id="idLoginPasswordBox" class="box-item expansion">
                            <div class="box-item-inner tab">
                                <i class="icon-pw"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">登入密碼</div>
                                </div>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" data-click-btn="openPanel">
                                    <span class="language_replace">編輯</span>
                                </button>
                            </div>
                            <div class="box-item-inner panel">
                                <div class="form-content">

                                    <form>
                                        <div class="form-group">
                                            <label class="form-title language_replace">舊密碼</label>
                                            <div class="input-group">
                                                <input id="idOldPassword" type="password" class="form-control custom-style" placeholder="" inputmode="email">
                                                <div class="invalid-feedback language_replace">提示</div>
                                            </div>
                                            <button class="btn btn-icon" type="button" onclick="showPassword('idOldPassword')">
                                                <i class="icon-eye-off"></i>
                                            </button>
                                        </div>

                                        <div class="form-group">
                                            <label class="form-title language_replace">新密碼</label>
                                            <div class="input-group">
                                                <input id="idNewPassword" type="password" class="form-control custom-style" placeholder="" inputmode="email">
                                                <div class="invalid-feedback language_replace">提示</div>
                                            </div>
                                            <button class="btn btn-icon" type="button" onclick="showPassword('idNewPassword')">
                                                <i class="icon-eye-off"></i>
                                            </button>
                                        </div>

                                        <div class="btn-container">
                                            <button type="button" class="btn btn-outline-primary btn-md" data-click-btn="closePanel"><span class="language_replace">取消</span></button>
                                            <button type="button" class="btn btn-primary btn-md" onclick="changePassword()"><span class="language_replace">儲存變更</span></button>
                                        </div>
                                    </form>
                                </div>

                            </div>
                        </div>

                        <!-- 取款密碼 -->
                       <%-- <div id="idWalletPasswordBoxItem" class="box-item expansion">
                            <div class="box-item-inner tab">
                                <i class="icon-withdraw-pw"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title">
                                        <span class="language_replace">取款密碼</span><span style="display: none" id="idWalletPasswordUnSet" class="box-item-status language_replace">尚未設定</span>
                                    </div>
                                </div>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" data-click-btn="openPanel">
                                    <span class="language_replace">編輯</span>
                                </button>
                            </div>
                            <div class="box-item-inner panel">
                                <!-- step 1 -->
                                <div id="idPincodeStep1" class="form-content">
                                    <div class="form-group pincode-box">
                                        <label class="form-title language_replace">輸入密碼</label>
                                        <div id="idWalletDivNew1" class="input-group">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                        </div>
                                    </div>

                                    <div class="btn-container">
                                        <div class="btn btn-outline-primary btn-md" onclick="cancelWalletPassword()"><span class="language_replace">取消</span></div>
                                        <button class="btn btn-primary btn-md" onclick="setWalletPasswordStep1()"><span class="language_replace">下一步</span></button>
                                    </div>
                                </div>
                                <!-- step 2 -->
                                <div id="idPincodeStep2" class="form-content is-hide">
                                    <div class="form-group pincode-box">
                                        <label class="form-title language_replace">確認密碼</label>
                                        <div id="idWalletDivNew2" class="input-group">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                            <input type="password" class="form-control custom-style" maxlength="1" size="1">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-title language_replace">登入密碼</label>
                                        <div class="input-group">
                                            <input id="idWalletLoginPassword" type="password" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入登入密碼確認" inputmode="email">
                                            <div class="invalid-feedback language_replace">提示</div>
                                        </div>
                                        <button class="btn btn-icon" type="button" onclick="showPassword('idWalletLoginPassword')">
                                            <i class="icon-eye-off"></i>
                                        </button>
                                    </div>
                                    <div class="btn-container">
                                        <button class="btn btn-outline-primary btn-md" onclick="cancelWalletPassword()"><span class="language_replace">取消</span></button>
                                        <button class="btn btn-primary btn-md" onclick="setWalletPasswordStep2()"><span class="language_replace">儲存變更</span></button>
                                    </div>
                                </div>
                            </div>
                        </div>--%>
                        <!-- 推廣碼 -->
                      <%--  <div id="idPersonCodeDiv" class="box-item is-hide">
                            <div class="box-item-inner tab">
                                <i class="icon-star"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title sup language_replace">我的推薦碼</div>
                                    <div id="idPersonCode" class="box-item-desc highlight"></div>
                                    <input id="idCopyPersonCode" class="is-hide">
                                    <button class="btn btn-icon" onclick="copyText('idCopyPersonCode')">
                                        <i class="icon-copy"></i>
                                    </button>
                                </div>
                            </div>

                        </div>--%>
                        <!-- 金幣轉移 -->
<%--                        <div class="box-item" style="display: none" id="divTransfer">
                            <div class="box-item-inner tab">
                                <i class="icon-casinoworld-money-flow"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">金幣轉移</div>
                                </div>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" onclick="goUserTransfer()">
                                    <span class="language_replace">前往</span>
                                </button>
                            </div>
                        </div>--%>
                        <!-- 存款紀錄 -->
                        <div id="idPaymentDepositHistoryBox" class="box-item expansion">
                            <div class="box-item-inner tab">
                                <i class="icon-wallet"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">存款紀錄</div>
                                </div>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" data-toggle="modal" onclick="window.parent.API_LoadPage('PaymentHistory', 'PaymentHistory.aspx', true)">
                                    <span class="language_replace">檢視</span>
                                </button>
                            </div>
                        </div>
                        <!-- 我的推廣碼 -->
                        <div class="box-item expansion is-hide"  id="idPersonCodeDiv">
                            <div class="box-item-inner tab">
                                <i class="icon-star"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">我的推廣碼</div>
                                </div>
                                <button class="btn btn-outline-primary btn-sm toggle-panel" data-toggle="modal" data-click-btn="openPanel">
                                    <span class="language_replace">檢視</span>
                                </button>
                            </div>
                            <div class="box-item-inner panel ">
                                <div class="form-content">
                                    <form>                                        
                                        <div class="text-wrap">
                                            <div class="myPromotionCode">
                                                <div class="myPromotionCode-img">
                                                    <div class="img-crop">
                                                        <img id="QRCodeimg" src="" alt="">
                                                    </div>                                                
                                                </div>
                                                <div class="myPromotionCode-container">
                                                    <div class="myPromotionCode-info">
                                                        <!-- <i class="icon-prepend icon-wallet"></i> -->
                                                        <span id="idPersonCode" class="data"></span>
                                                        <input id="idCopyPersonCode" class="is-hide">
                                                    </div>
                                                    <button class="btn btn-icon btn-copy">
                                                        <i class="icon-copy" onclick="copyText('idCopyPersonCode')"></i>
                                                    </button>
                                                </div>
                                            </div>                                           
                                        </div>
                                        <div class="btn-container">
                                            <button type="button" class="btn btn-outline-primary btn-md" data-click-btn="closePanel"><span class="language_replace">取消</span></button>
                                        </div>
                                    </form>
                                </div>

                            </div>
                        </div>                       
                    </div>
                </div>
                <div class="activity-container is-hide">
                    <div class="activity-inner">
                        <h5 class="subject-title language_replace">熱門活動</h5>
                        <div class="text-wrap promo-container">
                            <ul class="promo-list row">
                                <li class="item col col-sm-6 col-md-4 col-xl-3">
                                    <div class="promo-inner">
                                        <div class="promo-img">
                                            <a id="activityURL" href="https://casino-maharaja.net/lp/01/N00000000"
                                                target="_blank">
                                                <div class="img-crop">
                                                    <img src="images/activity/promo-01.jpg"
                                                        alt="とりあえず、当社のドメインで紹介用LPをアップしてみました。">
                                                </div>
                                            </a>
                                        </div>
                                        <div class="promo-content">
                                            <h6 class="title">とりあえず、当社のドメインで紹介用LPをアップしてみました</h6>
                                            <button type="button" class="btn btn-outline-primary btn-link" onclick="copyActivityUrl()">
                                                <span class="language_replace">複製活動連結</span>
                                            </button>
                                        </div>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- avatar popup -->
        <div id="idAvatarPopup" class="overlay-container is-hide" data-form-group="avatar">
            <div class="box-item avatar-select-container">
                <div class="box-item-inner">
                    <p class="text-center mb-4 language_replace">選擇頭像</p>
                    <div class="swiper-container" id="avatar-select">
                        <div class="swiper-wrapper">
                            <div class="swiper-slide">
                                <div class="avatar-select">
                                    <input type="radio" name="avatar" data-avatar_value="avatar-05">
                                    <label for="avatar-05">
                                        <div class="avatar">
                                            <img src="images/assets/avatar/avatar-05.jpg">
                                        </div>
                                    </label>
                                </div>
                            </div>
                            <div class="swiper-slide">
                                <div class="avatar-select">
                                    <input type="radio" name="avatar" data-avatar_value="avatar-06">
                                    <label for="avatar-06">
                                        <div class="avatar">
                                            <img src="images/assets/avatar/avatar-06.jpg">
                                        </div>
                                    </label>
                                </div>
                            </div>
                            <%--
                            <div class="swiper-slide">
                                <div class="avatar-select">
                                    <input type="radio" name="avatar" data-avatar_value="avatar-01">
                                    <label for="avatar-01">
                                        <div class="avatar">
                                            <img src="images/assets/avatar/avatar-01.jpg">
                                        </div>
                                    </label>
                                </div>
                            </div>
                            <div class="swiper-slide">
                                <div class="avatar-select">
                                    <input type="radio" name="avatar" data-avatar_value="avatar-02">
                                    <label for="avatar-02">
                                        <div class="avatar">
                                            <img src="images/assets/avatar/avatar-02.jpg">
                                        </div>
                                    </label>
                                </div>
                            </div>
                            <div class="swiper-slide">
                                <div class="avatar-select">
                                    <input type="radio" name="avatar" data-avatar_value="avatar-03">
                                    <label av for="avatar-03">
                                        <div class="avatar">
                                            <img src="images/assets/avatar/avatar-03.jpg">
                                        </div>
                                    </label>
                                </div>
                            </div>
                            <div class="swiper-slide">
                                <div class="avatar-select">
                                    <input type="radio" name="avatar" data-avatar_value="avatar-04">
                                    <label for="avatar-04">
                                        <div class="avatar">
                                            <img src="images/assets/avatar/avatar-04.jpg">
                                        </div>
                                    </label>
                                </div>
                            </div>
                            --%>
                        </div>
                        <div class="swiper-button-prev"></div>
                        <div class="swiper-button-next"></div>
                    </div>

                    <div class="d-flex justify-content-center btn-container">
                        <button class="btn btn-outline-primary btn-md" onclick="closeAvatar()"><span class="language_replace">取消</span></button>
                        <button class="btn btn-primary btn-md" onclick="saveAvatar()"><span class="language_replace">儲存變更</span></button>
                    </div>
                </div>
            </div>
            <div class="overlay-backdrop"></div>
        </div>


        <!-- Modal 有按鈕-->
        <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="alertContact" aria-hidden="true" id="alertContact">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true"><i class="icon-close-small"></i></span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="modal-body-content">
                            <i class="icon-error_outline primary"></i>
                            <div class="text-wrap">
                                <p class="language_replace">變更個人資訊，請透過客服進行 ！</p>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <div class="btn-container">
                            <button type="button" class="btn btn-primary btn-sm" data-dismiss="modal"><span class="language_replace">前往客服</span></button>
                            <button type="button" class="btn btn-outline-primary btn-sm" data-dismiss="modal"><span class="language_replace">取消</span></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</body>
</html>
