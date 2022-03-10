<%@ Page Language="C#" %>

<%
    string Version = EWinWeb.Version;
%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
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
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/libphonenumber.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/DateExtension.js"></script>
<script src="Scripts/OutSrc/js/wallet.js"></script>
<script>
    var WebInfo;
    var mlp;
    var lang;
    var c = new common();
    var v ="<%:Version%>";
    var PaymentClient;
    var ActivityNames = [];
    var ExpireSecond = 0;

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        WebInfo = window.parent.API_GetWebInfo();
        lang = window.parent.API_GetLang();
        PaymentClient = window.parent.API_GetPaymentAPI();
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();
        },"PaymentAPI");
        btn_NextStep();

        //Date.prototype.addSecs = function (s) {
        //    this.setTime(this.getTime() + (s * 1000));
        //    return this;
        //}

        GetPaymentMethod();
    }

    function CoinBtn_Click() {
        var seleAmount = parseInt($(event.target).parent('.btn-radio').find('.OcoinAmount').text());
        let RangeRate = 0;
        $("#amount").val(seleAmount);

        for (var i = 0; i < PaymentMethod[0].ExtraData.length; i++) {
            let RangeMinValuie = PaymentMethod[0].ExtraData[i].RangeMinValuie;
            let RangeMaxValuie = PaymentMethod[0].ExtraData[i].RangeMaxValuie;
            if (RangeMaxValuie != 0) {
                if (RangeMinValuie <= seleAmount && seleAmount < RangeMaxValuie) {
                    RangeRate = PaymentMethod[0].ExtraData[i].RangeRate;
                    break;
                }
            } else {
                if (RangeMinValuie <= seleAmount) {
                    RangeRate = PaymentMethod[0].ExtraData[i].RangeRate;
                    break;
                }
            }
        }

        $("#ExchangeVal").text(new BigNumber(seleAmount * (1 + RangeRate)).toFormat());
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

    function setAmount() {
        $("input[name=amount]").prop("checked", false);
        var amount = $("#amount").val().replace(/[^\-?\d.]/g, '');
        $("#amount").val(amount);

        for (var i = 0; i < PaymentMethod[0].ExtraData.length; i++) {
            let RangeMinValuie = PaymentMethod[0].ExtraData[i].RangeMinValuie;
            let RangeMaxValuie = PaymentMethod[0].ExtraData[i].RangeMaxValuie;
            if (RangeMaxValuie != 0) {
                if (RangeMinValuie <= amount && amount < RangeMaxValuie) {
                    RangeRate = PaymentMethod[0].ExtraData[i].RangeRate;
                    break;
                }
            } else {
                if (RangeMinValuie <= amount) {
                    RangeRate = PaymentMethod[0].ExtraData[i].RangeRate;
                    break;
                }
            }
        }

        $("#ExchangeVal").text(Math.ceil(amount * (1 + RangeRate)));
    }

    function btn_NextStep() {
        var Step3 = $('[data-deposite="step3"]');

        Step3.hide();

        $('button[data-deposite="step2"]').click(function () {
            window.parent.API_LoadingStart();
            //建立訂單/活動
            CreatePayPalDeposit();
        });
        $('button[data-deposite="step3"]').click(function () {
            window.parent.API_LoadingStart();
            //加入參加的活動
            setActivityNames();
        });
    }

    function GetPaymentMethod() {
        PaymentClient.GetPaymentMethodByCategory(WebInfo.SID, Math.uuid(), "Paypal", 0, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.PaymentMethodResults.length > 0) {
                        PaymentMethod = o.PaymentMethodResults;
                        for (var i = 0; i < PaymentMethod.length; i++) {
                            if (PaymentMethod[i]["ExtraData"]) {
                                PaymentMethod[i]["ExtraData"] = JSON.parse(PaymentMethod[i]["ExtraData"]);
                            }
                        }
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                            window.location.href = "index.aspx"
                        });
                    }
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                        window.location.href = "index.aspx"
                    });
                }
            }
            else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("服務器異常, 請稍後再嘗試一次"), function () {
                    window.location.href = "index.aspx"
                });
            }

        })
    }

    //建立訂單
    function CreatePayPalDeposit() {
        if ($("#amount").val() != '') {
            var amount = parseFloat($("#amount").val());
            var paymentID = PaymentMethod[0]["PaymentMethodID"];
            PaymentClient.CreatePayPalDeposit(WebInfo.SID, Math.uuid(), amount, paymentID, function (success, o) {
                if (success) {
                    let data = o.Data;
                    if (o.Result == 0) {
                        $("#depositdetail .Amount").text(new BigNumber(data.Amount).toFormat());
                        $("#depositdetail .TotalAmount").text(new BigNumber(data.Amount).toFormat());
                        $("#depositdetail .OrderNumber").text(data.OrderNumber);
                        $("#depositdetail .PaymentMethodName").text(data.PaymentMethodName);
                        $("#depositdetail .ThresholdValue").text(new BigNumber(data.ThresholdValue).toFormat());
                        ExpireSecond = data.ExpireSecond;

                        var depositdetail = document.getElementsByClassName("Collectionitem")[0];
                        var CollectionitemDom = c.getTemplate("templateCollectionitem");
                        c.setClassText(CollectionitemDom, "currency", null, data.ReceiveCurrencyType);
                        c.setClassText(CollectionitemDom, "val", null, new BigNumber(data.ReceiveTotalAmount).toFormat());
                        depositdetail.appendChild(CollectionitemDom);

                        OrderNumber = data.OrderNumber;
                        GetDepositActivityInfoByOrderNumber(OrderNumber);
                    } else {
                        window.parent.API_LoadingEnd(1);
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

    //建立可選活動
    function setActivity(ActivityTitle, ActivitySubTitle, ActivityName, ThresholdValue, BonusValue) {
        var ParentActivity = document.getElementsByClassName("ActivityMain")[0];
        var ActivityCount = ParentActivity.children.length + 1;

        var ActivityDom = c.getTemplate("templateActivity");
        c.setClassText(ActivityDom, "ActivityTitle", null, ActivityTitle);
        c.setClassText(ActivityDom, "ActivitySubTitle", null, ActivitySubTitle);
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-checked", "true");
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-ActivityName", ActivityName);
        ActivityDom.getElementsByClassName("ActivityCheckBox")[0].setAttribute("data-ThresholdValue", ThresholdValue);
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

    function setActivityNames() {
        ActivityNames = [];
        for (var i = 0; i < $(".ActivityMain .ActivityCheckBox").length; i++) {
            if ($(".ActivityMain .ActivityCheckBox").eq(i).data("checked")) {
                ActivityNames.push($(".ActivityMain .ActivityCheckBox").eq(i).data("activityname"));
            }
        }
        ConfirmPayPalDeposit();
    }

    function ConfirmPayPalDeposit() {
        PaymentClient.ConfirmPayPalDeposit(WebInfo.SID, Math.uuid(), OrderNumber, ActivityNames, lang, function (success, o) {
            window.parent.API_LoadingEnd(1);
            if (success) {
                if (o.Result == 0) {
                    window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("前往付款"), function () {
                        window.open("/OpenPayPal.aspx?Url=" + o.Message, "_blank");
                    });

                    setExpireSecond();
                    let Step3 = $('button[data-deposite="step3"]');
                    //let Step4 = $('[data-deposite="step4"]');
                    Step3.hide();
                    $(".activity-container").hide();
                    //Step4.fadeIn();
                    $("#depositdetail").show();
                    $('.progress-step:nth-child(4)').addClass('cur');
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"),mlp.getLanguageKey(o.Message) , function () {

                    });
                }
            }
            else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"),mlp.getLanguageKey("服務器異常, 請稍後再嘗試一次"), function () {

                });
            }
        })
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

                <div class="progress-title text-wrap">
                    <p data-deposite="step2" class="language_replace">輸入存款金額</p>
                    <!--<p data-deposite="step3" class="language_replace" style="display: none">完成</p>
                     <p data-deposite="step4">支付</p> -->
                </div>

                <div class="split-layout-container">
                    <div class="aside-panel" data-deposite="step2">
                        <!-- PayPal -->
                        <div class="card-item sd-08">
                            <div class="card-item-link">
                                <div class="card-item-inner">
                                    <div class="title">
                                        <span class="language_replace">電子錢包</span>
                                        <!-- <span>Electronic Wallet</span>  -->
                                    </div>
                                    <div class="logo vertical-center">
                                        <img src="images/assets/card-surface/icon-logo-paypal-w.svg" />
                                    </div>
                                </div>
                                <img src="images/assets/card-surface/card-08.svg" class="card-item-bg" />
                            </div>
                        </div>
                        <div class="text-wrap payment-change" style="display: none">
                            <a href="deposit.html" class="text-link c-blk">
                                <i class="icon-transfer"></i>
                                <span class="language_replace">切換</span>
                            </a>
                        </div>
                        <div class="form-content">
                            <!-- 存款提示 -->
                            <div class="form-group text-wrap desc mt-2 mt-md-4">
                                <!-- <h5 class="language_replace">便捷金額存款</h5> -->
                                <p class="text-s language_replace">請從下方金額選擇您要的金額，或是自行填入想要存款的金額。兩種方式擇一即可。</p>
                            </div>
                            <form>
                                <div class="form-group">
                                    <div class="btn-wrap btn-radio-wrap btn-radio-payment">
                                        <div class="btn-radio btn-radio-coinType" onclick="CoinBtn_Click()">
                                            <input type="radio" name="amount" id="amount1" />
                                            <label class="btn btn-outline-primary" for="amount1">
                                                <span class="coinType gameCoin">
                                                    <%-- <span class="coinType-title language_replace">遊戲幣</span>--%>
                                                    <span class="coinType-title">Ocoin</span>
                                                    <span class="coinType-amount OcoinAmount">10000</span>
                                                </span>
                                            </label>
                                        </div>

                                        <div class="btn-radio btn-radio-coinType" onclick="CoinBtn_Click()">
                                            <input type="radio" name="amount" id="amount2" />
                                            <label class="btn btn-outline-primary" for="amount2">
                                                <span class="coinType gameCoin">
                                                    <span class="coinType-name">Ocoin</span>
                                                    <span class="coinType-amount OcoinAmount">20000</span>
                                                </span>
                                            </label>
                                        </div>

                                        <div class="btn-radio btn-radio-coinType" onclick="CoinBtn_Click()">
                                            <input type="radio" name="amount" id="amount3" />
                                            <label class="btn btn-outline-primary" for="amount3">
                                                <span class="coinType gameCoin">
                                                    <%--<span class="coinType-title language_replace">遊戲幣</span>--%>
                                                    <span class="coinType-name">Ocoin</span>
                                                    <span class="coinType-amount OcoinAmount">50000</span>
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
                                        <div class="form-notice-aside unit" id="OrderCurrencyType">Ocoin</div>
                                        <div class="invalid-feedback language_replace">提示</div>
                                    </div>
                                </div>
                                <!-- 換算金額(日元) -->
                                <div class="form-group ">
                                    <div class="input-group inputlike-box-group">
                                        <span class="inputlike-box-prepend">≒</span>
                                        <!-- 換算金額(日元)-->
                                        <!-- 兌換後加入 class =>exchanged-->
                                        <%--<span class="inputlike-box "><span ></span></span>--%>
                                        <span class="inputlike-box-append">
                                            <span class="inputlike-box-append-title" id="ExchangeVal"></span>
                                            <span class="inputlike-box-append-unit">JPY</span>
                                        </span>
                                    </div>
                                </div>

                            </form>
                        </div>
                    </div>
                    <!-- 虛擬錢包 step4 -->
                    <div class="main-panel" data-deposite="step4">

                        <div class="crypto-info-coantainer">

                            <h4 class="mt-2 mt-md-4 cryoto-address language_replace">請盡速完成交易</h4>

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
                                            <h5 class="name language_replace">存入金額</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name PaymentCode">OCoin</span>
                                            <span class="count Amount"></span>
                                        </div>
                                    </div>
                                    <div class="item subtotal">
                                        <div class="title">
                                            <h5 class="name language_replace">活動獎勵</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name">OCoin</span>
                                            <span class="count" id="idBonusValue">0</span>
                                        </div>
                                    </div>
                                    <div class="item total">
                                        <div class="title">
                                            <h5 class="name language_replace">可得總額</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name">OCoin</span>
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
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">支付方式</h6>
                                        <span class="data PaymentMethodName"></span>
                                    </li>

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
                        <div class="activity-container">
                            <div class="activity-item">
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

                <div class="btn-container">
                    <button class="btn btn-primary" data-deposite="step2">
                        <span class="language_replace">下一步</span>
                    </button>
                    <button class="btn btn-primary" data-deposite="step3">
                        <span class="language_replace">下一步</span>
                    </button>
                    <%--<button class="btn btn-outline-primary" data-deposite="step4" onclick="goBack()" style="display: none">
                        <span class="language_replace">取消</span>
                    </button>--%>
                </div>

                <!-- 溫馨提醒 -->
                <div class="notice-container" data-deposite="step4">
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

    <div id="templateCollectionitem" style="display: none">
        <li class="item">
            <div class="title">
                <h6 class="name currency"></h6>
            </div>
            <span class="data val"></span>
        </li>
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
</body>
</html>
