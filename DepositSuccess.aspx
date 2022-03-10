<%@ Page Language="C#" %>

<%
    string OrderDate = Request["OrderDate"];
    string Amount = Request["Amount"];
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
    <script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>

</head>
<script>
    var Amount = "<%=Amount%>";
    var OrderDate = "<%=OrderDate%>";
    var mlp;
    var lang;
    var v ="<%:Version%>";
    function init() {
        //if (window.localStorage.getItem("Lang")) {
        //    lang = window.localStorage.getItem("Lang");
        //} else {
        //    lang = "CHT";
        //}   
        lang = "JPN";
        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {

        },"PaymentAPI");

        $("#amount").text(Amount);
        $("#totalamount").text(Amount);
        $("#orderdate").text(OrderDate);
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
                    <div class="progress-step cur">
                        <div class="progress-step-item"></div>
                    </div>
                </div>

                <div class="progress-title text-wrap">
                    <!-- <p data-deposite="step2">輸入存款金額</p> -->
                    <p data-deposite="step2" class="language_replace">完成</p>
                </div>

                <div class="split-layout-container">
                    <!-- 交易結果 -->
                    <div class="main-panel" data-deposite="">
                        <div class="form-content">
                            <!-- 1. 加入 class=> resultShow
                                 2. 加入 class=> success/fail
                            -->
                            <!-- 交易成功 -->
                            <div class="WrappertransactionResult resultShow success">
                                <div class="transactionResult ">
                                    <div class="transaction_resultShow">
                                        <div class="transaction_resultDisplay">
                                            <div class="icon-symbol"></div>
                                        </div>
                                        <p class="transaction_resultTitle"><span class="language_replace">存款完成</span></p>
                                        <p class="transaction_resultDesc"><span class="language_replace">您存款的金額已經追加至您的錢包!</span></p>
                                    </div>

                                    <!-- <div class="transaction_currency">
                                    <span class="transaction_amountTitle"><span class="language_replace">金額</span></span>
                                    <span class="transaction_currencyType"><span class="language_replace">$</span></span>
                                    <div class="transaction_currencyAmount">2.2300</div>
                                </div> -->
                                </div>
                                <div class="transaction_detail">

                                    <div class="item-detail">
                                        <div class="title language_replace">
                                            交易時間
                                        </div>
                                        <div class="data">
                                            <span class="transaction_date" id="orderdate"></span><span
                                                class="transaction_time" style="display: none">18:10:30</span>
                                        </div>
                                    </div>
                                    <div class="item-detail">
                                        <div class="title language_replace">
                                            本次存款金額
                                        </div>
                                        <div class="data" id="amount"></div>
                                    </div>
                                    <div class="item-detail" style="display: none">
                                        <div class="title language_replace">
                                            手續費
                                        </div>
                                        <div class="data">2</div>
                                    </div>
                                    <div class="item-detail" style="display: none">
                                        <div class="title language_replace">Bonus</div>
                                        <div class="data">20</div>
                                    </div>
                                    <div class="item-detail balance">
                                        <div class="title language_replace">
                                            合計
                                        </div>
                                        <div class="data" id="totalamount"></div>
                                    </div>

                                </div>

                                <div class="transaction_recordLink" style="display: none">
                                    <p class="">
                                        <span class="language_replace">至</span>
                                        <span class="wallet_record"><i class="icon-wallet"></i><span class="language_replace ">錢包</span></span>
                                        <span class="language_replace">查看交易紀錄</span>
                                    </p>
                                </div>

                            </div>

                        </div>
                    </div>
                </div>

                <div class="btn-container" style="display: none">
                    <button class="btn btn-outline-primary" data-deposite="" type="button">
                        <span class="language_replace">回到首頁</span>
                    </button>
                    <button class="btn btn-primary" data-deposite="" data-toggle=""
                        data-target="">
                        <span class="language_replace">繼續存款</span>
                    </button>
                </div>
            </section>
        </div>
    </div>



    <!-- Modal 有溫馨提醒-->
    <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="depositSucc" aria-hidden="true"
        id="depositSucc">
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

    <script src="../src/lib/jquery/jquery.min.js"></script>
    <script src="../src/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="../src/js/wallet.js"></script>

</body>

</html>
