<%@ Page Language="C#" %>

<%string Version = EWinWeb.Version; %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Casino World</title>

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
    var nowRecordStatus = -1;
    var isDepositeOrWithdrawal = -1;
    var v ="<%:Version%>";
    function updateBaseInfo() {
        updatePaymentHistory();
    }

    function switchtRecordDepositeWithdrawal(recordStatus) {
        var Text;
        if (recordStatus == -1) {
            document.getElementById("record-type-all").setAttribute("checked", "checked");
            document.getElementById("record-type-deposit").removeAttribute("checked");
            document.getElementById("record-type-withdraw").removeAttribute("checked");

        } else if (recordStatus == 0) {
            document.getElementById("record-type-all").removeAttribute("checked");
            document.getElementById("record-type-deposit").setAttribute("checked", "checked");
            document.getElementById("record-type-withdraw").removeAttribute("checked");
        } else if (recordStatus == 1) {
            document.getElementById("record-type-all").removeAttribute("checked");
            document.getElementById("record-type-deposit").removeAttribute("checked");
            document.getElementById("record-type-withdraw").setAttribute("checked", "checked");
        } else {
            recordStatus == -1;
            document.getElementById("record-type-all").setAttribute("checked", "checked");
            document.getElementById("record-type-deposit").removeAttribute("checked");
            document.getElementById("record-type-withdraw").removeAttribute("checked");
        }

        isDepositeOrWithdrawal = recordStatus;

        updatePaymentHistory();
    }

    function getDateString(date) {
        var mm = date.getMonth() + 1; // getMonth() is zero-based
        var dd = date.getDate();

        return [date.getFullYear(),
        (mm > 9 ? '' : '0') + mm,
        (dd > 9 ? '' : '0') + dd
        ].join('-');
    }


    function updatePaymentHistory() {

        var ParentMain = document.getElementById("idRecordContent");
        ParentMain.innerHTML = "";

        p.GetPaymentByNonFinished(WebInfo.SID, Math.uuid(), function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.Datas.length > 0) {
                        var RecordDom;
                        //var numGameTotalValidBetValue = new BigNumber(0);
                        for (var i = 0; i < o.Datas.length; i++) {
                            var record = o.Datas[i];
                            if (record.PaymentType == 0) {
                                RecordDom = c.getTemplate("temRecordItem2");
                            } else {
                                RecordDom = c.getTemplate("temRecordItem");
                            }


                            var recordDate = new Date(c.addHours(record.CreateDate, 1));
                            var paymentRecordText;
                            var BasicType;
                            let Amount;


                            paymentRecordText = mlp.getLanguageKey('進行中');
                            $(RecordDom).find('.PaymentStatus').addClass('processing');

                            // 0=一般/1=銀行卡/2=區塊鏈
                            switch (record.BasicType) {
                                case 0:
                                    BasicType = mlp.getLanguageKey('一般');
                                    break;
                                case 1:
                                    BasicType = mlp.getLanguageKey('銀行卡');
                                    break;
                                case 2:
                                    BasicType = mlp.getLanguageKey('區塊鏈');
                                    break;
                                default:
                            }


                            if (isDepositeOrWithdrawal != -1) {
                                if (isDepositeOrWithdrawal != record.PaymentType) {
                                    continue;
                                }
                            }

                            //金額處理
                            var countDom = RecordDom.querySelector(".amount");

                            if (record.PaymentType == 0) {
                                Amount = record.Amount;
                            } else {
                                Amount = record.Amount * -1;
                            }

                            if (Amount >= 0) {
                                countDom.classList.add("positive");
                                countDom.innerText = "+ " + new BigNumber(Math.abs(Amount)).toFormat();
                            } else {
                                countDom.classList.add("negative");
                                countDom.innerText = "- " + new BigNumber(Math.abs(Amount)).toFormat();
                            }

                            c.setClassText(RecordDom, "month", null, recordDate.toLocaleString('en-US', { month: 'short' }).toUpperCase());
                            c.setClassText(RecordDom, "date2", null, recordDate.toLocaleString('en-US', { day: 'numeric' }).toUpperCase());
                            c.setClassText(RecordDom, "PaymentStatus", null, paymentRecordText);
                            c.setClassText(RecordDom, "CreateDate", null, c.addHours(record.CreateDate, 1).format("yyyy/MM/dd hh:mm:ss"));
                            c.setClassText(RecordDom, "FinishTime", null, c.addHours(record.CreateDate, 1).format("hh:mm:ss"));
                            if (record.PaymentType == 1) {
                                c.setClassText(RecordDom, "ToWalletAddress", null, record.ToWalletAddress);
                            }
                            c.setClassText(RecordDom, "PaymentMethodName", null, record.PaymentMethodName);
                            c.setClassText(RecordDom, "BasicType", null, BasicType);
                            c.setClassText(RecordDom, "PaymentSerial", null, record.PaymentSerial);
                            $(RecordDom).find(".detailbtn").data('PaymentSerial', record.PaymentSerial);
                            $(RecordDom).find('.inputPaymentSerial').val(record.PaymentSerial);
                            RecordDom.querySelector(".detailbtn").onclick = function () {

                                if (record.PaymentType == 0) {
                                    window.parent.API_LoadPage('DepositDetail', 'DepositDetail.aspx?PS=' + $(this).data('PaymentSerial'), true);
                                } else {
                                    window.parent.API_LoadPage('WtihdrawalDetail', 'WtihdrawalDetail.aspx?PS=' + $(this).data('PaymentSerial'), true);
                                }

                            };

                            ParentMain.appendChild(RecordDom);
                            if ($(ParentMain).length == 0) {
                                window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("沒有資料"));
                            }

                        }
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("沒有資料"));
                        //document.getElementById('gameTotalValidBetValue').textContent = 0;
                    }
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("沒有資料"));
                    //document.getElementById('gameTotalValidBetValue').textContent = 0;                   
                }
            } else {
                // 忽略 timeout 
            }
        });
    }

    function copyText(tag) {

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

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        WebInfo = window.parent.API_GetWebInfo();
        p = window.parent.API_GetPaymentAPI();
        lang = window.parent.API_GetLang();

        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();
            updateBaseInfo()
        }, "PaymentAPI");

        document.getElementById("idWalletAmount").innerText = new BigNumber(WebInfo.UserInfo.WalletList.find(x => x.CurrencyType == window.parent.API_GetCurrency()).PointValue).toFormat();
        document.getElementById("idUserName").innerText = WebInfo.UserInfo.RealName;
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
                                <%--          <div class="language_replace">錢包</div>--%>
                            </div>
                        </div>
                        <div class="col d-flex">
                            <div class="balance-info">
                                <div class="balance-info-title" style="display: none;">
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
                            <h3 class="title language_replace">進行中交易</h3>
                        </div>
                    </div>
                </div>

                <!-- 類別選單 -->
                <div class="slide-menu-container">
                    <div class="slide-menu-wraper">
                        <input type="radio" name="record-type" id="record-type-all" onclick="switchtRecordDepositeWithdrawal(-1)" checked>
                        <label class="slide-menu-item" for="record-type-all">
                            <span class="language_replace">全部</span>
                        </label>

                        <input type="radio" name="record-type" id="record-type-deposit" onclick="switchtRecordDepositeWithdrawal(0)">
                        <label class="slide-menu-item" for="record-type-deposit">
                            <span class="language_replace">存款</span>
                        </label>

                        <input type="radio" name="record-type" id="record-type-withdraw" onclick="switchtRecordDepositeWithdrawal(1)">
                        <label class="slide-menu-item" for="record-type-withdraw">
                            <span class="language_replace">取款</span>
                        </label>

                        <div class="tracking-bar"></div>
                    </div>
                </div>

                <!-- 紀錄列表 -->
                <div class="record-table-container payment-record">
                    <!--  日期選擇 -->
                    <div class="record-table-date-select">
                        <%--     <div class="wrap-box">
                            <div class="desc">
                                <span class="month" data-date="10" id="idSearchMonth">October</span>
                                <span class="year" data-date="2021" id="idSearchYear">2021</span>
                            </div>
                            <div class="btn-container">
                                   <button class="btn btn-icon" onclick="setSearchDate(-1)">
                                    <i class="icon-arrow-left"></i>
                                </button>
                                <button class="btn btn-icon" onclick="setSearchDate(1)">
                                    <i class="icon-arrow-right"></i>
                                </button>
                            </div>
                        </div>--%>
                    </div>

                    <div class="record-table payment-record">
                        <div class="record-table-item header">
                            <div class="record-table-cell date"><span class="language_replace">日期</span></div>
                            <div class="record-table-cell payment-way"><span class="language_replace">支付方式</span></div>
                            <div class="record-table-cell count"><span class="language_replace">金額</span></div>
                            <div class="record-table-cell status"><span class="language_replace">狀態</span></div>
                        </div>
                        <div id="idRecordContent">
                            <!-- 存款樣式 / 進行中=> class="processing" -->
                            <%--   <div class="record-table-item processing" data-record-type="diposit">
                            <div class="record-table-tab">
                                <div class="record-table-cell date">
                                    <div class="data-date">
                                        <div class="month">OCT</div>
                                        <div class="date">10</div>
                                    </div>
                                </div>
                                <div class="record-table-cell payment-way">
                                    <div class="paymen-tway">PayPal</div>
                                </div>
                                <div class="record-table-cell count">
                                    <div class="count positive">+99,999,999</div>
                                </div>
                                <div class="record-table-cell status">
                                    <span class="data-status processing">進行中</span>
                                </div>             </div>

                            <!-- 明細 -->
                            <div class="record-table-drop-panel">
                                <table class="table table-sm">
                                    <tbody>
                                        <tr>
                                            <th>訂單編號</th>
                                            <td>XXXX-XXXX-XXXXXXXX</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <!-- 進入細詳頁按鈕 -->
                            <div class="record-table-detail-btn">
                                <button class="btn btn-icon">
                                    <i class="icon-arrow-right"></i>
                                </button>
                            </div>

                        </div>--%>
                            <!-- 存款樣式 -->
                            <%--          <div class="record-table-item" data-record-type="diposit">
                            <div class="record-table-tab">
                                <div class="record-table-cell date">
                                    <div class="data-date">
                                        <div class="month">OCT</div>
                                        <div class="date">10</div>
                                    </div>
                                </div>
                                <div class="record-table-cell payment-way">
                                    <div class="paymen-tway">PayPal</div>
                                </div>
                                <div class="record-table-cell count">
                                    <div class="count positive">+9,999</div>
                                </div>
                                <div class="record-table-cell status">
                                    <span class="data-status">已完成</span>
                                </div>
                            </div>

                            <!-- 明細 -->
                            <div class="record-table-drop-panel">
                                <table class="table table-sm">
                                    <tbody>
                                        <tr>
                                            <th>訂單編號</th>
                                            <td>XXXX-XXXX-XXXXXXXX</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                        </div>--%>
                            <!-- 取款樣式 / 進行中=> class="processing" -->
                            <%--         <div class="record-table-item processing" data-record-type="wihtdraw">
                            <div class="record-table-tab">
                                <div class="record-table-cell date">
                                    <div class="data-date">
                                        <div class="month">OCT</div>
                                        <div class="date">10</div>
                                    </div>
                                </div>
                                <div class="record-table-cell payment-way">
                                    <div class="paymen-tway">JKC+ETH</div>
                                </div>
                                <div class="record-table-cell count">
                                    <div class="count negative">-999,999,999</div>
                                </div>
                                <div class="record-table-cell status">
                                    <span class="data-status processing">進行中</span>
                                </div>
                            </div>

                            <!-- 明細 -->
                            <div class="record-table-drop-panel">
                                <table class="table table-sm">
                                    <tbody>
                                        <tr>
                                            <th>訂單編號</th>
                                            <td>XXXX-XXXX-XXXXXXXX</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <!-- 進入細詳頁按鈕 -->
                            <div class="record-table-detail-btn">
                                <button class="btn btn-icon">
                                    <i class="icon-arrow-right"></i>
                                </button>
                            </div>

                        </div>--%>
                            <!-- 取款樣式 / 失敗 -->
                            <%-- <div class="record-table-item" data-record-type="wihtdraw">
                            <div class="record-table-tab">
                                <div class="record-table-cell date">
                                    <div class="data-date">
                                        <div class="month">OCT</div>
                                        <div class="date">10</div>
                                    </div>
                                </div>
                                <div class="record-table-cell payment-way">
                                    <div class="paymen-tway">JKC+ETH</div>
                                </div>
                                <div class="record-table-cell count">
                                    <div class="count negative">-9,999</div>
                                </div>
                                <div class="record-table-cell status">
                                    <span class="data-status fail">失敗</span>
                                </div>
                            </div>

                            <!-- 明細 -->
                            <div class="record-table-drop-panel">
                                <table class="table table-sm">
                                    <tbody>
                                        <tr>
                                            <th>訂單編號</th>
                                            <td>XXXX-XXXX-XXXXXXXX</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                        </div>--%>
                        </div>



                    </div>
                </div>
            </section>

        </div>
    </div>
    <!-- Modal -->
    <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="alertLastMonth" aria-hidden="true" id="alertLastMonth">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true"><i class="icon-close-small"></i></span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="modal-body-content">
                        <div class="text-wrap">
                            <p class="language_replace">已經是最新月份了!</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                </div>

            </div>
        </div>
    </div>
    <div id="temRecordItem" class="is-hide">
        <div class="record-table-item processing" data-record-type="diposit">
            <div class="record-table-tab">
                <div class="record-table-cell date">
                    <div class="data-date">
                        <div class="month">OCT</div>
                        <div class="date date2">10</div>
                    </div>
                </div>
                <div class="record-table-cell payment-way">
                    <div class="paymen-tway PaymentMethodName"></div>
                </div>
                <div class="record-table-cell count">
                    <div class="count positive amount">+9,999</div>
                </div>
                <div class="record-table-cell status">
                    <span class="data-status PaymentStatus language_replace">已完成</span>
                </div>
            </div>

            <!-- 明細 -->
            <div class="record-table-drop-panel">
                <table class="table table-sm">
                    <tbody>
                        <tr>
                            <th class="title language_replace">訂單編號</th>
                            <td><span class="PaymentSerial"></span>
                                <input class="inputPaymentSerial is-hide" />
                                <i class="icon-copy" onclick="copyText(this)" style="display: inline;"></i>
                            </td>
                        </tr>
                        <tr>
                            <th class="language_replace">出款地址</th>
                            <td class="ToWalletAddress">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                        <tr>
                            <th class="language_replace">類型</th>
                            <td class="BasicType">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                        <tr>
                            <th class="language_replace">建立日期</th>
                            <td class="CreateDate">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                        <tr style="display: none">
                            <th class="language_replace">完成時間</th>
                            <td class="FinishTime">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <!-- 進入細詳頁按鈕 -->
            <div class="record-table-detail-btn">
                <button class="btn btn-icon detailbtn">
                    <i class="icon-arrow-right"></i>
                </button>
            </div>

        </div>
    </div>
    <div id="temRecordItem2" class="is-hide">
        <div class="record-table-item processing" data-record-type="diposit">
            <div class="record-table-tab">
                <div class="record-table-cell date">
                    <div class="data-date">
                        <div class="month">OCT</div>
                        <div class="date date2">10</div>
                    </div>
                </div>
                <div class="record-table-cell payment-way">
                    <div class="paymen-tway PaymentMethodName"></div>
                </div>
                <div class="record-table-cell count">
                    <div class="count positive amount">+9,999</div>
                </div>
                <div class="record-table-cell status">
                    <span class="data-status PaymentStatus"></span>
                </div>
            </div>

            <!-- 明細 -->
            <div class="record-table-drop-panel">
                <table class="table table-sm">
                    <tbody>
                        <tr>
                            <th class="title language_replace">訂單編號</th>
                            <td><span class="PaymentSerial"></span>
                                <input class="inputPaymentSerial is-hide" />
                                <i class="icon-copy" onclick="copyText(this)" style="display: inline;"></i>
                            </td>
                        </tr>
                        <tr>
                            <th class="language_replace">類型</th>
                            <td class="BasicType">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                        <tr>
                            <th class="language_replace">建立日期</th>
                            <td class="CreateDate">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                        <tr style="display: none">
                            <th class="language_replace">完成時間</th>
                            <td class="FinishTime">XXXX-XXXX-XXXXXXXX</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <!-- 進入細詳頁按鈕 -->
            <div class="record-table-detail-btn">
                <button class="btn btn-icon detailbtn">
                    <i class="icon-arrow-right"></i>
                </button>
            </div>

        </div>
    </div>
</body>
</html>
