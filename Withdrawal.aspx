<%@ Page Language="C#" %>

<%
    string Version = EWinWeb.Version;
    string InOpenTime = EWinWeb.CheckInWithdrawalTime() ? "Y":"N";
    string IsWithdrawlTemporaryMaintenance = EWinWeb.IsWithdrawlTemporaryMaintenance() ? "Y" : "N";
    string PersonCode=EWinWeb.MainPersonCode;
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
    <link rel="stylesheet" href="css/wallet.css" type="text/css" />

</head>

<script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
<script src="Scripts/OutSrc/js/wallet.js"></script>
<script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/libphonenumber.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script>      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var lang;
    var mlp;
    var p;
    var WebInfo;
    var v = "<%:Version%>";
    var IsOpenTime = "<%:InOpenTime%>";
    var PersonCode = "<%:PersonCode%>";
    var IsWithdrawlTemporaryMaintenance = "<%:IsWithdrawlTemporaryMaintenance%>";

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        lang = window.parent.API_GetLang();
        mlp = new multiLanguage(v);
        p = window.parent.API_GetLobbyAPI();
        WebInfo = window.parent.API_GetWebInfo();
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();

            p.GetParentPersonCode(WebInfo.SID, Math.uuid(), function (success, o) {
                if (success) {
                    if (o.ResultState == 0) {
                        ParentPersonCode = o.Message;
                        if (ParentPersonCode == PersonCode) {
                            $('.WithdrawalBankCard').removeClass('is-hide');
                            $('.WithdrawalCrypto').removeClass('is-hide');
                        } else {
                            $('.WithdrawalAgent').removeClass('is-hide');
                        }
                    }
                }
            });

            //if (IsOpenTime == "N") {
            //    window.parent.API_NonCloseShowMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("NotInOpenTime"), function () {
            //        window.parent.API_Reload();
            //    });
            //} else {
            //    if (IsWithdrawlTemporaryMaintenance == "Y") {
            //        window.parent.API_NonCloseShowMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("WithdrawlTemporaryMaintenance"), function () {
            //            window.parent.API_Reload();
            //        });
            //    }
            //}
        }, "PaymentAPI");
    }

    function API_showMessageOK(title, message, cbOK) {
        if ($("#alertContact").attr("aria-hidden") == 'true') {
            var divMessageBox = document.getElementById("alertContact");
            var divMessageBoxCloseButton = divMessageBox.querySelector(".alertContact_Close");
            var divMessageBoxOKButton = divMessageBox.querySelector(".alertContact_OK");
            //var divMessageBoxTitle = divMessageBox.querySelector(".alertContact_Text");
            var divMessageBoxContent = divMessageBox.querySelector(".alertContact_Text");

            if (messageModal == null) {
                messageModal = new bootstrap.Modal(divMessageBox);
            }

            if (divMessageBox != null) {
                messageModal.show();

                if (divMessageBoxCloseButton != null) {
                    divMessageBoxCloseButton.classList.add("is-hide");
                }

                if (divMessageBoxOKButton != null) {
                    //divMessageBoxOKButton.style.display = "inline";

                    divMessageBoxOKButton.onclick = function () {
                        messageModal.hide();

                        if (cbOK != null)
                            cbOK();
                    }
                }

                //divMessageBoxTitle.innerHTML = title;
                divMessageBoxContent.innerHTML = message;
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
    <div class="page-container">
        <!-- Heading-Top -->
        <div id="heading-top"></div>

        <div class="page-content">

            <section class="sec-wrap">
                <!-- 頁面標題 -->
                <div class="page-title-container">
                    <div class="page-title-wrap">
                        <div class="page-title-inner">
                            <h3 class="title language_replace">出款</h3>
                        </div>
                    </div>
                </div>

                <!-- 步驟 -->
                <div class="progress-container progress-line">
                    <div class="progress-step cur">
                        <div class="progress-step-item"></div>
                    </div>
                    <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                    <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                    <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                </div>
                <div class="text-wrap progress-title">
                    <p class="language_replace">選擇出款管道</p>
                </div>

                <!-- 選擇出款管道  -->
                <div class="card-container">

                    <!-- PayPal -->
                    <%--                    <div class="card-item sd-08">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('DepositPayPal','DepositPayPal.aspx')">
                            <div class="card-item-inner">
                                <div class="title">
                                    <span class="language_replace">電子錢包</span>
                                    <!-- <span>Electronic Wallet</span>  -->
                                </div>
                                <div class="logo vertical-center">
                                    <img src="images/assets/card-surface/icon-logo-paypal-w.svg">
                                </div>
                            </div>
                            <img src="images/assets/card-surface/card-08.svg" class="card-item-bg">
                        </a>      

                    </div>--%>
					<!-- bankCard -->
                    <div class="card-item sd-03 is-hide WithdrawalBankCard">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('WithdrawalBankCard','WithdrawalBankCard.aspx')">
                            <div class="card-item-inner">
                                <div class="title">
                                    <span class="language_replace">銀行卡</span>
                                    <!-- <span>Electronic Wallet</span>  -->
                                </div>
                                <div class="logo vertical-center">
                                    <img src="images/assets/card-surface/icon-logo-bankCard.svg">
                                </div>
                            </div>
                            <img src="images/assets/card-surface/card-03.svg" class="card-item-bg">
                        </a>      

                    </div>
					<!-- 代理出款 -->
                    <div class="card-item sd-05 is-hide WithdrawalAgent" style="">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('WithdrawalAgent','WithdrawalAgent.aspx')">
                            <div class="card-item-inner">
                                <div class="title">
                                    <span class="language_replace">銀行卡轉帳</span>
                                </div>
                                <div class="title vertical-center">
                                    <span class="language_replace">通知代理</span>
                                </div>
                            </div>
                            <img src="images/assets/card-surface/card-05.svg" class="card-item-bg">
                        </a>
                    </div>
                    <!-- 虛擬錢包 -->
                    <div class="card-item sd-02 is-hide WithdrawalCrypto" style="">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('WithdrawalCrypto','WithdrawalCrypto.aspx')">
                            <div class="card-item-inner">
                                <div class="title">
                                    <span>Crypto Wallet</span>
                                </div>
                                <div class="title vertical-center">
                                    <span class="language_replace">虛擬貨幣</span>
                                </div>
                                <!-- <div class="desc">
                                    <b>30</b> € -  <b>5,000</b> € No Fee                                   
                                </div> -->
                                <div class="logo">
                                    <i class="icon-logo-usdt"></i>
                                    <!-- <i class="icon-logo-eth-o"></i> -->
                                    <i class="icon-logo-eth"></i>
                                    <i class="icon-logo-btc"></i>
                                    <!-- <i class="icon-logo-doge"></i> -->
                                    <!-- <i class="icon-logo-tron"></i> -->
                                </div>
                                <!-- <div class="instructions-crypto">
                                    <i class="icon-info_circle_outline"></i>
                                    <span onclick="window.open('instructions-crypto.html')" class="language_replace">使用說明</span>
                                </div>                                -->
                            </div>
                            <img src="images/assets/card-surface/card-02.svg" class="card-item-bg">
                        </a>
                    </div>

                </div>
                <!-- 出款紀錄 -->
                <div class="notice-container mt-5">
                    <div class="notice-item">
                        <i class="icon-wallet"></i>
                        <div class="text-wrap">
                            <p class="title language_replace text-link" onclick="window.parent.API_LoadPage('PaymentHistory', 'PaymentHistory.aspx', true)">檢視出款紀錄</p>
                        </div>
                    </div>
                </div>
                <!-- 溫馨提醒 -->
                <!--div class="notice-container mt-5">
                    <div class="notice-item">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <p class="title language_replace">溫馨提醒</p>
                            <p class="language_replace">不同的存款管道可能影響存款金額到達玩家錢包的時間。最遲一個營業日為合理的範圍。</p>
                        </div>
                    </div>
                </div-->

            </section>


        </div>
    </div>
</body>
</html>
