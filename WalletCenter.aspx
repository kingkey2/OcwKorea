<%@ Page Language="C#" %> 
<%
    string Version=EWinWeb.Version;
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
<script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/DateExtension.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript">      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var c = new common();
    var ui = new uiControl();
    var p;
    var mlp;
    var lang;
    var WebInfo;
    var PersonCode = "<%:PersonCode%>";
    var v ="<%:Version%>";
    var ParentPersonCode = "";
    function updateBaseInfo() {
        var wallet = WebInfo.UserInfo.WalletList.find(x => x.CurrencyType.toLocaleUpperCase() == WebInfo.MainCurrencyType);
        document.getElementById("idPointValue").innerText = new BigNumber(wallet.PointValue).toFormat();

        var ThresholdInfos = WebInfo.UserInfo.ThresholdInfo;
        if (ThresholdInfos && ThresholdInfos.length > 0) {
            let thresholdInfo = ThresholdInfos.find(x => x.CurrencyType.toLocaleUpperCase() == WebInfo.MainCurrencyType);
            if (thresholdInfo) {
                document.getElementById("idThrehold").innerText = new BigNumber(thresholdInfo.ThresholdValue).toFormat();
            } else {
                document.getElementById("idThrehold").innerText = "0";
            }
        } else {
            document.getElementById("idThrehold").innerText = "0";
        }


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
            updateBaseInfo()
        });

        p.GetParentPersonCode(WebInfo.SID, Math.uuid(), function (success, o) {
            if (success) {
                if (o.ResultState == 0) {
                    ParentPersonCode = o.Message;
                    if (ParentPersonCode == PersonCode) {
                        $('.box-itemPaymentHistory').removeClass('is-hide');
                        $('.box-itemDeposit').removeClass('is-hide');
                    } else {
                        $('.box-itemAgentWithdrawalHistory').removeClass('is-hide');
                    }
                } 
            } 
        });
       

        changeAvatar(getCookie("selectAvatar"));


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
                WebInfo = window.parent.API_GetWebInfo();
                updateBaseInfo();
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
            <header class="heading-top-container-show">
                <div class="heading-top-inner">
                    <div class="heading-user-info">
                        <div class="heading">
                            <div class="avatar">
                                <img id="avatarImg" src="images/assets/avatar/avatar-01.jpg">
                            </div>
                            <!-- <div class="heading-img">
                                <div class="img-crop"><img src="images/assets/walletcenter.png"></div>
                            </div> -->
                            <div class="basic-info">
                                <div class="name"><span class="language_replace">錢包中心</div>
                            </div>
                        </div>
                        <div class="wallet">
                            <div class="balance-info">  
                                <div class="item balance-amount">
                                    <div class="title language_replace">錢包餘額</div>
                                    <div class="data">
                                        <span class="coinType" ></span>
                                        <span id="idPointValue" class="coinAmount"> 9,999.265</span>
                                    </div>
                                </div>                             
                                <div class="item withdraw-limit">
                                    <div class="title language_replace">取款門檻</div>
                                    <div class="data">
                                        <span class="coinType"></span>
                                        <span id="idThrehold" class="coinAmount" > 9,999.265</span>
                                    </div>
                                </div>                             
<%--                                <div class="item bouns-amount">
                                    <div class="title language_replace">領取獎勵</div>
                                    <div class="data">
                                        <span class="coinType">OCoin</span>
                                        <span class="coinAmount"> 9,999.265</span>
                                    </div>
                                </div> --%>
                            </div>
                        </div>
                    </div>
                </div>
            </header>
        </div>
        <div class="page-content">
            <section class="section-wrap">
                <div class="box-item-container walletcenter-menu">
                    <div class="box-item is-hide box-itemDeposit">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('Deposit','Deposit.aspx', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-deposit"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">存款</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="box-item">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('Withdrawal','Withdrawal.aspx', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-withdraw"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">取款</div>
                                </div>
                            </div>
                        </a>
                    </div>
                     <div class="box-item">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('ProgressPaymentHistory','ProgressPaymentHistory.aspx', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-casinoworld-process-order"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">進行中交易</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="box-item is-hide">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('instructions-crypto','instructions-crypto.html', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-news"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">活動專區</div>
                                </div>
                            </div>
                        </a>
                    </div>
                     <div class="box-item is-hide box-itemPaymentHistory">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('PaymentHistory','PaymentHistory.aspx?1', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-file"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">存取款紀錄</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="box-item is-hide box-itemAgentWithdrawalHistory">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('AgentWithdrawalHistory','AgentWithdrawalHistory.aspx?1', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-file"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">下線取款紀錄</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="box-item is-hide" style="display: none;">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('instructions-crypto','instructions-crypto.html')">
                            <div class="box-item-inner tab">
                                <i class="icon icon-casinoworld-newspaper"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">存取款說明</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="box-item is-hide">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('Withdrawal','Withdrawal.aspx', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-coin"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">獎勵專區</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="box-item is-hide" style="display: none;">
                        <a class="box-item-link" onclick="window.parent.API_LoadPage('MemberCenter','MemberCenter.aspx', true)">
                            <div class="box-item-inner tab">
                                <i class="icon icon-setting"></i>
                                <div class="box-item-detail">
                                    <div class="box-item-title language_replace">錢包設定</div>
                                </div>
                            </div>
                        </a>
                    </div>
                     
                </div>
            </section>
        </div>
    </div>
 
</body>
</html>
