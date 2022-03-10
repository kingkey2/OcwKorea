<%@ Page Language="C#" %>
    <%string Version=EWinWeb.Version; %>
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
    var c = new common();
    var ui = new uiControl();
    var p;
    var mlp;
    var lang;
    var WebInfo;
    var nowTransferType = -1;
    var v ="<%:Version%>";
    function updateBaseInfo() {
        setSearchDate(0);
    }

    function switchtransferType(transferType) {
            var Text;
            if (transferType == -1) {
                Text = 'All';
            } else if (transferType == 0) {
                Text = mlp.getLanguageKey('轉出');
            } else if (transferType == 1) {
                Text = mlp.getLanguageKey('轉入');
            } else {
                Text = 'All';
            }

            nowTransferType = transferType;

            $('.dropdown-selector-tab span').text(Text);
            $('.dropdown-selector').removeClass('cur');
            updateTransferHistory();
    }

    function getDateString(date) {
        var mm = date.getMonth() + 1; // getMonth() is zero-based
        var dd = date.getDate();

        return [date.getFullYear(),
        (mm > 9 ? '' : '0') + mm,
        (dd > 9 ? '' : '0') + dd
        ].join('-');
    }

    function setSearchDate(step) {
        var idSearchYear = document.getElementById("idSearchYear");
        var idSearchMonth = document.getElementById("idSearchMonth");
        var targetDate;

        switch (step) {
            case 0:
                targetDate = new Date();
                //targetDate.setHours(0,0,0,0);
                break;
            case 1:
                var nowDate = new Date();
                nowDate.setHours(0, 0, 0, 0);

                var targetDate = new Date(Number(idSearchYear.dataset.date), Number(idSearchMonth.dataset.date), 1);

                if (nowDate < targetDate) {
                    var modal = new bootstrap.Modal(document.getElementById("alertLastMonth"));
                    modal.show()
                    return;
                }

                break;
            case -1:
                var targetDate = new Date(Number(idSearchYear.dataset.date), Number(idSearchMonth.dataset.date) - 2, 1);
                break;

        }

        idSearchYear.dataset.date = targetDate.getFullYear();
        idSearchYear.innerText = targetDate.getFullYear();
        idSearchMonth.dataset.date = targetDate.getMonth() + 1;
        idSearchMonth.innerText = targetDate.toLocaleString('en-US', { month: 'long' });


        updateTransferHistory();
    }

    function updateTransferHistory() {
        //var dateType = document.querySelector('input[name="record-type"]:checked').value;
        var idSearchYear = document.getElementById("idSearchYear");
        var idSearchMonth = document.getElementById("idSearchMonth");
        var basicDate = new Date(Number(idSearchYear.dataset.date), Number(idSearchMonth.dataset.date), 0);
        var startDate = basicDate.format("yyyy/MM") + "/01";
        var endDate = basicDate.format("yyyy/MM/dd");

        //switch (dateType) {
        //    case 0:
        //        startDate = nowDate.format("yyyy-MM-dd");;;
        //        break;
        //    case 1:
        //        startDate = nowDate.addDays(-7).format("yyyy-MM-dd");
        //        break;
        //    case 2:
        //        startDate = nowDate.addDays(-30).format("yyyy-MM-dd");
        //        break;
        //    default:
        //        startDate = nowDate.format("yyyy-MM-dd");;;
        //        break;
        //}

        var ParentMain = document.getElementById("idRecordContent");
        ParentMain.innerHTML = "";

        p.GetTransferHistory(WebInfo.SID, Math.uuid(), startDate, endDate, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.TransferHistoryList.length > 0) {
                        //var numGameTotalValidBetValue = new BigNumber(0);
                        for (var i = 0; i < o.TransferHistoryList.length; i++) {
                            var transferRecord = o.TransferHistoryList[i];
                            var RecordDom = c.getTemplate("temRecordItem");
                            var recordDate = new Date(transferRecord.ConfirmDate);
                            var transferTypeText;
                            var toUserAccountText;


                            //switchtransferType(nowTransferType)

                            if (nowTransferType == 0) {
                                if (transferRecord.SrcLoginAccount != WebInfo.UserInfo.LoginAccount) {
                                    continue;
                                }
                            } else if (nowTransferType == 1) {
                                if (transferRecord.DstLoginAccount != WebInfo.UserInfo.LoginAccount) {
                                    continue;
                                }
                            }


                            if (transferRecord.SrcLoginAccount == WebInfo.UserInfo.LoginAccount) {
                                transferTypeText = mlp.getLanguageKey("轉出");
                                toUserAccountText = transferRecord.DstLoginAccount;
                                RecordDom = c.getTemplate("temRecordItem")
                            } else if (transferRecord.DstLoginAccount == WebInfo.UserInfo.LoginAccount) {
                                transferTypeText = mlp.getLanguageKey("轉入");
                                toUserAccountText = transferRecord.SrcLoginAccount;
                                RecordDom = c.getTemplate("temRecordItem2")
                            } else {
                                transferTypeText = mlp.getLanguageKey("轉出");
                                toUserAccountText = transferRecord.DstLoginAccount;
                                RecordDom = c.getTemplate("temRecordItem")
                            }
                            
                            //numGameTotalValidBetValue = numGameTotalValidBetValue.plus(o.SummaryList[i].ValidBetValue);                           

                            c.setClassText(RecordDom, "month", null, recordDate.toLocaleString('en-US', { month: 'short' }).toUpperCase());
                            c.setClassText(RecordDom, "date", null, recordDate.toLocaleString('en-US', { day: 'numeric' }).toUpperCase());
                            c.setClassText(RecordDom, "transferType", null, transferTypeText);
                            c.setClassText(RecordDom, "toUserAccount", null, toUserAccountText);
                            c.setClassText(RecordDom, "confirmDate", null, transferRecord.ConfirmDate + " " + transferRecord.ConfirmTime);
                            c.setClassText(RecordDom, "transferAmount", null, new BigNumber(transferRecord.TransferValue).toFormat());
                            var countDom = RecordDom.querySelector(".count");
                            if (transferRecord.DstLoginAccount == WebInfo.UserInfo.LoginAccount) {
                                countDom.classList.add("positive");
                                countDom.innerText = "+ " + new BigNumber(transferRecord.TransferValue).toFormat();
                            } else {
                                countDom.classList.add("negative");
                                countDom.innerText = "- " + new BigNumber(Math.abs(transferRecord.TransferValue)).toFormat();
                            }

                            RecordDom.querySelector(".btn-toggle").onclick = function () {
                                $(this).toggleClass('cur');
                                $(this).parents('.record-table-item').find('.record-table-drop-panel').slideToggle();
                            };

                            ParentMain.appendChild(RecordDom);

                        }
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("沒有資料"));
                        //document.getElementById('gameTotalValidBetValue').textContent = 0;
                    }
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("取得資料失敗"));
                    //document.getElementById('gameTotalValidBetValue').textContent = 0;                   
                }
            } else {
                // 忽略 timeout 
            }
        });
    }

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
            updateBaseInfo()
        });

        // dropdown-selector
        $('[data-click-btn="toggle-dropdown"]').click(function () {
            $(this).parent().toggleClass('cur');
        });

        document.getElementById("idWalletAmount").innerText = new BigNumber(WebInfo.UserInfo.WalletList.find(x=> x.CurrencyType == window.parent.API_GetCurrency()).PointValue).toFormat();
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
                            <h3 class="title language_replace">轉移紀錄</h3>
                        </div>
                    </div>
                </div>

                <!-- 類別選單 -->
                <%--                <div class="slide-menu-container">
                    <div class="slide-menu-wraper">
                        <input value="0" type="radio" name="record-type" id="record-type-all" checked>
                        <label class="slide-menu-item" for="record-type-all">
                            <span>近1日</span>
                        </label>

                        <input value="1" type="radio" name="record-type" id="record-type-seven">
                        <label class="slide-menu-item" for="record-type-seven">
                            <span>近7日</span>
                        </label>

                        <input value="2" type="radio" name="record-type" id="record-type-month">
                        <label class="slide-menu-item" for="record-type-month">
                            <span>近30日</span>
                        </label>

                        <div class="tracking-bar"></div>
                    </div>
                </div>--%>

                <!-- 紀錄列表 -->
                <div class="record-table-container">
                    <!--  日期選擇 -->
                    <div class="record-table-date-select">
                        <div class="wrap-box">
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
                        </div>

                        <div class="dropdown-selector">
                            <div class="dropdown-selector-tab" data-click-btn="toggle-dropdown">
                                <span>All</span>
                            </div>
                            <div class="dropdown-selector-panel">
                                <div id="idGameBrands" class="btn-wrap btn-radio-wrap">
                                    <div class="btn-radio">
                                        <input type="radio" name="transferType" id="type_All" onclick="switchtransferType(-1)" checked>
                                        <label class="btn btn-outline-primary btn-sm" for="type_All">
                                            <span>All</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="transferType" id="type_0" onclick="switchtransferType(0)">
                                        <label class="btn btn-outline-primary btn-sm" for="type_0">
                                            <span class="language_replace">轉出</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="transferType" id="type_1" onclick="switchtransferType(1)">
                                        <label class="btn btn-outline-primary btn-sm" for="type_1">
                                            <span class="language_replace">轉入</span>
                                        </label>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>

                    <div class="record-table games-record">
                        <div class="record-table-item header">
                            <div class="record-table-cell"><span class="language_replace">日期</span></div>
                            <div class="record-table-cell"><span class="language_replace">類型</span></div>
                            <div class="record-table-cell"><span class="language_replace">金額</span></div>
                        </div>
                        <div id="idRecordContent">
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <!-- Modal -->
    <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="modalInfo" aria-hidden="true" id="modalInfo">
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
                            <ul class="list-style-decimal">
                                <li class="language_replace">此遊戲紀錄僅列出各遊戲的當日總和，若您需要查詢各遊戲的詳細記錄，請於各遊戲中的遊戲紀錄進行查詢。</li>
                                <li class="language_replace">各平台遊戲紀錄查詢方式和路徑不盡相同，此處無法一一列舉說明，請各位玩家見諒。</li>
                                <li class="language_replace">各遊戲統計遊戲紀錄之時間有可能不盡相同，可能無法進行即時核對，發現金額計算有所差異，可稍後再試。</li>
                            </ul>
                            <p class="note primary language_replace">※遊戲紀錄統計時間從1分鐘~隔日統計都是有可能的。</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                </div>
            </div>
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
        <div class="record-table-item">
            <div class="record-table-tab">
                <div class="record-table-cell">
                    <div class="data-date">
                        <div class="month"></div>
                        <div class="date"></div>
                    </div>
                </div>

                <div class="record-table-cell">
                    <div class="transferType"></div>
                </div>

                <div class="record-table-cell">
                    <div class="count"></div>
                </div>

                <div class="record-table-cell">
                    <div class="btn-toggle">
                        <div></div>
                    </div>
                </div>
            </div>

            <!-- 下拉明細 -->
            <div class="record-table-drop-panel" style="display: none">
                <table class="table table-sm">
                    <tbody>
                        <tr>
                            <th class="language_replace">收取對象</th>
                            <td class="toUserAccount"></td>
                        </tr>
                        <tr>
                            <th class="language_replace">轉出金額</th>
                            <td class="transferAmount"></td>
                        </tr>
                        <tr>
                            <th class="language_replace">轉出時間</th>
                            <td class="confirmDate"></td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </div>

    </div>

    <div id="temRecordItem2" class="is-hide">
        <div class="record-table-item">
            <div class="record-table-tab">
                <div class="record-table-cell">
                    <div class="data-date">
                        <div class="month"></div>
                        <div class="date"></div>
                    </div>
                </div>

                <div class="record-table-cell">
                    <div class="transferType"></div>
                </div>

                <div class="record-table-cell">
                    <div class="count"></div>
                </div>

                <div class="record-table-cell">
                    <div class="btn-toggle">
                        <div></div>
                    </div>
                </div>
            </div>

            <!-- 下拉明細 -->
            <div class="record-table-drop-panel" style="display: none">
                <table class="table table-sm">
                    <tbody>
                        <tr>
                            <th class="language_replace">轉入來源</th>
                            <td class="toUserAccount"></td>
                        </tr>
                        <tr>
                            <th class="language_replace">轉入金額</th>
                            <td class="transferAmount"></td>
                        </tr>
                        <tr>
                            <th class="language_replace">轉入時間</th>
                            <td class="confirmDate"></td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </div>

    </div>
</body>
</html>
