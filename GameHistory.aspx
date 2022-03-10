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
    var gameBrandList;
    var WebInfo;
    var v ="<%:Version%>";
    function updateBaseInfo() {
        gameBrandList = Array.from(window.parent.API_GetGameList().CategoryList.find(x => x.Categ.toUpperCase() == 'All'.toUpperCase()).CategBrandList);

        if (gameBrandList.findIndex(x => x == "All") == -1) {
            gameBrandList.unshift("All");
        }


        setSearchDate(0);
        createGameBrand();
    }

    function switchGameBrand(brand) {
        //$('.dropdown-selector-tab span').text(brand);
        //$('.dropdown-selector').removeClass('cur');
        updateGameHistory();
    }

    function createGameBrand() {
        var idGameBrands = document.getElementById("idGameBrands");
        idGameBrands.innerHTML = "";
        for (var i = 0; i < gameBrandList.length; i++) {
            var categ = gameBrandList[i];
            var RecordDom = c.getTemplate("temBrandItem");
            RecordDom.querySelector("input").setAttribute("id", "idBrand_" + categ);
            RecordDom.querySelector("input").onclick = new Function("switchGameBrand('" + categ + "')");
            RecordDom.querySelector("label").setAttribute("for", "idBrand_" + categ);
            RecordDom.querySelector("span").innerText = categ;


            if (categ.toUpperCase() == 'All'.toUpperCase()) {
                RecordDom.querySelector("input").checked = true;
                document.querySelector('.dropdown-selector-tab span').innerText = categ;
            }
            idGameBrands.appendChild(RecordDom);
        }
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

        updateGameHistory();
    }

    function updateGameHistory() {
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

        p.GetGameOrderSummaryHistoryGroupGameCode(WebInfo.SID, Math.uuid(), startDate, endDate, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    if (o.SummaryList.length > 0) {
                        //var brand = document.querySelector('.dropdown-selector-tab span').innerText;
                        var brand = "All";
                        //var numGameTotalValidBetValue = new BigNumber(0);
                        var numGameTotalRewardValue = new BigNumber(0);
                        for (var i = 0; i < o.SummaryList.length; i++) {
                            var daySummary = o.SummaryList[i];
                            var RecordDom = c.getTemplate("temRecordItem");
                            var summaryDate = new Date(daySummary.SummaryDate);


                            if (brand != "All") {
                                if (daySummary.GameAccountingCode.toUpperCase().includes(brand.toUpperCase()) == false) {
                                    continue;
                                }
                            }
                            //numGameTotalValidBetValue = numGameTotalValidBetValue.plus(o.SummaryList[i].ValidBetValue);
                            numGameTotalRewardValue = numGameTotalRewardValue.plus(daySummary.RewardValue);

                            c.setClassText(RecordDom, "month", null, summaryDate.toLocaleString('en-US', { month: 'short' }).toUpperCase());
                            c.setClassText(RecordDom, "date", null, summaryDate.toLocaleString('en-US', { day: 'numeric' }).toUpperCase());


                            var countDom = RecordDom.querySelector(".count");
                            if (daySummary.RewardValue >= 0) {
                                countDom.classList.add("positive");
                                countDom.innerText = "+ " + new BigNumber(daySummary.RewardValue).toFormat();
                            } else {
                                countDom.classList.add("negative");
                                countDom.innerText = "- " + new BigNumber(Math.abs(daySummary.RewardValue)).toFormat();
                            }
;
                            RecordDom.dataset.queryDate = daySummary.SummaryDate;
                            RecordDom.querySelector(".btn-toggle").onclick = function () {
                                var nowJQ = $(this);
                                var summaryDateDom = nowJQ.parents(".record-table-item").get(0);
                                var queryDate = summaryDateDom.dataset.queryDate;
                               
                                //Loading => 不重複點擊
                                //Loaded => 只做切換，不重新撈取數據
                                if (!summaryDateDom.classList.contains("Loading")) {
                                    if (summaryDateDom.classList.contains("Loaded")) {
                                        nowJQ.toggleClass('cur');
                                        nowJQ.parents('.record-table-item').find('.record-table-drop-panel').slideToggle();
                                    } else {
                                        summaryDateDom.classList.add("Loading");
                                        getGameOrderDetail(summaryDateDom, queryDate, function (success) {
                                            if (success) {
                                                nowJQ.addClass('cur');
                                                nowJQ.parents('.record-table-item').find('.record-table-drop-panel').slideToggle();                                                
                                                summaryDateDom.classList.add("Loaded");
                                            }

                                            summaryDateDom.classList.remove("Loading");
                                        });
                                    }                                   
                                }                                                  
                            };

                            ParentMain.prepend(RecordDom);

                        }

                        //document.getElementById('gameTotalValidBetValue').textContent = numGameTotalValidBetValue;
                        document.getElementById('idTotalReward').textContent = numGameTotalRewardValue;

                    } else {

                        window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("沒有資料"));
                        //document.getElementById('gameTotalValidBetValue').textContent = 0;
                        document.getElementById('idTotalReward').textContent = 0;
                    }
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("取得資料失敗"));
                    //document.getElementById('gameTotalValidBetValue').textContent = 0;
                    document.getElementById('idTotalReward').textContent = 0;
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
        
        var wallet = WebInfo.UserInfo.WalletList.find(x => x.CurrencyType.toLocaleUpperCase() == WebInfo.MainCurrencyType);

        document.getElementById("idWalletAmount").innerText = new BigNumber(wallet.PointValue).toFormat();
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

    function getGameOrderDetail(Dom, QueryDate, cb) {
        p.GetGameOrderHistoryBySummaryDateAndGameCode(WebInfo.SID, Math.uuid(), QueryDate, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    var panel = Dom.querySelector(".record-table-drop-panel")
                    panel.innerHTML = "";

                    if (o.DetailList.length > 0) {                       
                        for (var i = 0; i < o.DetailList.length; i++) {
                            var record = o.DetailList[i];
                            var RecordDom = c.getTemplate("temRecordDetailItem");
                            c.setClassText(RecordDom, "gameName", null, window.parent.API_GetGameLang(2, "", record.GameCode));
                            RecordDom.querySelector(".gameName").setAttribute("gameLangkey", record.GameCode);
                            RecordDom.querySelector(".gameName").classList.add("gameLangkey");
                            if (record.RewardValue >= 0) {
                                RecordDom.querySelector(".rewardValue").classList.add("positive");
                                c.setClassText(RecordDom, "rewardValue", null, "+ " + new BigNumber(record.RewardValue).toFormat());
                            } else {
                                RecordDom.querySelector(".rewardValue").classList.add("negative");
                                c.setClassText(RecordDom, "rewardValue", null, new BigNumber(record.RewardValue).toFormat());
                            }
                            
                            c.setClassText(RecordDom, "orderValue", null, new BigNumber(record.OrderValue).toFormat());

                            //if (record.OrderValue >= 0) {
                            //    RecordDom.querySelector(".orderValue").classList.add("positive");
                            //    c.setClassText(RecordDom, "orderValue", null, "+ " + new BigNumber(record.OrderValue).toFormat());
                            //} else {
                            //    RecordDom.querySelector(".orderValue").classList.add("negative");
                            //    c.setClassText(RecordDom, "orderValue", null, new BigNumber(record.OrderValue).toFormat());
                            //}

                            c.setClassText(RecordDom, "validBet", null, new BigNumber(record.ValidBetValue).toFormat());

                            //if (record.ValidBetValue >= 0) {
                            //    RecordDom.querySelector(".validBet").classList.add("positive");
                            //    c.setClassText(RecordDom, "validBet", null, "+ " + new BigNumber(record.ValidBetValue).toFormat());
                            //} else {
                            //    RecordDom.querySelector(".validBet").classList.add("negative");
                            //    c.setClassText(RecordDom, "validBet", null, new BigNumber(record.ValidBetValue).toFormat());
                            //}

                            //c.setClassText(RecordDom, "rewardValue", null, new BigNumber(record.RewardValue).toFormat());
                            //c.setClassText(RecordDom, "orderValue", null, new BigNumber(record.OrderValue).toFormat());
                            //c.setClassText(RecordDom, "validBet", null, new BigNumber(record.ValidBetValue).toFormat());
                            panel.appendChild(RecordDom);
                        }

                        if (cb) {
                            cb(true);
                        }
                    } else {
                        window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("沒有資料"));

                        if (cb) {
                            cb(false);
                        }
                    }
                   
                } else {
                    window.parent.showMessageOK(mlp.getLanguageKey("提示"), mlp.getLanguageKey("取得資料失敗"));

                    if (cb) {
                        cb(false);
                    }
                }
            } else {
                if (cb) {
                    cb(false);
                }
            }
        });
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
                var gameDoms = document.querySelectorAll(".gameLangkey");

                for (var i = 0; i < gameDoms.length; i++) {
                    var gameDom = gameDoms[i];
                    var newGameLang = window.parent.API_GetGameLang(2, "", gameDom.getAttribute("gameLangkey"));
                    gameDom.innerText = newGameLang;
                }

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
                                <%--            <div class="language_replace">錢包</div>--%>
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
                            <h3 class="title language_replace">遊戲紀錄</h3>
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
                            <div class="modal-info" data-toggle="modal" data-target="#modalInfo">
                                <i class="icon-error_outline"></i>
                            </div>
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

                       
                       <%-- <div class="dropdown-selector" style="display: none;">
                            <div class="dropdown-selector-tab" data-click-btn="toggle-dropdown">
                                <span>All Game</span>
                            </div>
                            <div class="dropdown-selector-panel">
                                <div id="idGameBrands" class="btn-wrap btn-radio-wrap">
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game00" checked>
                                        <label class="btn btn-outline-primary btn-sm" for="game00">
                                            <span>All Game</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game2">
                                        <label class="btn btn-outline-primary btn-sm" for="game2">
                                            <span>Ewin</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game3">
                                        <label class="btn btn-outline-primary btn-sm" for="game3">
                                            <span>BG</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game4">
                                        <label class="btn btn-outline-primary btn-sm" for="game4">
                                            <span>BNG</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game5">
                                        <label class="btn btn-outline-primary btn-sm" for="game5">
                                            <span>CG</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game6">
                                        <label class="btn btn-outline-primary btn-sm" for="game6">
                                            <span>HC</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game7">
                                        <label class="btn btn-outline-primary btn-sm" for="game7">
                                            <span>KGS</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game8">
                                        <label class="btn btn-outline-primary btn-sm" for="game8">
                                            <span>PG</span>
                                        </label>
                                    </div>
                                    <div class="btn-radio">
                                        <input type="radio" name="games" id="game9">
                                        <label class="btn btn-outline-primary btn-sm" for="game9">
                                            <span>abcdefg</span>
                                        </label>
                                    </div>
                                </div>

                            </div>
                        </div>--%>
                        
                        <button class="btn  btn-icon btn-white btn-round" onclick="updateGameHistory()">
                            <i class="icon-casinoworld-ico-cycle"></i>
                        </button>
                        
                    </div>

                    <div class="record-table games-record">
                        <div class="record-table-item header">
                            <div class="record-table-cell"><span class="language_replace">日期</span></div>
                            <div class="record-table-cell"><span class="language_replace" style="display: none;">遊戲</span></div>
                            <div class="record-table-cell"><span class="language_replace">輸贏</span></div>
                        </div>
                        <div id="idRecordContent">
                        </div>
                        <div class="record-table-item total">
                            <div class="record-table-cell">
                                <div class="ttl language_replace">期間輸贏 Total</div>
                            </div>
                            <div class="record-table-cell">
                                <div id="idTotalReward" class="count"></div>
                            </div>
                        </div>


                    </div>
                </div>
                <!-- 溫馨提醒 -->
                <div class="notice-container mt-5">
                    <div class="notice-item">
                        <i class="icon-info_circle_outline"></i>
                        <div class="text-wrap">
                            <p class="title language_replace">注意</p>
                            <p class="language_replace">遊戲記錄統計由於每間廠商同步資訊時間可能稍有不同，若有發現即時記錄不同，請稍後重新查詢一次。</p>
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
                    <div class="gameBrand"></div>
                </div>

                <div class="record-table-cell">
                    <div class="count"></div>
                </div>

                <div class="record-table-cell">
                    <div class="btn-toggle">
                        <div></div>
                    </div>
                    <div class="loader-lds-dual-ring"></div>
                </div>
            </div>

            <!-- 下拉明細 -->
            <div class="record-table-drop-panel" style="display: none">
            </div>

        </div>

    </div>

    <div id="temRecordDetailItem" class="is-hide">
        <%--   <table class="table table-sm table-sub" >
            <tbody>
                <tr class="thead">
                    <th class="language_replace gameName" rowspan="3"></th>

                    <th class="title language_replace">輸贏</th>
                    <!-- class=> negative/positive -->
                    <td class="text-bolder rewardValue"></td>
                </tr>
                <tr>
                    <th class="text-s language_replace">投注金額</th>
                    <td class="text-s orderValue"></td>
                </tr>
                <tr>
                    <th class="text-s language_replace">有效投注</th>
                    <td class="text-s validBet">50.000</td>
                </tr>
                <%--                        <tr class="total">
                            <th class="language_replace">餘額</th>
                            <td>
                                <div class="amount">
                                    <!-- <sup>USD</sup> -->
                                    <span class="count">0</span>
                                </div>
                            </td>
                        </tr>--%>
            </tbody>
        </table>--%>

        <div class="table table-sm table-gamehistory">
            <div class="thead">
                <div class="tr">
                    <div class="th language_replace gameName"></div>
                </div>
            </div>
            <div class="tbody">
                <div class="tr">
                    <div class="td title language_replace">輸贏</div>
                    <div class="td text-bolder language_replace rewardValue"></div>
                </div>
                <div class="tr">
                    <div class="td data text-s language_replace">投注金額</div>
                    <div class="td text-s orderValue"></div>
                </div>
                <div class="tr">
                    <div class="td data text-s language_replace">有效投注</div>
                    <div class="td text-s validBet">50.000</div>
                </div>
            </div>
        </div>


    </div>

    <div id="temBrandItem" class="is-hide">
        <div class="btn-radio">
            <input type="radio" name="games" id="">
            <label class="btn btn-outline-primary btn-sm" for="">
                <span>abcdefg</span>
            </label>
        </div>
    </div>
</body>
</html>
