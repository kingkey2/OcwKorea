<%@ Page Language="C#" %>

<%
    string Version = EWinWeb.Version;
    string MainCurrencyType = EWinWeb.MainCurrencyType;
    
    string InOpenTime = EWinWeb.CheckInWithdrawalTime() ? "Y":"N";
    string IsWithdrawlTemporaryMaintenance = EWinWeb.IsWithdrawlTemporaryMaintenance() ? "Y" : "N";
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
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/libphonenumber.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/PaymentAPI.js"></script>
<script type="text/javascript" src="/Scripts/crypto-address-validator.min.js"></script>
<script type="text/javascript" src="/Scripts/DateExtension.js"></script>
<%--<script src="Scripts/OutSrc/js/wallet.js"></script>--%>
<script>      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var WebInfo;
    var mlp;
    var lang;
    var seleCurrency;
    var NomicsExchangeRate;
    var PaymentMethod;
    var c = new common();
    var ActivityNames = [];
    var OrderNumber;
    var PaymentClient;
    var lobbyClient;
    var v = "<%:Version%>";
    var CountInterval;
    var IsOpenTime = "<%:InOpenTime%>";
    var IsWithdrawlTemporaryMaintenance = "<%:IsWithdrawlTemporaryMaintenance%>";
    var MainCurrencyType = "<%:MainCurrencyType%>";
    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        $('.MainCurrencyType').html(MainCurrencyType);
        WebInfo = window.parent.API_GetWebInfo();
        lang = window.parent.API_GetLang();
        PaymentClient = window.parent.API_GetPaymentAPI();
        lobbyClient = window.parent.API_GetLobbyAPI();
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();
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
        },"PaymentAPI");

        GetPaymentMethod();
        btn_NextStep();

        var EthWalletAddress = WebInfo.UserInfo.EthWalletAddress;
        var walletList = WebInfo.UserInfo.WalletList;
        var selectedLang = $('.header-tool-item').eq(2).find('a>span').text();
        var HasBitCoin = false;
        for (var i = 0; i < walletList.length; i++) {
            if (walletList[i].ValueType == 2) {
                HasBitCoin = true;
            }
        }

        seleCurrency = $(".crypto-list").children().find("input[type=radio]:checked").data("val");
        //RefreshExchange();

        window.setInterval(function () {


        }, 30000);
    }

    function btn_NextStep() {
        var Step2 = $('[data-deposite="step2"]');
        var Step3 = $('[data-deposite="step3"]');
        var Step4 = $('[data-deposite="step4"]');


        Step3.hide();
        Step4.hide();

        $('button[data-deposite="step2"]').click(function () {
            //建立訂單/活動
            CreateAgentWithdrawal();
        });
        //$('button[data-deposite="step3"]').click(function () {
        //    //加入參加的活動
        //    ConfirmCryptoWithdrawal();
        //});
    }

    function copyText(tag) {
        var copyText = document.getElementById(tag);
        copyText.select();
        copyText.setSelectionRange(0, 99999);

        navigator.clipboard.writeText(copyText.value).then(
            () => { window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製成功")) },
            () => { window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製失敗")) });
    }

    function copyTextPaymentSerial(tag) {
      
        var copyText = $(tag).parent().find('.inputPaymentSerial')[0];

        copyText.select();
        copyText.setSelectionRange(0, 99999);

        navigator.clipboard.writeText(copyText.value).then(
            () => { window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製成功")) },
            () => { window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製失敗")) });
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

    function CurrencyChange(e) {
        seleCurrency = $(e).data("val");
        $(".RateOutCurrency .unit").text(seleCurrency);
    }

    function GetRealExchange(currency) {
        var R = 0;
        var price;

        if (NomicsExchangeRate && NomicsExchangeRate.length > 0) {
            if (currency == "JKC") {
                price = NomicsExchangeRate.find(x => x["currency"] == "ETH").price;
                R = 1 / (price / 3000);
            } else {
                price = NomicsExchangeRate.find(x => x["currency"] == currency).price;
                R = 1 / price;
            }
        }
        return R;
    }

    function ReSetPaymentAmount(isResetRealRate, Amount) {
        let needResetDom = document.querySelectorAll(".needReset");
        needResetDom.forEach(function (dom) {
            let realRate = 0;
            let HandingFeeAmount = 0;
            let HandingFeeRate = 0
            if (isResetRealRate) {
                let Rate = Number(dom.dataset.rate);
                let Currency = dom.dataset.currency;
                HandingFeeRate = Number(dom.dataset.feerate);
                HandingFeeAmount = Number(dom.dataset.feeamount)
                let RealExChange = GetRealExchange(Currency);
                realRate = 1 * Rate * RealExChange;
                dom.dataset.realrate = realRate.toString();
            } else {
                realRate = Number(dom.dataset.realrate);
                HandingFeeRate = Number(dom.dataset.feerate);
                HandingFeeAmount = Number(dom.dataset.feeamount);
            }

            if (Amount) {
                var calcAmount = ((Amount * (1 - HandingFeeRate)) - HandingFeeAmount) * realRate;
                dom.innerText = new BigNumber(calcAmount.toFixed(6)).toFormat();
            } else {
                dom.innerText = 0;
            }
        });
    }

    function GetPaymentMethod() {
        PaymentClient.GetPaymentMethodByCategory(WebInfo.SID, Math.uuid(), "Agent", 1, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.PaymentMethodResults.length > 0) {
                        PaymentMethod = o.PaymentMethodResults;
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                            window.parent.API_Home();
                        });
                    }
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                        window.parent.API_Home();
                    });
                }
            }
            else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("服務器異常, 請稍後再嘗試一次"), function () {
                    window.parent.API_Home();
                });
            }

        })
    }

    function CoinBtn_Click() {
        let amount = parseInt($(event.currentTarget).data("val"))
        $("#amount").val(amount);
        //$("#ExchangeVal").text(parseInt($(event.target).parent('.btn-radio').find('.OcoinAmount').text()));
        ReSetPaymentAmount(false, amount);
    }

    function setAmount() {
        $("input[name=amount]").prop("checked", false);
        var amount = $("#amount").val().replace(/[^\-?\d.]/g, '')
        $("#amount").val(amount);
        //$("#ExchangeVal").text(amount);
        ReSetPaymentAmount(false, amount);
    }

    function setPaymentAmount() {
        for (var i = 0; i < PaymentMethod.length; i++) {
            let PaymentName = PaymentMethod[i]["PaymentName"];
            let MultiCurrencyInfo = PaymentMethod[i]["MultiCurrencyInfo"];
            let PaymentCode = PaymentMethod[i]["PaymentCode"];
            let RealExchange = PaymentMethod[i]["RealExchange"];
            let ExchangeVal = $("#ExchangeVal").text();
            let JS_MultiCurrencyInfo;

            if ($(`[data-val='${PaymentName}']`).length > 0) {
                if (MultiCurrencyInfo != '') {
                    JS_MultiCurrencyInfo = JSON.parse(MultiCurrencyInfo);
                    for (var j = 0; j < JS_MultiCurrencyInfo.length; j++) {
                        RealExchange = PaymentMethod.find(x => x["PaymentCode"].trim() == JS_MultiCurrencyInfo[j]["ShowCurrency"]).RealExchange;
                        $(`[data-val='${PaymentName}']`).parent().find(".count").eq(j).text(new BigNumber((ExchangeVal * (JS_MultiCurrencyInfo[j]["Rate"]) * RealExchange).toFixed(6)).toFormat());
                        $(`[data-val='${PaymentName}']`).parent().find(".count").eq(j).next().text(JS_MultiCurrencyInfo[j]["ShowCurrency"]);
                    }
                } else {
                    $(`[data-val='${PaymentName}']`).parent().find(".count").eq(0).text(new BigNumber((ExchangeVal * RealExchange).toFixed(6)).toFormat());
                    $(`[data-val='${PaymentName}']`).parent().find(".count").eq(0).next().text(PaymentCode);
                }
            }
        }
    }

    //建立訂單
    function CreateAgentWithdrawal() {
        if ($("#amount").val() != '') {
            var amount = parseFloat($("#amount").val());
            var bankName = $("#idBankName").val().trim();
            var bankBranchName = $("#idBankBranchName").val().trim();
            var bankCard = $("#idBankCard").val().trim();
            var bankCardName = $("#idBankCardName").val().trim();

            if (!bankName || bankName == '') {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("銀行名稱不能為空"), function () {
                });

                return false;
            }

            if (!bankCard || bankCard == '') {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("銀行卡號不能為空"), function () {
                });
                return false;
            }

            if (!bankCardName || bankCardName == '') {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("收款人姓名不能為空"), function () {
                });
                return false;
            }
       
            PaymentClient.CreateAgentWithdrawal(WebInfo.SID, Math.uuid(), amount, bankName, bankBranchName, bankCard, bankCardName, function (success, o) {
                        if (success) {
                            let data = o.Data;
                            if (o.Result == 0) {
                           
                                $("#depositdetail .BankName").text(bankName);
                                //$("#depositdetail .OrderNumber").text(data.OrderNumber);
                                $("#depositdetail .BankBranchName").text(bankBranchName);
                                $("#depositdetail .BankCard").text(bankCard);
                                $("#depositdetail .BankCardName").text(bankCardName);
                                $("#depositdetail .Amount").text(BigNumber(amount).toFormat());
                                
                                
                                GetDepositActivityInfoByOrderNumber(OrderNumber);
                            } else {
                                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"),mlp.getLanguageKey(o.Message), function () {

                                });
                            }

                        }
                        else {
                            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("訂單建立失敗"), function () {

                            });
                        }
                    })
              
        } else {
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入購買金額"), function () {

            });
        }
    }
    //根據訂單編號取得可參加活動
    function GetDepositActivityInfoByOrderNumber(OrderNum) {
        clearInterval(CountInterval);
        var Step2 = $('[data-deposite="step2"]');
        var Step3 = $('[data-deposite="step3"]');

        Step2.hide();
        Step3.fadeIn();
        $('button[data-deposite="step3"]').hide();
        $('.progress-step:nth-child(3)').addClass('cur');
    }
    //完成訂單
    function ConfirmCryptoWithdrawal() {
        PaymentClient.ConfirmCryptoWithdrawal(WebInfo.SID, Math.uuid(), OrderNumber, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    //setEthWalletAddress(o.Message)
                    let Step3 = $('button[data-deposite="step3"]');
                    let Step4 = $('button[data-deposite="step4"]');
                    Step3.hide();
                    Step4.fadeIn();
                    $('.progress-step:nth-child(4)').addClass('cur');
                    $("#depositdetail .OrderNumber").text(o.Message);
                     $("#depositdetail .inputPaymentSerial").val(o.Message);
                    $("#depositdetail .OrderNumber").parent().show();
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                    });
                }
            }
            else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                });
            }
        })
    }

    function setEthWalletAddress(EthAddress) {
        $('#idEthAddr').text(EthAddress);
        $('#idEthAddrInput').val(EthAddress);
        $('#cryptoimg').attr("src", `/GetQRCode.aspx?QRCode=${EthAddress}&Download=2`);
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
                    <div class="progress-step cur">
                        <div class="progress-step-item"></div>
                    </div>
                  <%--  <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>--%>
                    <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                </div>
                <div class="text-wrap progress-title" style="display: none">
                    <p data-deposite="step2">輸入出款金額</p>
                    <p data-deposite="step3" class="language_replace">入金確認</p>
                    <p data-deposite="step4" class="language_replace">
                        <span class="language_replace">使用</span>
                        <span class="language_replace">KRW</span>
                        <span class="language_replace">入款</span>
                    </p>
                </div>
                <div class="split-layout-container">
                    <%--
                    <div class="aside-panel">
                        <!-- 卡片 -->
                        <div class="card-item sd-02">
                            <div class="card-item-inner">
                                <!-- <div class="title">USDT</div> -->
                                <div class="title">
                                    <span class="language_replace">加密貨幣</span>
                                    <!-- <span>Crypto Wallet</span>  -->
                                </div>
                                <div class="amount-info is-hide">
                                    <div class="amount-info-title language_replace">本次出款 (USD)</div>
                                    <div class="amount">
                                        <sup>$</sup>
                                        <span class="count">99</span>
                                    </div>
                                </div>
                                <div class="desc transform-result is-hide"><span class="language_replace">日幣換算：約</span> <b>0</b> <span class="language_replace">元</span></div>
                                <div class="logo">
                                    <i class="icon-logo-usdt"></i>
                                    <!-- <i class="icon-logo-eth-o"></i> -->
                                    <i class="icon-logo-eth"></i>
                                    <i class="icon-logo-btc"></i>
                                    <!-- <i class="icon-logo-doge"></i> -->
                                    <!-- <i class="icon-logo-tron"></i> -->
                                </div>
                            </div>
                            <img src="images/assets/card-surface/card-02.svg" class="card-item-bg">
                        </div>
                        <div class="text-wrap payment-change">
                            <a href="deposit.html" class="text-link c-blk">
                                <i class="icon-transfer"></i>
                                <span>切換</span>
                            </a>
                        </div>                        
                        <div class="form-content" data-deposite="step2">
                            <form>
                                <div class="form-group">
                                    <label class="form-title">金額</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control custom-style" placeholder="請輸入金額或選擇金額" inputmode="numeric">
                                        <div class="invalid-feedback">提示</div>
                                    </div>
                                </div>
        
                                <div class="btn-wrap btn-radio-wrap">
                                    <div class="btn-radio">
                                        <input type="radio" name="amount" id="amount1" >
                                        <label class="btn btn-outline-primary" for="amount1">
                                            <span>$25</span>
                                        </label>
                                    </div>
                                    
                                    <div class="btn-radio">
                                        <input type="radio" name="amount" id="amount2" >
                                        <label class="btn btn-outline-primary" for="amount2">
                                            <span>$50</span>
                                        </label>
                                    </div>

                                    <div class="btn-radio">
                                        <input type="radio" name="amount" id="amount3" >
                                        <label class="btn btn-outline-primary" for="amount3">
                                            <span>$100</span>
                                        </label>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    --%>

                    <!-- 虛擬錢包 step2 -->
                    <div class="aside-panel" data-deposite="step2">
                        <div class="form-content">
                            <h5 class="language_replace">選擇或填入出款金額</h5>
                            <!-- 出款提示 -->
                            <div class="form-group text-wrap desc mt-2 mt-md-4">
                                <!-- <h5 class="language_replace">便捷金額出款</h5> -->
                                <p class="text-s language_replace">請從下方金額選擇您要的金額，或是自行填入想要出款的金額。兩種方式擇一即可。</p>
                            </div>
                            <form>
                                <div class="form-group">
                                    <div class="btn-wrap btn-radio-wrap btn-radio-payment">
                                        <div class="btn-radio btn-radio-coinType">
                                            <input type="radio" name="amount" id="amount1" />
                                            <label class="btn btn-outline-primary" for="amount1" data-val="10000" onclick="CoinBtn_Click()">
                                                <span class="coinType gameCoin">
                                                    <%-- <span class="coinType-title language_replace">遊戲幣</span>--%>
                                                    <span class="coinType-title MainCurrencyType"></span>
                                                    <span class="coinType-amount OcoinAmount">10,000</span>
                                                </span>
                                            </label>
                                        </div>

                                        <div class="btn-radio btn-radio-coinType">
                                            <input type="radio" name="amount" id="amount2" />
                                            <label class="btn btn-outline-primary" for="amount2" data-val="50000" onclick="CoinBtn_Click()">
                                                <span class="coinType gameCoin">
                                                    <span class="coinType-name MainCurrencyType"></span>
                                                    <span class="coinType-amount OcoinAmount">50,000</span>
                                                </span>
                                            </label>
                                        </div>

                                        <div class="btn-radio btn-radio-coinType">
                                            <input type="radio" name="amount" id="amount3" />
                                            <label class="btn btn-outline-primary" for="amount3" data-val="100000" onclick="CoinBtn_Click()">
                                                <span class="coinType gameCoin">
                                                    <%--<span class="coinType-title language_replace">遊戲幣</span>--%>
                                                    <span class="coinType-name MainCurrencyType"></span>
                                                    <span class="coinType-amount OcoinAmount">100,000</span>
                                                </span>
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <!-- 輸入金額-->
                                <div class="form-group language_replace">
                                    <label class="form-title language_replace">輸入金額</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control custom-style" id="amount" language_replace="placeholder" placeholder="請輸入金額" onkeyup="setAmount()" />
                                        <div class="form-notice-aside unit MainCurrencyType" id="OrderCurrencyType"></div>
                                        <div class="invalid-feedback language_replace">提示</div>
                                    </div>
                                </div>
                                <div class="form-group cryptoWallet-address">
                                    <label class="form-title language_replace">輸入銀行名稱</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="icon icon-bank"></i></span>
                                        </div>
										<input type="text" class="form-control custom-style" id="idBankName" language_replace="placeholder" placeholder="輸入銀行名稱" />
                                    </div>
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
								<div class="form-group cryptoWallet-address">
                                    <label class="form-title language_replace">輸入分行別</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="icon icon-bank"></i></span>
                                        </div>
										<input type="text" class="form-control custom-style" id="idBankBranchName" language_replace="placeholder" placeholder="輸入分行別" />
                                    </div>
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
								<div class="form-group cryptoWallet-address">
                                    <label class="form-title language_replace">輸入銀行卡號</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="icon icon-wallet"></i></span>
                                        </div>
										<input type="text" class="form-control custom-style" id="idBankCard" language_replace="placeholder" placeholder="輸入銀行卡號" />
                                    </div>
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
								<div class="form-group cryptoWallet-address">
                                    <label class="form-title language_replace">收款人姓名</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="icon icon-user-circle"></i></span>
                                        </div>
										<input type="text" class="form-control custom-style" id="idBankCardName" language_replace="placeholder" placeholder="收款人姓名" />
                                    </div>
                                    <div class="invalid-feedback language_replace">提示</div>
                                </div>
                                <!-- 換算金額(日元) -->
                                <%--<div class="form-group ">
                                    <div class="input-group inputlike-box-group">
                                        <span class="inputlike-box-prepend">≒</span>--%>
                                <!-- 換算金額(日元)-->
                                <!-- 兌換後加入 class =>exchanged-->
                                <%--<span class="inputlike-box "><span ></span></span>--%>
                                <%--                                        <span class="inputlike-box-append">
                                            <span class="inputlike-box-append-title" id="ExchangeVal"></span>
                                            <span class="inputlike-box-append-unit">Ocoin</span>
                                        </span>
                                    </div>
                                </div>--%>
                            </form>
                        </div>
                    </div>
                    <!--div class="main-panel cryptopanel" data-deposite="step2" >
                        <div class="box-item-container crypto-list">
                            <div class="notice-container mt-3 mb-3">
                                <div class="notice-item">
                                    <i class="icon-info_circle_outline"></i>
                                    <div class="text-wrap">
                                        <p class="title language_replace">溫馨提醒</p>
                                          <ul class="list-style-decimal">
                                            <li><span class="language_replace">出金表示金額には燃料費が含まれております(10万OCOIN以下の場合は、燃料費を差引いての着金となります。)</span></li>
                                            <li><span class="language_replace">10万 OCOIN 以上の出金の場合は燃料費は無料となります。</span></li>
                                            <li><span class="language_replace">出金は1日３回までとなります。</span></li>
                                            <li><span class="language_replace">1日出金最大限度額が100万OCOINとなります。</span></li>
                                            <li><span class="language_replace">出金申請後、弊社が送金完了した時点でお客様からのウォレットアドレスの変更、間違い等の申請には対応を協力致しますが、責任は一切負いかねます。出金の際、よくウォレットアドレス確認して下さい。</span></li>
                                         </ul>  
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div-->

                    <!-- 虛擬錢包 step3 -->
                    <%--<div class="aside-panel" data-deposite="step3">
                        <div class="deposit-confirm">
                            <h5 class="language_replace">入金細項確認</h5>
                            <ul class="deposit-detail">
                                <li class="item">
                                    <h6 class="title language_replace">存入金額</h6>
                                    <span class="data">6000</span>
                                </li>
                                <li class="item">
                                    <h6 class="title language_replace">虛擬幣別</h6>
                                    <span class="data">USDT</span>
                                </li>
                                <li class="item">
                                    <h6 class="title language_replace">出款門檻</h6>
                                    <span class="data ThresholdVal">6000</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <div class="main-panel" data-deposite="step3">
                        <!-- 出款獎勵 -->
                        <div class="text-wrap award-content">
                            <h6 class="language_replace">這次出款可獲得的獎勵</h6>
                            <ul class="award-list ActivityMain">
                            </ul>
                        </div>
                    </div>--%>

                    <!-- 虛擬錢包 step3 - 入金確認頁-->
                    <div class="deposit-confirm " data-deposite="step3" id="depositdetail">
                        <div class="aside-panel">
                            <div class="deposit-calc">
                                <div class="deposit-crypto">
                                    <h5 class="subject-title language_replace">出款項目</h5>
                                    <ul class="deposit-crypto-list Collectionitem">
                                    </ul>
                                </div>
                                <div class="deposit-total">
                                    <div class="item total">
                                        <div class="title">
                                            <h5 class="name language_replace">出金金額</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name PaymentCode MainCurrencyType"></span>
                                            <span class="count Amount"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="main-panel">
                            <div class="deposit-list">
                                <h5 class="subject-title language_replace">出款細項</h5>
                                <ul class="deposit-detail">
                                    <li class="item" style="display: none">
                                        <h6 class="title language_replace">訂單號碼</h6>
                                        <span class="data OrderNumber"></span>
                                         <input class="inputPaymentSerial is-hide" />
                                        <i class="icon-copy" onclick="copyTextPaymentSerial(this)" style="display: inline;"></i>     
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">銀行名稱</h6>
                                        <span class="data BankName"></span>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">分行別</h6>
                                        <span class="data BankBranchName"></span>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">收款人</h6>
										<span class="data BankCardName"></span>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">銀行卡號</h6>
                                        <span class="data BankCard"></span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <%--                        <div class="activity-container">
                            <div class="activity-item">
                                <h5 class="subject-title language_replace">熱門活動</h5>
                                <!-- 出款獎勵 -->
                                <div class="text-wrap award-content">
                                    <ul class="deposit-award-list ActivityMain">
                                    </ul>
                                </div>
                            </div>
                        </div>--%>
                    </div>

                    <!-- 虛擬錢包 step4 -->
                    <div class="main-panel" data-deposite="step4">

                        <div class="crypto-info-coantainer">
                            <div class="box-item" style="display: none">
                                <!-- 子選項 -->
                                <div class="sub-box">
                                    <div class="sub-box-item">
                                        <input type="radio" name="payment-crypto-contract" id="payment-cry-cont1" checked>
                                        <label class="sub-box-item-inner" for="payment-cry-cont1">
                                            <div class="sub-box-item-detail"><i class="icon-check"></i><span class="contract">ERC20</span></div>
                                        </label>
                                    </div>
                                    <div class="sub-box-item" style="display: none">
                                        <input type="radio" name="payment-crypto-contract" id="payment-cry-cont2">
                                        <label class="sub-box-item-inner" for="payment-cry-cont2">
                                            <div class="sub-box-item-detail"><i class="icon-check"></i><span class="contract">TRC20</span></div>
                                        </label>
                                    </div>
                                </div>

                            </div>

                            <h4 class="mt-2 mt-md-4 cryoto-address language_replace">收款錢包地址</h4>
                            <div class="img-wrap qrcode-img">
                                <img id="cryptoimg" src="">
                            </div>
                            <div class="crypto-info">
                                <%--<div class="is-hide amount-info">
                                    <div class="amount">
                                        <sup>BTC</sup>
                                        <span class="count" id="cryptoPoint">0.000000</span>
                                    </div>
                                    <button class="btn btn-icon" onclick="copyText('cryptoPoint')">
                                        <i class="icon-copy"></i>
                                    </button>
                                </div>--%>
                                <div class="wallet-code-container">
                                    <div class="wallet-code-info">
                                        <i class="icon-wallet"></i>
                                        <span id="idEthAddr"></span>
                                        <input id="idEthAddrInput" class="is-hide" />
                                    </div>
                                    <button class="btn btn-icon">
                                        <i class="icon-copy" onclick="copyText('idEthAddrInput')"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="crypto-info-related">
                                <!-- 查詢入款交易狀況 -->
                                <div class="crypto-info-inqury">
                                    <div class="content">
                                        <p class="desc">
                                            <span class="language_replace desc-1">可透過</span>
                                            <a href="https://etherscan.io/" target="_blank" class="btn btn-outline-primary btn-etherscan btn-white">Etherscan</a><span class="language_replace desc-2">查詢入款交易狀況</span>
                                        </p>
                                        <!-- 說明頁 -->
                                        <button type="button" class="btn btn-icon" onclick="window.parent.API_LoadPage('instructions-crypto', 'instructions-crypto.html', true)">
                                            <i class="icon-casinoworld-question-outline"></i>
                                        </button>
                                    </div>
                                </div>
                                <!-- 匯率換算 -->
                                <div class="crypto-exchange-rate" style="display: none">
                                    <div class="rate">
                                        <p class="crypto RateOutCurrency"><span class="amount">1</span><span class="unit">USDT</span></p>
                                        <span class="sym">=</span>
                                        <p class="currency ExchangeRateOut"><span class="amount">100</span><span class="unit">Ocoin</span></p>
                                    </div>
                                    <div class="refresh" style="display: none;">
                                        <p class="period"><span class="date"></span><span class="time" style="display: none">15:30:02</span></p>
                                        <button type="button" class="btn btn-outline-primary btn-icon btn-refresh  btn-white" onclick="RefreshExchange()">
                                            <i class="icon-casinoworld-refresh" onclick=""></i>
                                            <span class="language_replace">更新</span>
                                        </button>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

                <div class="btn-container mt-2">
                    <button class="btn btn-primary" data-deposite="step2">
                        <span class="language_replace">下一步</span>
                    </button>
                    <button class="btn btn-primary" data-deposite="step3">
                        <span class="language_replace">下一步</span>
                    </button>
                    <%--     <button class="btn btn-outline-primary" data-deposite="step4" href="index.aspx">
                        <span class="language_replace">首頁</span>
                    </button>
                      <button class="btn btn-primary" data-deposite="step4" data-toggle="modal" data-target="#depositSucc">
                        <span>確認</span>
                    </button>--%>
                </div>

                <!-- 溫馨提醒 -->
                <div class="notice-container is-hide" data-deposite="step4">
                    <div class="notice-item">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <p class="title language_replace">溫馨提醒</p>
                            <ul class="list-style-decimal">
                                <li><span class="language_replace">OCoin為平台使用的專屬遊戲幣。</span></li>
                                <li><span class="language_replace">請正確使用對應的錢包入款，否則可能造成您入款失敗。</span></li>
                                <li><span class="language_replace">虛擬貨幣入款需經過區塊認證確認，可能需要數分鐘或者更久，完成時間並非由本網站決定，敬請知悉。</span></li>
                                <li><span class="language_replace">實際入款遊戲幣為入款金額-手續費後之餘額進行換算。</span></li>
                                <li><span class="language_replace">匯率可能隨時變動中，所有交易以本網站的匯率為準，打幣後交易期間若有變動，將以實際入幣時的匯率撥給遊戲幣。建議您可於入款前重整匯率資訊，確保您同意目前的匯率後進行入款。</span></li>
                                <li><span class="language_replace">『ETH』和USDT的『ERC20』可透過 https://etherscan.io/ 進行查詢交易的狀況。</span></li>
                            </ul>
                            <!-- <ul class="list-style-decimal">
                                <li><span class="language_replace">請正確使用對應的錢包入款，否則將造成資產損失。</span><br>
                                    <span class="primary language_replace">※USDT請勿使用ERC20以外的協定。</span></li>
                                <li class="language_replace">虛擬貨幣入賬需經過數個區塊確認，約需要數分鐘時間。</li>
                            </ul> -->
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>


    <!-- Modal 有溫馨提醒-->
    <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="depositSucc" aria-hidden="true" id="depositSucc">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true"><i class="icon-close-small"></i></span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="modal-body-content">
                        <i class="icon-circle-check green"></i>
                        <div class="text-wrap">
                            <h6 class="language_replace">出款成功 !</h6>
                            <p class="language_replace">您可進入遊戲確認您本次的入金，以及對應的 Bouns 獎勵。</p>
                        </div>
                    </div>
                    <div class="modal-body-content">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <h6 class="language_replace">溫馨提醒</h6>
                            <p class="language_replace">匯率波動以交易所為主，匯率可能不定時更新。</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                </div>
            </div>
        </div>
    </div>

    <div id="templateActivity" style="display: none">
        <li class="item">
            <div class="custom-control custom-checkbox chkbox-item">
                <input class="custom-control-input-hidden ActivityCheckBox" type="checkbox" name="payment-crypto">
                <label class="custom-control-label">
                    <div class="detail">
                        <h6 class="title language_replace ActivityTitle"></h6>
                        <p class="desc language_replace ActivitySubTitle"></p>
                    </div>
                </label>
            </div>
        </li>
    </div>

    <div id="templateCollectionitem" style="display: none">
        <li class="item">
            <div class="title">
                <i class="icon-logo icon-logo-btc currencyicon"></i>
                <h6 class="name currency"></h6>
            </div>
            <span class="data val"></span>
        </li>
    </div>

    <div id="templatePaymentMethod" style="display: none">
        <div class="box-item">
            <input class="PaymentCode" type="radio" name="payment-crypto">
            <label class="box-item-inner tab">
                <div class="box-item-info">
                    <i class="icon-logo"></i>
                    <div class="box-item-detail">
                        <div class="box-item-title">
                            <div class="coinUnit">
                                <span class="coinType">BTC</span>
                            </div>
                            <div class="amount">
                                <%--                                <div class="item">
                                    <span class="count BTCval">0</span><sup class="unit"></sup>
                                </div>
                                <div class="item">
                                    <span class="count ETHval">0</span><sup class="unit"></sup>
                                </div>--%>
                            </div>
                            <%--<span class="box-item-status">1 TRON = 1234567 USD</span>--%>
                        </div>
                    </div>
                </div>
                <div class="box-item-sub">
                    <div class="coinPush">
                        <i class="icon icon-coin"></i>
                        <p class="text hintText">業界最高! Play Open Bouns! 最大100% &10萬送給您!首次 USDT 入金回饋100%</p>
                    </div>
                </div>

            </label>
        </div>
    </div>
</body>
</html>
