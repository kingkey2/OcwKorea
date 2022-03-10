<%@ Page Language="C#" %>

<%
    Newtonsoft.Json.Linq.JObject jObject = EWinWeb.GetSettingJObj();
    string MaintainMessage = jObject["MaintainMessage"].ToString();


%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maharaja</title>
    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="css/icons.css" type="text/css" />
    <link rel="stylesheet" href="css/global.css" type="text/css" />  
</head>
<body>
        <div class="page-container">
           <!-- 系統錯誤 -->
        <div id="system-msg" class="">
            <div class="layout-full-screen system-msg-container">
                <div class="main-panel">

                    <section class="section-wrap">
                        <div class="logo">
                            <img src="images/assets/logo-icon.svg" alt="">
                        </div>
                        <div class="img-wrap img-error">
                            <img src="images/assets/feature-img-joker.svg">
                        </div>
                        <div class="text-wrap text-center">
                            <p>
                                <span class="language_replace">サイト点検中</span><br>　
                                <span class="language_replace">しばらく待ってから、お戻りください。</span><br><br>
                                <span class="language_replace"><%:MaintainMessage%></span>                                
                            </p> 
                            <!-- <p><span class="language_replace">您點選的頁面沒有反應，請回到首頁。</span></p> -->
                        </div>
                        <div class="btn-container">
                            <a href="index.aspx" class="square-link outline">
                                <i class="icon-home"></i>
                                <!-- <span class="language_replace">首頁</span> -->
                                <span class="language_replace">ホームページ</span>
                            </a>
                        </div>
                    </section>

                </div>
            </div>

        </div>

        </div>

   
        <!--<script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
        <script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>    
         <script src="Scripts/OutSrc/js/wallet.js"></script> 
        <script src="Scripts/OutSrc/lib/swiper/js/swiper-bundle.min.js"></script>
        <script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>-->
        <script type="text/javascript">
        
            //var lang = "JPN";
            //var mlp;

            //function init() {           
            //    //if (self==top) {
            //    //    window.location.href = "index.aspx";
            //    //}
            
            //    mlp = new multiLanguage();            
            //    //lang = window.parent.API_GetLang();
            //    mlp.loadLanguage(lang, function () {
            //        //window.parent.API_LoadingEnd();
            //        changePic(lang);
            //    });
            //}

            //function EWinEventNotify(eventName, isDisplay, param) {
            //    switch (eventName) {
            //        case "LoginState":
            //            //updateBaseInfo();

            //            break;
            //        case "BalanceChange":
            //            break;
            //        case "SetLanguage":
            //            lang = param;
            //            //mlp.loadLanguage(lang);
            //            changePic(lang);
            //            break;
            //    }
            //}
        
            //window.onload = init;
        
        </script>
        

   
</body>
</html>