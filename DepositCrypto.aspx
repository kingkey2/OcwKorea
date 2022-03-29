<%@ Page Language="C#" %>

<%
    string Version = EWinWeb.Version;
    string MainCurrencyType = EWinWeb.MainCurrencyType;
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
    var ExpireSecond = 0;
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
        }, "PaymentAPI");

        GetPaymentMethod();
        startCountDown();
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

        //Date.prototype.addSecs = function (s) {
        //    this.setTime(this.getTime() + (s * 1000));
        //    return this;
        //}

        window.setInterval(function () {
            watchScroll();
        }, 1000);
    }

    function detectionAltitude() {
        let scrollHeight = window.pageYOffset;

        if (scrollHeight > 60) {
            return true;
        } else {
            return false;
        }
    }

    function watchScroll() {
        if (detectionAltitude()) {
            $(".aside-panel").eq(0).addClass("sm-fixed");
            return;
        } else {
            $(".aside-panel").eq(0).removeClass("sm-fixed");
            return;
        }
    }

    function startCountDown() {
        let secondsRemaining = 30;

        CountInterval = setInterval(function () {
            let idRecClock = document.getElementById("idRecClock");

            //min = parseInt(secondsRemaining / 60);
            //sec = parseInt(secondsRemaining % 60);
            idRecClock.innerText = secondsRemaining;

            secondsRemaining = secondsRemaining - 1;
            if (secondsRemaining < 0) {
                secondsRemaining = 30;
                GetExchangeRateFromNomics(function () {
                    let amountText = document.getElementById("amount").value;

                    if (amountText) {
                        ReSetPaymentAmount(true, Number(amountText));
                    } else {
                        ReSetPaymentAmount(true);
                    }
                });
            };

        }, 1000);
    }

    function btn_NextStep() {
        var Step2 = $('[data-deposite="step2"]');
        var Step3 = $('[data-deposite="step3"]');
        var Step4 = $('[data-deposite="step4"]');


        Step3.hide();
        Step4.hide();

        $('button[data-deposite="step2"]').click(function () {
            window.parent.API_LoadingStart();
            //建立訂單/活動
            CreateCryptoDeposit();
            //$('button[data-deposite="step2"]').prop("disabled", "true");
        });
        $('button[data-deposite="step3"]').click(function () {
            window.parent.API_LoadingStart();
            //加入參加的活動
            setActivityNames();
            //$('button[data-deposite="step3"]').prop("disabled", "true");
        });
    }

    function copyText(tag) {
        var copyText = document.getElementById(tag);
        copyText.select();
        copyText.setSelectionRange(0, 99999);

        copyToClipboard(copyText.value)
            .then(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製成功")))
            .catch(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製失敗")));
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

    function copyTextPaymentSerial(tag) {

        var copyText = $(tag).parent().find('.inputPaymentSerial')[0];

        copyText.select();
        copyText.setSelectionRange(0, 99999);

        copyToClipboard(copyText.value)
            .then(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製成功")))
            .catch(() => window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("複製失敗")));
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

    function GetExchangeRateFromNomics(cb) {

        PaymentClient.GetExchangeRateFromNomics(WebInfo.SID, Math.uuid(), function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.Message != "") {
                        NomicsExchangeRate = JSON.parse(o.Message);
                        if (cb) {
                            cb();
                        }
                    } else {
                        window.parent.API_LoadingEnd();
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                        });
                    }
                } else {
                    window.parent.API_LoadingEnd();
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                    });
                }
            }
            else {
                window.parent.API_LoadingEnd();
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                });
            }
        })

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
            if (isResetRealRate) {
                let Rate = Number(dom.dataset.rate);
                let Currency = dom.dataset.currency;
                let HandingFeeRate = Number(dom.dataset.feerate);
                let RealExChange = GetRealExchange(Currency);
                realRate = 1 * Rate * (1 + HandingFeeRate) * RealExChange;
                dom.dataset.realrate = realRate.toString();
            } else {
                realRate = Number(dom.dataset.realrate);
            }

            if (Amount) {
                dom.innerText = new BigNumber((realRate * Amount).toFixed(6)).toFormat();
            } else {
                dom.innerText = 0;
            }
        });
    }

    function SetPaymentMethodDom() {
        let idPaymentMethod = document.getElementById('idPaymentMethods');
        idPaymentMethod.innerHTML = "";
        let strCryptoWalletType;

        for (var i = 0; i < PaymentMethod.length; i++) {

            if (PaymentMethod[i]["MultiCurrencyInfo"]) {
                if (!PaymentMethod[i]["MultiCurrencys"]) {
                    PaymentMethod[i]["MultiCurrencys"] = JSON.parse(PaymentMethod[i]["MultiCurrencyInfo"]);
                }
            }

            let PaymentMethodDom = c.getTemplate("templatePaymentMethod");
            let ItemsDom = PaymentMethodDom.querySelector(".amount");
            let EWinCryptoWalletType = parseInt(PaymentMethod[i]["EWinCryptoWalletType"]);

            switch (EWinCryptoWalletType) {
                case 0:
                    strCryptoWalletType = "ERC";
                    break;
                case 1:
                    strCryptoWalletType = "XRP";
                    break;
                case 2:
                    strCryptoWalletType = "BTC";
                    break;
                case 3:
                    strCryptoWalletType = "TRC";
                    break;
                default:
                    strCryptoWalletType = "ERC";
                    break;
            }

            PaymentMethodDom.classList.add("box_" + PaymentMethod[i]["PaymentCode"] + "_" + PaymentMethod[i]["EWinCryptoWalletType"]);
            PaymentMethodDom.querySelector(".PaymentCode").value = PaymentMethod[i]["PaymentMethodID"];
            PaymentMethodDom.querySelector(".PaymentCode").id = "payment-" + PaymentMethod[i]["PaymentCode"] + "_" + PaymentMethod[i]["EWinCryptoWalletType"];
            PaymentMethodDom.querySelector(".tab").setAttribute("for", "payment-" + PaymentMethod[i]["PaymentCode"] + "_" + PaymentMethod[i]["EWinCryptoWalletType"]);
            PaymentMethodDom.querySelector(".icon-logo").classList.add("icon-logo-" + PaymentMethod[i]["CurrencyType"].toLowerCase());
            c.setClassText(PaymentMethodDom, "coinType", null, PaymentMethod[i]["PaymentName"] + " (" + strCryptoWalletType + ")");

            if (PaymentMethod[i]["MultiCurrencys"]) {
                PaymentMethod[i]["MultiCurrencys"].forEach(function (mc) {
                    let item = document.createElement("div");
                    item.classList.add("item");
                    item.innerHTML = '<span class="count needReset" data-rate="' + mc["Rate"] + '" data-feerate="' + PaymentMethod[i]["HandingFeeRate"] + '" data-currency="' + mc["ShowCurrency"] + '">0</span><sup class="unit">' + mc["ShowCurrency"] + '</sup>';

                    ItemsDom.appendChild(item);
                });
            } else {
                let item = document.createElement("div");
                item.classList.add("item");
                item.innerHTML = '<span class="count needReset" data-rate="1" data-feerate="' + PaymentMethod[i]["HandingFeeRate"] + '"  data-currency="' + PaymentMethod[i]["CurrencyType"] + '">0</span><sup class="unit">' + PaymentMethod[i]["CurrencyType"] + '</sup>';

                ItemsDom.appendChild(item);
            }

            if (PaymentMethod[i]["HintText"]) {
                PaymentMethodDom.querySelector('.hintText').innerText = PaymentMethod[i]["HintText"];
            } else {
                PaymentMethodDom.querySelector('.box-item-sub').classList.add("is-hide");
            }

            idPaymentMethod.appendChild(PaymentMethodDom);
        }
    }

    function GetPaymentMethod() {
        PaymentClient.GetPaymentMethodByCategory(WebInfo.SID, Math.uuid(), "Crypto", 0, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.PaymentMethodResults.length > 0) {
                        PaymentMethod = o.PaymentMethodResults;

                        GetExchangeRateFromNomics(function () {
                            SetPaymentMethodDom();
                            ReSetPaymentAmount(true);
                        });
                    } else {
                        window.parent.API_LoadingEnd(1);
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                            window.location.href = "index.aspx"
                        });
                    }
                } else {
                    window.parent.API_LoadingEnd(1);
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                        window.location.href = "index.aspx"
                    });
                }
            }
            else {
                window.parent.API_LoadingEnd(1);
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("服務器異常, 請稍後再嘗試一次"), function () {
                    window.location.href = "index.aspx"
                });
            }

        })
    }

    function setRealExchange() {
        if (PaymentMethod.length > 0 && NomicsExchangeRate.length > 0) {
            let price;
            for (var i = 0; i < PaymentMethod.length; i++) {
                PaymentMethod[i]["RealExchange"] = 0;

                if (PaymentMethod[i]["MultiCurrencyInfo"]) {
                    if (!PaymentMethod[i]["MultiCurrencys"]) {
                        PaymentMethod[i]["MultiCurrencys"] = JSON.parse(PaymentMethod[i]["MultiCurrencyInfo"]);
                    }

                    PaymentMethod[i]["MultiCurrencys"].forEach(function (mc) {
                        mc["RealExchange"] = GetRealExchange(mc["ShowCurrency"]);
                    });
                } else {
                    PaymentMethod[i]["RealExchange"] = GetRealExchange(mc["CurrencyType"]);
                }
            }
        }
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
    //建立可選活動
    function setActivity(ActivityTitle, ActivitySubTitle, ActivityName, ThresholdValue, BonusValue) {
        var ParentActivity = document.getElementsByClassName("ActivityMain")[0];
        var ActivityCount = ParentActivity.children.length + 1;

        var ActivityDom = c.getTemplate("templateActivity");
        c.setClassText(ActivityDom, "ActivityTitle", null, ActivityTitle);
        c.setClassText(ActivityDom, "ActivitySubTitle", null, ActivitySubTitle);
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-checked", "true");
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-ActivityName", ActivityName);
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-thresholdvalue", ThresholdValue);
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-bonusvalue", BonusValue);
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].id = "award-bonus" + ActivityCount;
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("checked", "true");
        ActivityDom.getElementsByClassName("custom-control-label")[0].setAttribute("for", "award-bonus" + ActivityCount);

        $(".ThresholdValue").text(FormatNumber(ReFormatNumber($(".ThresholdValue").text()) + ThresholdValue));
        $("#idBonusValue").text(FormatNumber(ReFormatNumber($("#idBonusValue").text()) + BonusValue));
        $("#idTotalReceiveValue").text(FormatNumber(ReFormatNumber($("#idTotalReceiveValue").text()) + BonusValue));

        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].addEventListener("change", function (e) {
            let THV = $(e.target).data("thresholdvalue");
            let BV = $(e.target).data("bonusvalue");
            let activityname = $(e.target).data("activityname");

            if ($(e.target).data("checked")) {
                //取消參加活動
                $(e.target).data("checked", false);
                $(".ThresholdValue").text(FormatNumber(ReFormatNumber($(".ThresholdValue").text()) - THV));
                $("#idBonusValue").text(FormatNumber(ReFormatNumber($("#idBonusValue").text()) - BV));
                $("#idTotalReceiveValue").text(FormatNumber(ReFormatNumber($("#idTotalReceiveValue").text()) - BV));
            } else {
                //參加活動
                $(e.target).data("checked", true);
                $(".ThresholdValue").text(FormatNumber(ReFormatNumber($(".ThresholdValue").text()) + THV));
                $("#idBonusValue").text(FormatNumber(ReFormatNumber($("#idBonusValue").text()) + BV));
                $("#idTotalReceiveValue").text(FormatNumber(ReFormatNumber($("#idTotalReceiveValue").text()) + BV));
            }
        });
        ParentActivity.appendChild(ActivityDom);
    }

    function ReFormatNumber(x) {
        return Number(x.toString().replace(/,/g, ''));
    }

    function FormatNumber(x) {
        return new BigNumber(x).toFormat();
    }
    var fff;
    //建立訂單
    function CreateCryptoDeposit() {
        if ($("#amount").val() != '') {
            var amount = parseFloat($("#amount").val());
            var selePaymentMethodID = $("input[name=payment-crypto]:checked.PaymentCode").val();
            //var paymentID = PaymentMethod.find(x => x["PaymentName"].trim() == selePaymentName).PaymentMethodID;

            if (selePaymentMethodID) {
                var paymentID = selePaymentMethodID;

                PaymentClient.GetInProgressPaymentByLoginAccountPaymentMethodID(WebInfo.SID, Math.uuid(), WebInfo.UserInfo.LoginAccount, 0, paymentID, function (success, o) {
                    if (success) {
                        let UserAccountPayments = o.UserAccountPayments;
                        if (o.Result == 0) {
                            if (UserAccountPayments.length > 0) {

                                fff = o.UserAccountPayments[0];
                                showProgressOrder(o.UserAccountPayments[0]);

                                window.parent.API_LoadingEnd();
                                //window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("一個支付方式，只能有一筆進行中之訂單"), function () {

                                //});
                            } else {
                                PaymentClient.CreateCryptoDeposit(WebInfo.SID, Math.uuid(), amount, paymentID, function (success, o) {
                                    if (success) {
                                        let data = o.Data;

                                        if (o.Result == 0) {
                                            $("#depositdetail .Amount").text(new BigNumber(data.Amount).toFormat());
                                            $("#depositdetail .TotalAmount").text(new BigNumber(data.Amount).toFormat());
                                            $("#depositdetail .OrderNumber").text(data.OrderNumber);
                                            $("#depositdetail .PaymentMethodName").text(data.PaymentMethodName);
                                            $("#depositdetail .ThresholdValue").text(new BigNumber(data.ThresholdValue).toFormat());
                                            ExpireSecond = data.ExpireSecond;
                                            if (data.PaymentCryptoDetailList != null) {
                                                var depositdetail = document.getElementsByClassName("Collectionitem")[0];
                                                for (var i = 0; i < data.PaymentCryptoDetailList.length; i++) {

                                                    var CollectionitemDom = c.getTemplate("templateCollectionitem");
                                                    CollectionitemDom.querySelector(".icon-logo").classList.add("icon-logo-" + data.PaymentCryptoDetailList[i]["TokenCurrencyType"].toLowerCase());
                                                    c.setClassText(CollectionitemDom, "currency", null, data.PaymentCryptoDetailList[i]["TokenCurrencyType"]);
                                                    c.setClassText(CollectionitemDom, "val", null, new BigNumber(data.PaymentCryptoDetailList[i]["ReceiveAmount"]).toFormat());
                                                    depositdetail.appendChild(CollectionitemDom);
                                                }
                                            }
                                            OrderNumber = data.OrderNumber;
                                            GetDepositActivityInfoByOrderNumber(OrderNumber);
                                        } else {
                                            window.parent.API_LoadingEnd();
                                            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                                            });
                                        }

                                    }
                                    else {
                                        window.parent.API_LoadingEnd(1);
                                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("訂單建立失敗"), function () {

                                        });
                                    }
                                })
                            }
                        } else {
                            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                            });
                        }

                    }
                    else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("訂單建立失敗"), function () {

                        });
                    }
                })

            } else {
                window.parent.API_LoadingEnd(1);
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請選擇加密貨幣"))
            }
        } else {
            window.parent.API_LoadingEnd(1);
            window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入購買金額"), function () {

            });
        }
    }
    //根據訂單編號取得可參加活動
    function GetDepositActivityInfoByOrderNumber(OrderNum) {
        PaymentClient.GetDepositActivityInfoByOrderNumber(WebInfo.SID, Math.uuid(), OrderNum, function (success, o) {
            if (success) {
                if (o.DataList != null) {
                    if (o.DataList.length > 0) {
                        var ThresholdValue = 0
                        for (var i = 0; i < o.DataList.length; i++) {
                            setActivity(o.DataList[i]["Title"], o.DataList[i]["SubTitle"], o.DataList[i]["ActivityName"], o.DataList[i]["ThresholdValue"], o.DataList[i]["BonusValue"]);
                        }
                    }
                }
                clearInterval(CountInterval);
                var Step2 = $('[data-deposite="step2"]');
                var Step3 = $('[data-deposite="step3"]');
                Step2.hide();
                Step3.fadeIn();
                $('.progress-step:nth-child(3)').addClass('cur');
                window.parent.API_LoadingEnd(1);
            }
            else {
                window.parent.API_LoadingEnd(1);
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("取得可參加活動失敗"), function () {

                });
            }
        })
    }
    //完成訂單
    function ConfirmCryptoDeposit() {
        PaymentClient.ConfirmCryptoDeposit(WebInfo.SID, Math.uuid(), OrderNumber, ActivityNames, function (success, o) {
            window.parent.API_LoadingEnd(1);
            if (success) {
                if (o.Result == 0) {
                    let k;
                    if (o.Message != "") {
                        k = JSON.parse(o.Message);
                    }
                    setEthWalletAddress(k.WalletPublicAddress);
                    $(".OrderNumber").text(k.PaymentSerial);
                    $("#depositdetail .inputPaymentSerial").val(k.PaymentSerial);
                    $(".OrderNumber").parent().show();
                    setExpireSecond();
                    let Step3 = $('button[data-deposite="step3"]');
                    let Step4 = $('[data-deposite="step4"]');
                    Step3.hide();
                    $(".activity-container").hide();
                    Step4.fadeIn();
                    $('.progress-step:nth-child(4)').addClass('cur');
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("次へ進めて頂くと送金用QRコード（ウォレットアドレス）が生成されます、QRコードはこの取引のみの使用となります。QRコードの有効時間は1時間となりますが、送金の際は常に新しいQRコードの生成をお勧めします。"), function () {

                    });
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("無可用錢包"), function () {

                    });
                }
            }
            else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message), function () {

                });
            }
        })
    }

    function setActivityNames() {
        ActivityNames = [];
        for (var i = 0; i < $(".ActivityMain .ActivityCheckBox").length; i++) {
            if ($(".ActivityMain .ActivityCheckBox").eq(i).data("checked")) {
                ActivityNames.push($(".ActivityMain .ActivityCheckBox").eq(i).data("activityname"));
            }
        }
        ConfirmCryptoDeposit();
    }

    function setEthWalletAddress(EthAddress) {
        $('#idEthAddr').text(EthAddress);
        $('#idEthAddrInput').val(EthAddress);
        $('#cryptoimg').attr("src", `/GetQRCode.aspx?QRCode=${EthAddress}&Download=2`);
    }

    function setExpireSecond() {
        var nowDate = new Date();
        nowDate.addSeconds(ExpireSecond);
        nowDate.addHours(1);
        $(".ExpireSecond").text(format(nowDate, "-"));
        $(".ExpireSecond").parent().show();
    }

    function format(Date, str) {
        var obj = {
            Y: Date.getFullYear(),
            M: Date.getMonth() + 1,
            D: Date.getDate(),
            H: Date.getHours(),
            Mi: Date.getMinutes(),
            S: Date.getSeconds()
        }
        // 拼接时间 hh:mm:ss
        var time = ' ' + supplement(obj.H) + ':' + supplement(obj.Mi) + ':' + supplement(obj.S);
        // yyyy-mm-dd
        if (str.indexOf('-') > -1) {
            return obj.Y + '-' + supplement(obj.M) + '-' + supplement(obj.D) + time;
        }
        // yyyy/mm/dd
        if (str.indexOf('/') > -1) {
            return obj.Y + '/' + supplement(obj.M) + '/' + supplement(obj.D) + time;
        }
    }

    function supplement(nn) {
        return nn = nn < 10 ? '0' + nn : nn;
    }

    function showProgressOrder(data) {
        let divMessageBox = document.getElementById("divProgressOrder");
        let divMessageBoxCloseButton = divMessageBox.querySelector(".alertContact_Close");
        let divMessageBoxOKButton = divMessageBox.querySelector(".alertContact_OK");
        let divMessageBoxCloseButton1 = divMessageBox.querySelector(".close");
        let divMessageBoxPaymentSerial = divMessageBox.querySelector(".PaymentSerial");
        let divMessageBoxExpireSecond = divMessageBox.querySelector(".ExpireSecond");
        let divMessageBoxAmount = divMessageBox.querySelector(".Amount");
        let divMessageBoxBonusValue = divMessageBox.querySelector(".BonusValue");
        let divMessageBoxTotalAmount = divMessageBox.querySelector(".TotalAmount");
        let divMessageBoxcryptocontent = divMessageBox.querySelector(".crypto-content");

        let modal = new bootstrap.Modal(divMessageBox);

        if (divMessageBox != null) {
            if (divMessageBoxCloseButton != null) {
                divMessageBoxCloseButton.onclick = function () {
                    modal.hide();
                }
            }
            if (divMessageBoxCloseButton1 != null) {
                divMessageBoxCloseButton1.onclick = function () {
                    modal.hide();
                }
            }
            if (divMessageBoxOKButton != null) {
                divMessageBoxOKButton.onclick = function () {
                    modal.hide();
                    window.parent.API_LoadPage('DepositDetail', 'DepositDetail.aspx?PS=' + data.PaymentSerial, true);
                }
            }

            divMessageBoxPaymentSerial.innerHTML = data.PaymentSerial;
            divMessageBoxAmount.innerHTML = FormatNumber(data.Amount);

            if (data.ActivityData != "") {
                let JsonActivityData = JSON.parse(data.ActivityData);
                let bonusVal = 0;
                if (JsonActivityData&&JsonActivityData.length > 0) {
                    for (var i = 0; i < JsonActivityData.length; i++) {
                        bonusVal += JsonActivityData[i].BonusValue;
                    }

                    divMessageBoxBonusValue.innerHTML = FormatNumber(bonusVal).toString();
                    divMessageBoxTotalAmount.innerHTML = FormatNumber(data.Amount + bonusVal).toString();

                }
            }

            if (data.DetailData != "") {
                let JsonDetailData = JSON.parse(data.DetailData);
                for (var i = 0; i < JsonDetailData.length; i++) {

                    var CollectionitemDom = c.getTemplate("templateProgressOrderCurrency");
                    CollectionitemDom.querySelector(".icon-logo").classList.add("icon-logo-" + JsonDetailData[i]["TokenCurrencyType"].toLowerCase());
                    c.setClassText(CollectionitemDom, "name", null, JsonDetailData[i]["TokenCurrencyType"]);
                    c.setClassText(CollectionitemDom, "count", null, new BigNumber(JsonDetailData[i]["ReceiveAmount"]).toFormat());
                    divMessageBoxcryptocontent.appendChild(CollectionitemDom);
                }
            }

            let nowDate = new Date(data.CreateDate1);
            nowDate.addSeconds(data.ExpireSecond);
            nowDate.addHours(1);
            divMessageBoxExpireSecond.innerHTML = format(nowDate, "/");

            modal.toggle();
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
                    <div class="progress-step cur">
                        <div class="progress-step-item"></div>
                    </div>
                    <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                    <div class="progress-step">
                        <div class="progress-step-item"></div>
                    </div>
                </div>
                <div class="text-wrap progress-title" style="display: none">
                    <p data-deposite="step2">輸入存款金額及選擇加密貨幣</p>
                    <p data-deposite="step3" class="language_replace">入金確認</p>
                    <p data-deposite="step4" class="language_replace">
                        <span class="language_replace">使用</span>
                        <span class="language_replace">USDT</span>
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
                                    <div class="amount-info-title language_replace">本次存款 (USD)</div>
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
                            <!-- 存款提示 -->
                            <div class="form-group text-wrap desc mt-2 mt-md-4">
                                <!-- <h5 class="language_replace">便捷金額存款</h5> -->
                                <p class="text-s language_replace">請從下方金額選擇您要的金額，或是自行填入想要存款的金額。兩種方式擇一即可。</p>
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

                                <!-- 輸入金額(美元) -->
                                <div class="form-group language_replace">
                                    <label class="form-title language_replace">輸入金額</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control custom-style" id="amount" language_replace="placeholder" placeholder="請輸入金額" onkeyup="setAmount()" />
                                        <div class="form-notice-aside unit MainCurrencyType" id="OrderCurrencyType"></div>
                                        <div class="invalid-feedback language_replace">提示</div>
                                    </div>
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
                    <div class="main-panel cryptopanel" data-deposite="step2">
                        <h5 class="language_replace">選擇加密貨幣</h5>
                        <div>
                            <span id="idRecClock">30</span><span class="language_replace">秒後，重新取得匯率</span>
                        </div>
                        <div class="box-item-container crypto-list">
                            <div id="idPaymentMethods">
                            </div>

                            <!-- 溫馨提醒 -->
                            <div class="notice-container mt-3 mb-3">
                                <div class="notice-item">
                                    <i class="icon-info_circle_outline"></i>
                                    <div class="text-wrap">
                                        <p class="title language_replace">溫馨提醒</p>
                                        <p class="language_replace">匯率波動以交易所為主，匯率可能不定時更新。</p>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

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
                        <!-- 存款獎勵 -->
                        <div class="text-wrap award-content">
                            <h6 class="language_replace">這次存款可獲得的獎勵</h6>
                            <ul class="award-list ActivityMain">
                            </ul>
                        </div>
                    </div>--%>
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

                            <h4 class="mt-2 mt-md-4 cryoto-address language_replace">錢包地址</h4>
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
                                        <p class="currency ExchangeRateOut"><span class="amount">100</span><span class="unit MainCurrencyType">Ocoin</span></p>
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

                    <!-- 虛擬錢包 step3 - 入金確認頁-->
                    <div class="deposit-confirm " data-deposite="step3" id="depositdetail">
                        <div class="aside-panel">
                            <div class="deposit-calc">
                                <div class="deposit-crypto">
                                    <h5 class="subject-title language_replace">收款項目</h5>
                                    <ul class="deposit-crypto-list Collectionitem">
                                    </ul>
                                </div>
                                <div class="deposit-total">
                                    <div class="item subtotal">
                                        <div class="title">
                                            <h5 class="name language_replace">存款金額</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name MainCurrencyType"></span>
                                            <span class="count Amount"></span>
                                        </div>
                                    </div>
                                    <div class="item subtotal" style="display: none;">
                                        <div class="title">
                                            <h5 class="name language_replace">活動獎勵</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name MainCurrencyType"></span>
                                            <span class="count" id="idBonusValue">0</span>
                                        </div>
                                    </div>
                                    <div class="item total">
                                        <div class="title">
                                            <h5 class="name language_replace">可得總額</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name MainCurrencyType"></span>
                                            <span class="count TotalAmount" id="idTotalReceiveValue"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="main-panel">
                            <div class="deposit-list">
                                <h5 class="subject-title language_replace">存款細項</h5>
                                <ul class="deposit-detail">
                                    <li class="item" style="display: none">
                                        <h6 class="title language_replace">訂單號碼</h6>
                                        <span class="data OrderNumber"></span>
                                        <input class="inputPaymentSerial is-hide" />
                                        <i class="icon-copy" onclick="copyTextPaymentSerial(this)" style="display: inline;"></i>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">支付方式</h6>
                                        <span class="data PaymentMethodName"></span>
                                    </li>
                                    <%-- <li class="item">
                                        <h6 class="title language_replace">合約方式</h6><span class="data">ERC</span>
                                    </li>--%>
                                    <li class="item " style="display: none">
                                        <h6 class="title language_replace">交易限制時間</h6>
                                        <span class="data text-primary ExpireSecond"></span>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">出金條件</h6>
                                        <span class="data ThresholdValue"></span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <div class="activity-container" style="display: none;">
                            <div class="activity-inner">
                                <h5 class="subject-title language_replace">熱門活動</h5>
                                <!-- 存款獎勵 -->
                                <div class="text-wrap award-content">
                                    <ul class="deposit-award-list ActivityMain">
                                    </ul>
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
                    <%--    <button class="btn btn-outline-primary" data-deposite="step4" href="index.aspx">
                        <span class="language_replace">首頁</span>
                    </button>
                  <button class="btn btn-primary" data-deposite="step4" data-toggle="modal" data-target="#depositSucc">
                        <span>確認</span>
                    </button>--%>
                </div>

                <!-- 溫馨提醒 -->
                <div class="notice-container" data-deposite="step4">
                    <div class="notice-item">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <p class="title language_replace">溫馨提醒</p>
                            <ul class="list-style-decimal">
                                <li><span class="language_replace">請正確使用對應的錢包入款，否則可能造成您入款失敗。</span></li>
                                <li><span class="language_replace">虛擬貨幣入款需經過區塊認證確認，可能需要數分鐘或者更久，完成時間並非由本網站決定，敬請知悉。</span></li>
                                <li><span class="language_replace">實際入款遊戲幣為入款金額-手續費後之餘額進行換算。</span></li>
                                <li><span class="language_replace">匯率可能隨時變動中，所有交易以本網站的匯率為準，打幣後交易期間若有變動，將以實際入幣時的匯率撥給遊戲幣。建議您可於入款前重整匯率資訊，確保您同意目前的匯率後進行入款。</span></li>
                                <li><span class="language_replace">『ETH』和USDT的『ERC20』可透過 https://etherscan.io/ 進行查詢交易的狀況。</span></li>
                            </ul>
                            <ul class="list-style-decimal">
                                <li><span class="language_replace">請正確使用對應的錢包入款，否則將造成資產損失。</span><br>
                                    <span class="primary language_replace">※ETH請勿使用ERC20以外的協定。</span></li>
                                <li class="language_replace">虛擬貨幣入賬需經過數個區塊確認，約需要數分鐘時間。</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <!-- Modal 已存在 "進行中訂單" 提醒-->
    <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true" id="divProgressOrder">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header border-bottom align-items-center">
                    <i class="icon-info_circle_outline"></i>
                    <h5 class="modal-title language_replace ml-1">已存在進行中訂單</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true"><i class="icon-close-small"></i></span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="modal-body-content">
                        <div class="deposit-list processing">
                            <ul class="deposit-detail">
                                <li class="item">
                                    <h6 class="title language_replace">訂單號碼</h6>
                                    <span class="data PaymentSerial"></span>
                                </li>
                                <li class="item">
                                    <h6 class="title language_replace">交易限制時間</h6>
                                    <span class="data text-primary ExpireSecond"></span>
                                </li>
                            </ul>
                            <div class="deposit-total">
                                <div class="item crypto-list">
                                    <div class="title">
                                        <h6 class="name language_replace">收款項目</h6>
                                    </div>
                                    <div class="data">
                                        <div class="crypto-content">
                                              
                                        </div>
                                    </div>
                                </div>
                                <div class="item ">
                                    <div class="title">
                                        <h6 class="name language_replace">存款金額</h6>
                                    </div>
                                    <div class="data">
                                        <span class="count Amount"></span>
                                        <span class="name coin">
                                            <img src="images/assets/coin-Ocoin.png" alt=""></span>
                                    </div>
                                </div>
                                <div class="item " style="display: none;">
                                    <div class="title">
                                        <h6 class="name language_replace">活動獎勵</h6>
                                    </div>
                                    <div class="data">
                                        <span class="count BonusValue"></span>
                                        <span class="name coin">
                                            <img src="images/assets/coin-Ocoin.png" alt=""></span>
                                    </div>
                                </div>
                                <div class="item total">
                                    <div class="title">
                                        <h6 class="name language_replace">可得總額</h6>
                                    </div>
                                    <div class="data">
                                        <span class="count TotalAmount"></span>
                                        <span class="name coin">
                                            <img src="images/assets/coin-Ocoin.png" alt=""></span>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="modal-footer justify-content-center">
                    <div class="btn-container">
                        <button type="button" class="alertContact_Close btn btn-outline-primary btn-sm" data-dismiss="modal"><span class="language_replace">取消</span></button>
                        <button type="button" class="alertContact_OK btn btn-primary btn-sm" data-dismiss="modal"><span class="language_replace">查看進行中訂單</span></button>
                    </div>
                </div>
            </div>
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
                            <h6 class="language_replace">存款成功 !</h6>
                            <p class="language_replace">您可進入遊戲確認您本次的入金，以及對應的 Bouns 獎勵。</p>
                        </div>
                    </div>
                    <div class="modal-body-content">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <h6 class="language_replace">溫馨提醒</h6>
                            <p class="language_replace">不同的存款管道可能影響存款金額到達玩家錢包的時間。最遲一個營業日為合理的範圍。</p>
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

    <div id="templateProgressOrderCurrency" style="display: none">
        <div class="item">
            <div class="title">
                <i class="icon-logo round"></i>
                <h6 class="name"></h6>
            </div>
            <span class="count"></span>
        </div>
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
