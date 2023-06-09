﻿<%@ Page Language="C#" %>

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
    
    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css"/>
    <link rel="stylesheet" href="css/icons.css?<%:Version%>" type="text/css"/>
    <link rel="stylesheet" href="css/global.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/wallet.css" type="text/css"/>

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
    var WebInfo;
    var lang;
    var mlp;
    var v ="<%:Version%>";
    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        WebInfo = window.parent.API_GetWebInfo();

        lang = window.parent.API_GetLang();
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {

            if (WebInfo.UserInfo.LoginAccount == '819059202064' || WebInfo.UserInfo.LoginAccount == 'test002') {
                document.getElementById('idDepositPaypal').classList.add('is-hide');
            }

            window.parent.API_LoadingEnd();
        },"PaymentAPI");
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
                            <h3 class="title language_replace">存款</h3>
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
                    <p class="language_replace">選擇存款管道</p>
                </div>

                <!-- 選擇存款管道  -->
                <div class="card-container">
					<!-- bankCard -->
                    <div class="card-item sd-03">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('DepositBankCard','DepositBankCard.aspx')">
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
                    <!-- EPay -->
                    <div class="card-item sd-08" style="display: none;">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('DepositEPay','DepositEPay.aspx')">
                            <div class="card-item-inner">
                                <div class="title">
                                    <span class="language_replace">信用卡</span>
                                    <!-- <span>Electronic Wallet</span>  -->
                                </div>
                                <div class="logo vertical-center">
                                    <img src="images/assets/card-surface/icon-logo-visa.svg">
                                </div>
                            </div>
                            <img src="images/assets/card-surface/card-08.svg" class="card-item-bg">
                        </a>      

                    </div>
                    <!-- PayPal -->
                    <div class="card-item sd-08 is-hide" id="idDepositPaypal">
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

                    </div>
                    <!-- 虛擬錢包 -->
                    <div class="card-item sd-02" style="">
                        <a class="card-item-link" onclick="window.parent.API_LoadPage('DepositCrypto','DepositCrypto.aspx')">
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
                <!-- 存款紀錄 -->
                <div class="notice-container mt-5">
                    <div class="notice-item">
                        <i class="icon-wallet"></i>
                        <div class="text-wrap">
                            <p class="title language_replace text-link" onclick="window.parent.API_LoadPage('PaymentHistory', 'PaymentHistory.aspx', true)">檢視存款紀錄</p>
                        </div>
                    </div>
                </div>
                <!-- 溫馨提醒 -->
                <div class="notice-container mt-5">
                    <div class="notice-item">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <p class="title language_replace">溫馨提醒</p>
                            <p class="language_replace">不同的存款管道可能影響存款金額到達玩家錢包的時間。最遲一個營業日為合理的範圍。</p>
      
                            
                        </div>
                    </div>
                </div>

            </section>


        </div>
    </div>
</body>
</html>