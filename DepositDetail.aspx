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
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
    <script type="text/javascript" src="/Scripts/DateExtension.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script>      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var WebInfo;
    var mlp;
    var PaymentSerial;
    var OrderNumber;
    var c = new common();
    var p;
    var v = "<%:Version%>";
    var MainCurrencyType = "<%:MainCurrencyType%>";
    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        $('.MainCurrencyType').html(MainCurrencyType);
        WebInfo = window.parent.API_GetWebInfo();
        lang = window.parent.API_GetLang();
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            PaymentSerial = c.getParameter("PS");

            if (PaymentSerial) {
                p = window.parent.API_GetPaymentAPI();
                getPaymentByPaymentSerial(PaymentSerial);
            } else {
                window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("請輸入單號"), function () {
                    window.parent.API_Reload();
                });
            }

            window.parent.API_LoadingEnd();
        },"PaymentAPI");
    }

    function cancelPayment() {
        p.CancelPayment(WebInfo.SID, Math.uuid(), PaymentSerial, OrderNumber, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    window.parent.showMessageOK(mlp.getLanguageKey("成功"), mlp.getLanguageKey("已取消訂單"), function () {
                          window.parent.API_Reload();
                    });
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o), function () {
                          window.parent.API_Reload();
                    });
                }
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("服務器異常, 請稍後再嘗試一次"), function () {
                      window.parent.API_Reload();
                });
            }
        });
    }

    function getPaymentByPaymentSerial(PaymentSerial) {
        p.GetPaymentByPaymentSerial(WebInfo.SID, Math.uuid(), PaymentSerial, function (success, o) {
            
            if (success) {
                if (o.Result == 0) {
                    var retData = o.Data;
                    var TotalThresholdValue = 0
                    var TotalBonusValue = 0;
                    var TotalAmount = 0;
                    //dom物件
                    var paymentDetailDom = document.getElementById("paymentMethodDom");
                    var paymentInfoDom = document.getElementById("paymentInfoDom");
                    //var activityDom = document.getElementById("activityDom");


                    TotalThresholdValue += retData.ThresholdValue;
                    TotalAmount += retData.Amount;

                    if (retData.ActivityDatas != null) {
                        for (var i = 0; i < retData.ActivityDatas.length; i++) {
                            TotalThresholdValue += retData.ActivityDatas[i].ThresholdValue;
                            TotalBonusValue += retData.ActivityDatas[i].BonusValue;
                        }
                    }

                    if (retData.BasicType != 2) {
                        document.getElementById('idWalletAddressDom').classList.add('is-hide');
                        paymentInfoDom.querySelector('.EWinCryptoWalletTypeItem').classList.add('is-hide');
                        document.getElementById('idAlertDom').classList.add('is-hide');
                        //document.getElementById('idEthScanUrl').classList.add('is-hide');
                    } else {
                        if (retData.ToWalletAddress != "") {
                            setEthWalletAddress(retData.ToWalletAddress);
                        }              

                        switch (retData.WalletType) {
                            case 0:
                                c.setClassText(paymentInfoDom, "EWinCryptoWalletType", null, "ERC");                    
                                break;
                            case 1:
                                c.setClassText(paymentInfoDom, "EWinCryptoWalletType", null, "XRP");
                                break;
                            case 2:
                                c.setClassText(paymentInfoDom, "EWinCryptoWalletType", null, "BTC");
                                break;
                            case 3:
                                c.setClassText(paymentInfoDom, "EWinCryptoWalletType", null, "TRC");
                                break;
                            default:
                                paymentInfoDom.querySelector('.EWinCryptoWalletTypeItem').classList.add('is-hide');
                                break;
                        }
                    }


                    OrderNumber = retData.OrderNumber;
                    c.setClassText(paymentInfoDom, "Paymentserial", null, PaymentSerial);
                    $(paymentInfoDom).find('.inputPaymentSerial').val(PaymentSerial);
                    c.setClassText(paymentInfoDom, "PaymentMethodName", null, retData.PaymentMethodName);
                   
                    c.setClassText(paymentInfoDom, "ThresholdValue", null, TotalThresholdValue);
                    c.setClassText(paymentInfoDom, "CreateDate", null, c.addHours(retData.LimitDate, 1).format("yyyy/MM/dd hh:mm:ss"));

                    if (retData.PaymentCryptoDetailList != null) {
                        var depositdetail = document.getElementsByClassName("Collectionitem")[0];
                        for (var i = 0; i < retData.PaymentCryptoDetailList.length; i++) {

                            var CollectionitemDom = c.getTemplate("templateCollectionitem");
                            CollectionitemDom.querySelector(".icon-logo").classList.add("icon-logo-" + retData.PaymentCryptoDetailList[i]["TokenCurrencyType"].toLowerCase());
                            c.setClassText(CollectionitemDom, "currency", null, retData.PaymentCryptoDetailList[i]["TokenCurrencyType"]);
                            c.setClassText(CollectionitemDom, "val", null, new BigNumber(retData.PaymentCryptoDetailList[i]["ReceiveAmount"]).toFormat());
                            depositdetail.appendChild(CollectionitemDom);
                        }
                    }
                    c.setClassText(paymentDetailDom, "Amount", null, new BigNumber(retData.Amount).toFormat());

                    if (TotalBonusValue != 0) {
                        c.setClassText(paymentDetailDom, "BonusValue", null, new BigNumber(TotalBonusValue).toFormat());
                        paymentDetailDom.querySelector(".BonusValueItem").classList.remove("is-hide");
                        c.setClassText(paymentDetailDom, "TotalAmount", null, new BigNumber(TotalBonusValue + TotalAmount).toFormat());
                        paymentDetailDom.querySelector(".TotalAmountItem").classList.remove("is-hide");
                    }
               
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("貨幣未設定匯率"), function () {
                          window.parent.API_Reload();
                    });
                }
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("服務器異常, 請稍後再嘗試一次"), function () {
                      window.parent.API_Reload();
                });
            }
        });
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

    function copyTextPaymentSerial(tag) {
      
        var copyText = $(tag).parent().find('.inputPaymentSerial')[0];

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

        <div class="page-content">

            <section class="sec-wrap">
                <!-- 頁面標題 -->
                <div class="page-title-container">
                    <div class="page-title-wrap">
                        <div class="page-title-inner">
                            <h3 class="title language_replace">入款</h3>
                        </div>
                    </div>
                </div>

                <!-- 步驟 -->

                <div class="text-wrap progress-title" style="display: none">
                    <p data-deposite="step4" class="language_replace">
                        <span class="language_replace">使用</span>
                        <span class="language_replace">USDT</span>
                        <span class="language_replace">入款</span>
                    </p>

                </div>

                <div class="split-layout-container" >
                    <div class="crypto-info-coantainer" id="idWalletAddressDom">

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
                        <div class="crypto-info-related is-hide" id="idEthScanUrl">
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
                                    <p class="currency ExchangeRateOut"><span class="amount">100</span><span class="unit MainCurrencyType"></span></p>
                                </div>
                                <div class="refresh">
                                    <p class="period"><span class="date"></span><span class="time">15:30:02</span></p>
                                    <button type="button" class="btn btn-outline-primary btn-icon btn-refresh  btn-white" onclick="RefreshExchange()">
                                        <i class="icon-casinoworld-refresh" onclick=""></i>
                                        <span class="language_replace">更新</span>
                                    </button>
                                </div>
                            </div>

                        </div>
                    </div>
                    <!-- 虛擬錢包 step3 - 入金確認頁-->
                    <div class="deposit-confirm" data-deposite="step3">
                        <div class="aside-panel">
                            <div class="deposit-calc" id="paymentMethodDom">
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
                                            <span class="name MainCurrencyType"></span>
                                            <span class="count Amount"></span>
                                        </div>
                                    </div>
                                    <div class="item BonusValueItem subtotal is-hide">
                                        <div class="title">
                                            <h5 class="name language_replace">活動獎勵</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name MainCurrencyType"></span>
                                            <span class="count BonusValue"></span>
                                        </div>
                                    </div>
                                    <div class="item total is-hide TotalAmountItem" >
                                        <div class="title">
                                            <h5 class="name language_replace">可得總額</h5>
                                        </div>
                                        <div class="data">
                                            <span class="name MainCurrencyType"></span>
                                            <span class="count TotalAmount"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="main-panel">
                            <div class="deposit-list">
                                <h5 class="subject-title language_replace">存款細項</h5>
                                <ul class="deposit-detail" id="paymentInfoDom">
                                    <li class="item">
                                        <h6 class="title language_replace">訂單號碼</h6>
                                        <span class="data Paymentserial"></span>
                                         <i class="icon-copy" onclick="copyTextPaymentSerial(this)" style="display: inline;"></i>     
                                        <input class="inputPaymentSerial is-hide" />
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">支付方式</h6>
                                        <span class="data PaymentMethodName"></span>
                                    </li>
                                    <li class="item EWinCryptoWalletTypeItem">
                                        <h6 class="title language_replace">合約方式</h6>
                                        <span class="data EWinCryptoWalletType">ERC</span>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">交易限制時間</h6>
                                        <span class="data text-primary CreateDate">2021/3/1</span>
                                    </li>
                                    <li class="item">
                                        <h6 class="title language_replace">出金條件</h6>
                                        <span class="data ThresholdValue"></span>
                                    </li>

                                </ul>
                            </div>
                        </div>
                        <div class="activity-container" style="display: none">
                            <div class="activity-item">
                                <h5 class="subject-title language_replace">熱門活動</h5>
                                <!-- 存款獎勵 -->
                                <div class="text-wrap award-content">
                                    <ul class="deposit-award-list ActivityMain" id="activityDom">
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="btn-container mt-2">
                    <%--    <button class="btn btn-outline-primary" data-deposite="step4" onclick="window.top.API_LoadPage('Home','Home.aspx')">
                        <span class="language_replace">首頁</span>
                    </button>
                  <button class="btn btn-primary" data-deposite="step4" data-toggle="modal" data-target="#depositSucc">
                        <span>確認</span>
                    </button>--%>
                    <button class="btn btn-outline-primary" onclick="cancelPayment()">
                        <span class="language_replace">取消</span>
                    </button>
                </div>

                <!-- 溫馨提醒 -->
                <div class="notice-container" data-deposite="step4" id="idAlertDom">
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
</body>
</html>
