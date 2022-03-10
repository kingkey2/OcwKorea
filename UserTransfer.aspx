<%@ Page Language="C#" %>

<%
       string Version=EWinWeb.Version;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maharaja</title>
    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="css/icons.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/global.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="/css/wallet.css" type="text/css" />
</head>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
<script type="text/javascript" src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script>
    if (self != top) {
        window.parent.API_LoadingStart();
    }

    var c = new common();
    var mlp;
    var lang;
    var WebInfo;
    var p;
    var newTransferGuid;
    var isCheckUserExist = false;
    var v ="<%:Version%>";
    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        } else {
            window.parent.API_LoadingStart();
        }

        WebInfo = window.parent.API_GetWebInfo();
        p = window.parent.API_GetLobbyAPI();
        lang = window.parent.API_GetLang();
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();

            if (!WebInfo.UserInfo.IsWalletPasswordSet) {
                window.parent.showMessageOK("", mlp.getLanguageKey("錯誤") + " " + mlp.getLanguageKey("請先設定錢包密碼"), function () {
                });
            }
        });

        document.getElementById("idWalletAmount").innerText = new BigNumber(WebInfo.UserInfo.WalletList.find(x => x.CurrencyType == window.parent.API_GetCurrency()).PointValue).toFormat();
        document.getElementById("idUserName").innerText = WebInfo.UserInfo.RealName;
        changeAvatar(getCookie("selectAvatar"));
    }


    function checkUserExist() {
        var GUID = Math.uuid();
        var searchInput = document.getElementById("idSearchInput");

        if (searchInput.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入信箱"));
            return;
        } else if (searchInput.value == WebInfo.UserInfo.LoginAccount) {
            window.parent.showMessageOK("", mlp.getLanguageKey("你無法跟自己交易"));
            return;
        }

        p.CheckAccountExist(GUID, searchInput.value, function (success, o) {
            if (success) {
                if (o.Result != 0) {
                    window.parent.showMessageOK("", mlp.getLanguageKey("查無此信箱"));
                } else {
                    isCheckUserExist = true;
                    document.getElementById("idConfirmSearchUser").classList.add("is-hide");
                }
            }
        });
    }

    function unSetSearchStatus() {
        isCheckUserExist = false;
        document.getElementById("idConfirmSearchUser").classList.remove("is-hide");
    }

    function clearInputValue(tag) {
        var x = document.getElementById(tag);
        if (x) {
            x.value = "";
        }
    }

    function transferAmount() {
        var GUID = Math.uuid();
        var idLoginAccount = document.getElementById("idSearchInput");
        var idAmount = document.getElementById("idAmount");
        var idWalletPassword = document.getElementById("idWalletPassword");

        if (isCheckUserExist == false) {
            window.parent.showMessageOK("", mlp.getLanguageKey("請先確認該信箱是否存在"));
            return;
        } else if (isCheckUserExist.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入信箱"));
            return;
        } else if (idAmount.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入金額"));
            return;
        } else if (idWalletPassword.value == "") {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入錢包密碼"));
            return;
        } else if (!Number(idAmount.value)) {
            window.parent.showMessageOK("", mlp.getLanguageKey("請輸入金額"));
            return;
        }

        p.UserAccountTransfer(WebInfo.SID,
            GUID,
            idLoginAccount.value,
            window.parent.API_GetCurrency(),
            window.parent.API_GetCurrency(),
            idAmount.value,
            idWalletPassword.value,
            "",
            function (success, o) {
                if (success) {
                    if (o.Result == 0) {
                        newTransferGuid = o.Message;
                        window.parent.showMessageOK("", mlp.getLanguageKey("是否要轉移金幣")
                            + "：" + idAmount.value
                            + "<br/>" + mlp.getLanguageKey("給") + " " + idLoginAccount.value,
                            function () {
                                p.ConfirmUserAccountTransfer(WebInfo.SID, GUID, newTransferGuid, function (success, o) {
                                    if (success) {
                                        if (o.Result == 0) {
                                            window.parent.sleep(500).then(() => {
                                                window.parent.showMessageOK("", mlp.getLanguageKey("轉移成功"), function () {
                                                    window.parent.API_LoadPage('UserTransfer', 'UserTransfer.aspx', true)
                                                });
                                            })
                                        } else {
                                            window.parent.showMessageOK("", mlp.getLanguageKey(o.Message));
                                        }
                                    } else {
                                        window.parent.showMessageOK("", mlp.getLanguageKey("網路錯誤"));
                                    }
                                });
                            });
                    } else {
                        window.parent.showMessageOK("", mlp.getLanguageKey(o.Message));
                    }
                } else {
                    window.parent.showMessageOK("", mlp.getLanguageKey("網路錯誤"));
                }
            });
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

    function changeAvatar(avatar) {
        if (avatar) {
            document.getElementById("avatarImg").src = "images/assets/avatar/" + avatar + ".jpg"
        }
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
        <!-- Heading-Top -->
        <div id="heading-top">
            <header class="heading-top-container">
                <div class="heading-top-inner">
                    <div class="heading-user-info row justify-content-between">
                        <div class="col d-flex align-items-center">
                            <div class="avatar">
                                <img id="avatarImg" src="images/assets/avatar/avatar-01.jpg">
                            </div>
                            <div class="basic-info">
                                <div class="name"><span id="idUserName">Yamada Taro</span><span>'s</span></div>
                                <%--       <div class="language_replace">錢包</div>--%>
                            </div>
                        </div>
                        <div class="col d-flex">
                            <div class="balance-info">
                                <div class="balance-info-title">
                                    <i class="icon-coin"></i>
                                    <div>SUFFY</div>
                                </div>
                                <div id="idWalletAmount" class="amount">9,999</div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>
        </div>

        <div class="page-content">

            <section class="section-wrap">
                <!-- 頁面標題 -->
                <div class="page-title-container">
                    <div class="page-title-wrap">
                        <div class="page-title-inner">
                            <h3 class="title language_replace">金幣轉移</h3>
                        </div>
                    </div>
                    <div class="header-right">
                        <button class="btn btn-outline-primary btn-sm" onclick="window.parent.API_LoadPage('TransferHistory', 'TransferHistory.aspx')">
                            <span class="language_replace">轉移紀錄</span>
                        </button>
                    </div>
                </div>
                <!-- 會員登入 -->
                <div class="form-container" data-form-group="">

                    <div class="form-content">
                        <form>
                            <div class="form-group">
                                <label class="form-title language_replace">轉移對象</label>
                                <div class="input-group">
                                    <input id="idSearchInput" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入信箱搜尋" inputmode="" onchange="unSetSearchStatus()">
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
                                <div class="multiple-button">
                                    <!-- 當 確認完成 時，btn-confirm => class 加入 "is-hide" -->
                                    <!-- Clear Button-->
                                    <button class="btn btn-icon btn-former btn-reset" type="button" onclick="clearInputValue('idSearchInput')" style="display: none">
                                        <i class="icon-close-small"></i>
                                    </button>
                                    <button id="idConfirmSearchUser" class="btn btn-icon btn-confirm btn-latter" type="button" onclick="checkUserExist()">
                                        <i class="icon-casinoworld-search"></i><span class="language_replace">確認</span>
                                    </button>
                                    <!-- 確認完成-正確狀態-->
                                    <div class="btn btn-icon btn-confirm-check btn-latter">
                                        <i class="icon-circle-check"></i>
                                    </div>
                                </div>


                            </div>

                            <div class="form-group">
                                <label class="form-title language_replace">轉移金額</label>
                                <div class="input-group">
                                    <input id="idAmount" type="text" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入金額">
                                    <div class="invalid-feedback language_replace">請輸入金額</div>
                                </div>
                                <button class="btn btn-icon btn-reset" type="button" onclick="clearInputValue('idAmount')">
                                    <i class="icon-close-small"></i>
                                </button>
                            </div>
                            <!-- Trick：防止chrome 密碼記憶 password input 前一欄位自動填入 -->
                            <div class="form-group" style="margin: 0; padding: 0; opacity: 0; height: 0; width: 0; line-height: 0;">
                                <div class="input-group">
                                    <input type="text" class="form-control custom-style" language_replace="placeholder" placeholder="">
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-title language_replace">錢包密碼</label>
                                <div class="input-group">
                                    <input id="idWalletPassword" type="password" class="form-control custom-style" language_replace="placeholder" placeholder="請輸入錢包密碼">
                                    <div class="invalid-feedback language_replace">請輸入密碼</div>
                                </div>
                                <button class="btn btn-icon btn-confirm btn-latter" type="button" onclick="showPassword('idWalletPassword')">
                                    <i class="icon-eye-off"></i>
                                </button>
                            </div>

                            <div class="btn-container">
                                <button class="btn btn-outline-primary btn" onclick="window.parent.API_LoadPage('MemberCenter', 'MemberCenter.aspx')"><span class="language_replace">取消</span></button>
                                <button type="button" class="btn btn-primary" onclick="transferAmount()"><span class="language_replace">確認</span></button>
                            </div>
                        </form>
                    </div>

                </div>
            </section>
        </div>
    </div>
</body>
</html>
