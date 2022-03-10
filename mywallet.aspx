<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="Description" content="eWin Gaming">
    <title>eWin Gaming</title>

    <!-- CSS -->
    <link href="css/mainStyle.css" rel="stylesheet" type="text/css">
    <!-- Favicon and touch icons -->
    <link rel="shortcut icon" href="ico/favicon.png">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="ico/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="57x57" href="ico/apple-touch-icon-57-precomposed.png">
</head>
<body>
    <div class="pageWrapper">
        <div class="pageMain">
            <div class="pageHeader">
                <div class="backBtn" style="display:none;"><span class="fa fa-arrow-left"></span></div>
                <div class="pageTitle"><span class="language_replace">錢包中心</span></div>
                <div class="pageBtn_close"></div>
            </div>
            <div>
                <div class="switchTagDiv">
                    <!-- 使用中頁籤加上"active"-->
                    <div class="switchTagBtn active"><span class="language_replace">存款</span></div>
                    <div class="switchTagBtn"><span class="language_replace">取款</span></div>
                    <div class="switchTagBtn"><span class="language_replace">銀行卡</span></div>
                </div>
                <!-- 存款 -->
                <div class="pageMainCon" style="display:none;">
                    <div class="rowHalf">
                        <div class="rowTitle"><span class="language_replace">存款資料</span></div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">幣別</span></div>
                            <div class="rowRight"><span>CNY</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">最低存款金額</span></div>
                            <div class="rowRight"><span>500</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">最高存款金額</span></div>
                            <div class="rowRight"><span>10,000</span></div>
                        </div>
                    </div>
                    <div class="rowHalf">
                        <div class="rowTitle"><span class="language_replace">我要存款</span></div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">存款金額</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="請輸入存款金額">
                                <div class="rowBtnCon">
                                    <div class="sBtnOutline"><span class="language_replace">取消</span></div>
                                    <div class="sBtnFull"><span class="language_replace">送出</span></div>
                                </div>
                            </div>
                        </div>
                        <!-- -->
                    </div>
                    <div class="pageFooter">
                        <div class="rowTitle"><span class="language_replace">注意事項</span></div>
                        <div class="rowList">
                            <ol>
                                <li class="language_replace">敬愛的會員：虛擬帳號轉帳提供多家銀行帳號，"虛擬帳號轉帳"與"超商代碼支付"繳費成功後，即可到"帳戶訊息"查詢入帳資訊。</li>
                                <li class="language_replace">如您要"銀行轉帳"存款前，請您先聯繫您的代理商及客服人員告知存款，存款完成，請您正確填寫轉帳金額後"按下申請"。</li>
                                <li class="language_replace">晚上 12 點至凌晨 1 點之間為銀行固定維護時間，如於此期間進行轉帳，將於凌晨 1 點後入帳。</li>
                                <li class="language_replace">若使用ATM櫃員機，可選擇轉帳 / 轉出 ( 轉帳單筆上限3萬元 ) 。</li>
                                <li class="language_replace">本公司銀行帳號不定期變動，每次儲值前，請務必確認當前系統為您綁訂的專屬銀行帳號進行儲值，若您將款項儲值至非系統當前為您所綁定的專屬銀行帳號，本公司將不予承認該筆款項。</li>
                            </ol>
                        </div>

                    </div>
                </div>
                <!-- 取款 -->
                <div class="pageMainCon" style="display:none;">
                    <div class="rowHalf">
                        <div class="rowTitle"><span class="language_replace">取款資料</span></div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">幣別</span></div>
                            <div class="rowRight"><span>CNY</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">可用金額</span></div>
                            <div class="rowRight"><span>10,000</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">最低提款金額</span></div>
                            <div class="rowRight"><span>1,000</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">最高提款金額</span></div>
                            <div class="rowRight"><span>10,000</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">手續費</span></div>
                            <div class="rowRight"><span>1.2%</span></div>
                        </div>
                    </div>
                    <div class="rowHalf">
                        <div class="rowTitle"><span class="language_replace">我要提款</span></div>
                        <!-- -->
                        <div class="rowElm">
                            <div class="rowLeft"><span class="language_replace">選擇收款方式</span></div>
                            <div class="rowRight">
                                <div class="rowDropBtn">
                                    <div><span class="language_replace">[銀行名稱]</span><span class="language_replace">[支行名稱]</span></div>
                                    <div><span class="language_replace">[銀行卡號]</span></div>
                                </div>
                            </div>
                        </div>
                        <!--
                        <div class="rowElm">
                            <div class="rowLeft"><span>銀行名稱</span></div>
                            <div class="rowRight"><span>808(中國信託)</span></div>
                        </div>
                        <div class="rowElm">
                            <div class="rowLeft"><span>銀行所在省</span></div>
                            <div class="rowRight"><span>上海市</span></div>
                        </div>
                        <div class="rowElm">
                            <div class="rowLeft"><span>銀行城市/州/區</span></div>
                            <div class="rowRight"><span>徐匯區</span></div>
                        </div>
                        <div class="rowElm">
                            <div class="rowLeft"><span>支行名稱</span></div>
                            <div class="rowRight"><span>安和分行</span></div>
                        </div>
                        <div class="rowElm">
                            <div class="rowLeft"><span>帳戶名稱</span></div>
                            <div class="rowRight"><span>GGGG</span></div>
                        </div>
                        <div class="rowElm">
                            <div class="rowLeft"><span>銀行帳號</span></div>
                            <div class="rowRight"><span>107589536892</span></div>
                        </div>
                        -->
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">提款金額</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="請輸入提款金額">
                                <input type="text" language_replace="placeholder" placeholder="錢包密碼">
                                <div class="rowBtnCon">
                                    <div class="sBtnOutline"><span class="language_replace">取消</span></div>
                                    <div class="sBtnFull"><span class="language_replace">送出</span></div>
                                </div>
                            </div>
                        </div>
                        <!-- -->
                    </div>
                    <div class="pageFooter">
                        <div class="rowTitle"><span class="language_replace">注意事項</span></div>
                        <div class="rowList">
                            <ol>
                                <li class="language_replace">每次提款最少點數為1000點以上，請務必確認填寫之帳號，若提供的帳號錯誤，恕本公司無法負責。</li>
                                <li class="language_replace">每次提款最少點數為1000點以上，請務必確認填寫之帳號，若提供的帳號錯誤，恕本公司無法負責。</li>
                                <li class="language_replace">提款時需達到存款總金額的100%有效投注量才可提出申請。(PS:如利用本平臺進行任何洗錢詐騙行為，本公司保留權利審核會員帳戶或停權終止會員服務)</li>
                            </ol>
                        </div>
                    </div>
                </div>
                <!-- 銀行卡 -->
                <div class="pageMainCon">
                    <div class="rowHalf">
                        <div class="rowTitle"><span class="language_replace">我的銀行卡</span></div>
                        <!-- -->
                        <div class="rowElm2L">
                            <div class="rowLeft1T"><span class="language_replace">上海浦東發展銀行</span></div>
                            <div class="rowRight1T"><span class="language_replace">香港尖沙嘴支行</span></div>
                            <div class="rowLeft2T"><span class="language_replace">司徒浩南</span></div>
                            <div class="rowRight2T"><span>8945562698412</span></div>
                            <div class="rowBtnOutline"><span class="language_replace">可使用</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm2L">
                            <div class="rowLeft1T"><span class="language_replace">上海浦東發展銀行</span></div>
                            <div class="rowRight1T"><span class="language_replace">香港尖沙嘴支行</span></div>
                            <div class="rowLeft2T"><span class="language_replace">司徒浩南</span></div>
                            <div class="rowRight2T"><span>8945562698412</span></div>
                            <div class="rowBtnOutline"><span class="language_replace">可使用</span></div>
                        </div>
                        <!-- -->
                        <div class="rowElm2L">
                            <div class="rowLeft1T"><span class="language_replace">上海浦東發展銀行</span></div>
                            <div class="rowRight1T"><span class="language_replace">香港尖沙嘴支行</span></div>
                            <div class="rowLeft2T"><span class="language_replace">司徒浩南</span></div>
                            <div class="rowRight2T"><span class="language_replace">8945562698412</span></div>
                            <div class="rowBtnGray"><span class="language_replace">審核中</span></div>
                        </div>
                        <!-- -->

                    </div>
                    <div class="rowHalf">
                        <div class="rowTitle"><span class="language_replace">新增銀行卡</span></div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">銀行名稱</span></div>
                            <div class="rowRight">
                                <input type="text" placeholder="請輸入銀行名稱" language_replace="placeholder">
                            </div>
                        </div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">所在省</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="銀行所在省">
                            </div>
                        </div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">所在城市/州/區</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="請銀行所在城市/州/區">
                            </div>
                        </div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">支行名稱</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="請輸入支行名稱">
                            </div>
                        </div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">帳戶名稱</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="請輸入帳戶名稱">
                            </div>
                        </div>
                        <!-- -->
                        <div class="rowEdit">
                            <div class="rowLeft"><span class="language_replace">銀行帳號</span></div>
                            <div class="rowRight">
                                <input type="text" language_replace="placeholder" placeholder="請輸入銀行帳號">
                                <div class="rowBtnCon">
                                    <div class="sBtnOutline"><span  class="language_replace">取消</span></div>
                                    <div class="sBtnFull"><span  class="language_replace">送出</span></div>
                                </div>
                            </div>
                        </div>
                        <!-- -->
                    </div>
                    <div class="pageFooter">
                        <div class="rowTitle"><span class="language_replace">注意事項</span></div>
                        <div class="rowList">
                            <ol>
                                <li class="language_replace">每次提款最少點數為1000點以上，請務必確認填寫之帳號，若提供的帳號錯誤，恕本公司無法負責。</li>
                                <li class="language_replace">提款時需達到存款總金額的100%有效投注量才可提出申請。(PS:如利用本平臺進行任何洗錢詐騙行為，本公司保留權利審核會員帳戶或停權終止會員服務)</li>
                            </ol>
                        </div>
                    </div>
                </div>
                <!---->
            </div>
        </div>
    </div>

</body>
</html>