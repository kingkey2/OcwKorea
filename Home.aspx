<%@ Page Language="C#" %>

<%
    int RValue;
    string Token;
    string MarqueeText = "";
    string Version = EWinWeb.Version;
    string Bulletin = string.Empty;
    string FileData= string.Empty;
    string isModify = "0";
    string[] stringSeparators = new string[] { "&&_" };
    string[] Separators;
    Random R = new Random();

    EWin.Lobby.APIResult Result;
    EWin.Lobby.LobbyAPI LobbyAPI = new EWin.Lobby.LobbyAPI();

    RValue = R.Next(100000, 9999999);
    Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());
    Result = LobbyAPI.GetCompanyMarqueeText(Token, Guid.NewGuid().ToString());
    if (Result.Result == EWin.Lobby.enumResult.OK)
    {
        MarqueeText = Result.Message;
    }

    try { 
        if (System.IO.File.Exists(Server.MapPath("/App_Data/Bulletin.txt"))) {
            FileData = System.IO.File.ReadAllText(Server.MapPath("/App_Data/Bulletin.txt"));
            if (string.IsNullOrEmpty(FileData) == false) {
                Separators = FileData.Split(stringSeparators,StringSplitOptions.None);
                Bulletin = Separators[0];
                Bulletin = Bulletin.Replace("\r", "<br />").Replace("\n", string.Empty);
                if (Separators.Length >1) {
                    isModify = Separators[1];
                }

                if (isModify == "1") {
                    Response.Redirect("Maintain.aspx");
                }
            }
        }
    }
    catch (Exception ex) {};
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BET 파라다이스</title>
    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="css/icons.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/global.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/games.css" type="text/css" />
    <link rel="stylesheet" href="css/layoutAdj.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/toast.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="Scripts/OutSrc/lib/swiper/css/swiper-bundle.min.css" type="text/css" />
</head>
<script type="text/javascript" src="/Scripts/Common.js"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
<script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="Scripts/OutSrc/lib/swiper/js/swiper-bundle.min.js"></script>
<script type="text/javascript">
    if (self != top) {
        window.parent.API_LoadingStart();
    }

    var c = new common();
    var ui = new uiControl();
    var mlp;
    var lang;
    var WebInfo;
    var marqueeText = "<%=MarqueeText%>";
    var hasBulletin = <%=(string.IsNullOrEmpty(Bulletin) ? "false" : "true")%>;
    var HotList;
    var v ="<%:Version%>";
    //temp
    var HotCasino = [
        {
            GameName: "401",
            GameBrand: "PP"
        },
        {
            GameName: "204",
            GameBrand: "PP"
        },
        {
            GameName: "baccarat-deluxe",
            GameBrand: "PG"
        },
        {
            GameName: "blackjack-us",
            GameBrand: "PG"
        },
        {
            GameName: "Baccarat5T2",
            GameBrand: "CG"
        },
        {
            GameName: "InternationalSicbo",
            GameBrand: "CG"
        }
    ];

    //temp
    var HotSlot = [
        {

            GameName: "blackjack-us",
            GameBrand: "PG"
        },
        {
            GameName: "rla",
            GameBrand: "PP"
        },
        {
            GameName: "bjmb",
            GameBrand: "PP"
        },
        {
            GameName: "blackjack-eu",
            GameBrand: "PG"
        },
        {
            GameName: "InternationalSicbo",
            GameBrand: "CG"
        },
        {
            GameName: "bjma",
            GameBrand: "PP"
        }
    ];

    var MyGames;

    var FavoGames;

    var FourGames = [
        {
            GameName: "EWinGaming",
            GameBrand: "EWin",
            Description: "FourGamesDescription01"
        },
        {
            GameName: "32",
            GameBrand: "KGS",
            Description: "FourGamesDescription02"
        },
        {
            GameName: "1",
            GameBrand: "PG",
            Description: "FourGamesDescription03"
        },
        {
            GameName: "7",
            GameBrand: "PG",
            Description: "FourGamesDescription04"
        },
        {
            GameName: "TaikoDrumMasterEX",
            GameBrand: "CG",
            Description: "FourGamesDescription05"
        },
        {
            GameName: "LineBrownDaydreamEX",
            GameBrand: "CG",
            Description:"FourGamesDescription06"
        }
    ];

    window.onload = init;

    function tempInit() {
        //document.getElementById('idCasinoItemGroup').innerHTML = "";
        //document.getElementById('idSlotItemGroup').innerHTML = "";

        /*
                for (var i = 0; i < HotList.length; i++) {
                    var gameItem = HotList[i];
        
                    if (gameItem.Categ != "Baccarat" && gameItem.Categ != "Classic") {
                        continue;
                    }
        
                    var GI = c.getTemplate("idTempGameItem");
                    var GI_img = GI.querySelector("img");
                    var GI_a = GI.querySelector(".OpenGame");
        
                    if (GI_img != null) {
                        GI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + gameItem.GameName + ".png";
                        GI_img.onerror = new Function("setDefaultIcon('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    }
        
                    c.setClassText(GI, "GameCode", null, window.parent.API_GetGameLang(1, gameItem.GameBrand, gameItem.GameName));
                    GI_a.onclick = new Function("window.parent.API_OpenGameCode('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
        
                    if (gameItem.Categ == "Baccarat") {
                        document.getElementById('idCasinoItemGroup').appendChild(GI);
                    } else if (gameItem.Categ == "Classic") {
                        document.getElementById('idSlotItemGroup').appendChild(GI);
                    }
                }
        */
        //init my game
        document.getElementById('idMyGameItemGroup').innerHTML = "";
        if (window.localStorage.getItem('MyGames')) {
            MyGames = JSON.parse(window.localStorage.getItem('MyGames'));

            if (MyGames && MyGames.length > 0) {
                document.getElementById("idMyGameTitle").classList.remove("is-hide");
            } else {
                document.getElementById("idMyGameTitle").classList.add("is-hide");
            }

            for (var i = 0; i < MyGames.length; i++) {
                var gameItem = MyGames[i];
                var GI = c.getTemplate("idMyGameItem");
                var GI_img = GI.querySelector("img");
                var GI_a = GI.querySelector(".OpenGame");

                if (GI_img != null) {
                    GI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + gameItem.GameName + ".png";
                    GI_img.onerror = new Function("setDefaultIcon('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                }

                c.setClassText(GI, "GameCode", null, window.parent.API_GetGameLang(1, gameItem.GameBrand, gameItem.GameName));
                GI_a.onclick = new Function("window.parent.API_OpenGameCode('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                document.getElementById('idMyGameItemGroup').appendChild(GI);
            }
        } else {
            document.getElementById("idMyGameTitle").classList.add("is-hide");
        }

        //init my game
        document.getElementById('idFavoGameItemGroup').innerHTML = "";
        FavoGames = window.parent.API_GetFavoGames();
        if (FavoGames) {
            if (FavoGames && FavoGames.length > 0) {
                document.getElementById("idFavoGameTitle").classList.remove("is-hide");
            } else {
                document.getElementById("idFavoGameTitle").classList.add("is-hide");
            }

            for (var i = 0; i < FavoGames.length; i++) {
                var gameItem = FavoGames[i];
                var GI = c.getTemplate("idMyGameItem");
                var GI_img = GI.querySelector("img");
                var GI_a = GI.querySelector(".OpenGame");

                if (GI_img != null) {
                    GI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + gameItem.GameName + ".png";
                    GI_img.onerror = new Function("setDefaultIcon('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                }

                c.setClassText(GI, "GameCode", null, window.parent.API_GetGameLang(1, gameItem.GameBrand, gameItem.GameName));
                GI_a.onclick = new Function("window.parent.API_OpenGameCode('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                document.getElementById('idFavoGameItemGroup').appendChild(GI);
            }
        } else {
            document.getElementById("idFavoGameTitle").classList.add("is-hide");
        }


        setFourGame(0);
        setFourGame(1);
        setFourGame(2);
        setFourGame(3);
        setFourGame(4);
        setFourGame(5);
    }

    function refreshMyGmae() {

        var idMyGameItemGroup = document.getElementById('idMyGameItemGroup');
        if (idMyGameItemGroup) {
            idMyGameItemGroup.innerHTML = "";
            if (window.localStorage.getItem('MyGames')) {
                var MyGames = JSON.parse(window.localStorage.getItem('MyGames'));

                if (MyGames && MyGames.length > 0) {
                    document.getElementById("idMyGameTitle").classList.remove("is-hide");
                } else {
                    document.getElementById("idMyGameTitle").classList.add("is-hide");
                }

                for (var i = 0; i < MyGames.length; i++) {
                    var gameItem = MyGames[i];
                    var GI = c.getTemplate("idMyGameItem");
                    var GI_img = GI.querySelector("img");
                    var GI_a = GI.querySelector(".OpenGame");

                    if (GI_img != null) {
                        GI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + gameItem.GameName + ".png";
                        GI_img.onerror = new Function("setDefaultIcon('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    }

                    c.setClassText(GI, "GameCode", null, window.parent.API_GetGameLang(1, gameItem.GameBrand, gameItem.GameName));
                    GI_a.onclick = new Function("window.parent.API_OpenGameCode('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    idMyGameItemGroup.appendChild(GI);
                }
            } else {
                document.getElementById("idMyGameTitle").classList.add("is-hide");
            }
        }
    }

    function refreshFavoGame() {
        FavoGames = window.parent.API_GetFavoGames();
        var idFavoGameItemGroup = document.getElementById('idFavoGameItemGroup');
        if (idFavoGameItemGroup) {
            idFavoGameItemGroup.innerHTML = "";
            if (FavoGames) {
                if (FavoGames && FavoGames.length > 0) {
                    document.getElementById("idFavoGameTitle").classList.remove("is-hide");
                } else {
                    document.getElementById("idFavoGameTitle").classList.add("is-hide");
                }

                for (var i = 0; i < FavoGames.length; i++) {
                    var gameItem = FavoGames[i];
                    var GI = c.getTemplate("idMyGameItem");
                    var GI_img = GI.querySelector("img");
                    var GI_a = GI.querySelector(".OpenGame");

                    if (GI_img != null) {
                        GI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + gameItem.GameName + ".png";
                        GI_img.onerror = new Function("setDefaultIcon('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    }

                    c.setClassText(GI, "GameCode", null, window.parent.API_GetGameLang(1, gameItem.GameBrand, gameItem.GameName));
                    GI_a.onclick = new Function("window.parent.API_OpenGameCode('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    document.getElementById('idFavoGameItemGroup').appendChild(GI);
                }
            } else {
                document.getElementById("idFavoGameTitle").classList.add("is-hide");
            }
        }
    }

    function setFourGame(index) {
        var tempGI;
        var tempGI_img;
        var tempGI_a;
        var temp_gameItem;

        temp_gameItem = FourGames[index];
        tempGI = document.getElementById("idRecommend" + (index + 1));
        tempGI_img = tempGI.querySelector("img");
        tempGI_a = tempGI.querySelector("a");

        if (tempGI_img != null) {
            tempGI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + temp_gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + temp_gameItem.GameName + ".png";
            tempGI_img.onerror = new Function("setDefaultIcon('" + temp_gameItem.GameBrand + "', '" + temp_gameItem.GameName + "')");
        }

        c.setClassText(tempGI, "gameName", null, window.parent.API_GetGameLang(1, temp_gameItem.GameBrand, temp_gameItem.GameName));
        c.setClassText(tempGI, "gameDescription", null, mlp.getLanguageKey(temp_gameItem.Description));
        tempGI_a.onclick = new Function("window.parent.API_OpenGameCode('" + temp_gameItem.GameBrand + "', '" + temp_gameItem.GameName + "')");
    }

    function gameInitByOther() {
        // 輪播 banner
        //var swiper = new Swiper("#hero-thumb", {
        //    slidesPerView: 4,
        //    watchSlidesVisibility: true,
        //    watchSlidesProgress: true,
        //    preventClicks: true,
        //});

        var swiper2 = new Swiper("#hero", {
            loop: true,
            slidesPerView: 1,
            autoplay: {
                delay: 20000,
                disableOnInteraction: false
            },
            pagination: {
                el: "#hero .swiper-pagination",
                clickable: true,
            },
            navigation: {
                nextEl: "#hero .swiper-button-next",
                prevEl: "#hero .swiper-button-prev"
            },
            //thumbs: {
            //    swiper: swiper
            //}

        });

        document.addEventListener('mouseenter', event => {
            const el = event.target;
            if (el && el.matches && el.matches('#hero .swiper-container')) {
                el.swiper.autoplay.stop();
                el.classList.add('swiper-paused');

                const activeNavItem = el.querySelector('#hero .swiper-pagination-bullet-active');
                activeNavItem.style.animationPlayState = "paused";
            }
        }, true);

        document.addEventListener('mouseleave', event => {
            const el = event.target;
            if (el && el.matches && el.matches('#hero .swiper-container')) {
                el.swiper.autoplay.start();
                el.classList.remove('swiper-paused');

                const activeNavItem = el.querySelector('#hero .swiper-pagination-bullet-active');

                activeNavItem.classList.remove('swiper-pagination-bullet-active');

                setTimeout(() => {
                    activeNavItem.classList.add('swiper-pagination-bullet-active');
                }, 10);
            }
        }, true);


        // 熱門賭場
        var swiper3 = new Swiper("#pop-casino", {
            loop: false,
            slidesPerView: 3,
            freeMode: true,
            navigation: {
                nextEl: "#pop-casino .swiper-button-next",
            },
            breakpoints: {
                540: {
                    slidesPerView: 4,
                    freeMode: false,
                },
                576: {
                    slidesPerView: 5,
                    freeMode: false,
                },
                769: {
                    slidesPerView: 3,
                    freeMode: false,
                }
            }
        });

        // 熱門老虎機
        var swiper4 = new Swiper("#pop-slot", {
            loop: false,
            slidesPerView: 3,

            navigation: {
                nextEl: "#pop-slot .swiper-button-next",
            },
            breakpoints: {
                540: {
                    slidesPerView: 4,
                    freeMode: false,
                },
                576: {
                    slidesPerView: 5,
                    freeMode: false,
                },
                769: {
                    slidesPerView: 3,
                    freeMode: false,
                }

            }
        });

        // 註冊步驟
        var swiper5 = new Swiper("#register-steps", {
            // loop: true,
            // slidesPerView: 2,
            slidesPerView: "auto",
            // freeMode: true,
            // centeredSlides: true,


            breakpoints: {
                // 540: {
                //     slidesPerView: 2,
                //     freeMode: false,
                // },
                // 576: {
                //     slidesPerView: 5,
                //     freeMode: false,
                // },
                769: {
                    slidesPerView: 3,
                    freeMode: false,
                    enabled: false
                }

            }
        });

    }

    function changeMultImg() {
        var multImgs = $(".MultImg");
        for (var i = 0; i < multImgs.length; i++) {
            let multImg = multImgs.eq(i);
            let src = multImg.data("src");
            let extension = multImg.data("extension");
            let imgsrc = src + lang + extension;
            multImg.attr("src", imgsrc);
        }
    }

    function updateBaseInfo() {
        tempInit();
        gameInitByOther();
        changeMultImg();
    }
   
    

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }
      

        WebInfo = window.parent.API_GetWebInfo();
        p = window.parent.API_GetLobbyAPI();
        lang = window.parent.API_GetLang();

        $('head').append(`<link href="/css/Home.${lang}.css" rel="stylesheet" id="HomeCss" />`);

        mlp = new multiLanguage(v);

        if (WebInfo.IsOpenGame) {
            WebInfo.IsOpenGame = false;
            window.parent.SwitchGameHeader(0);
        }

        HotList = window.parent.API_GetGameList(1);
        window.parent.API_LoadingStart();
        mlp.loadLanguage(lang, function () {
            /*if (WebInfo.UserLogined) {
                document.getElementById("idRegisterBonus").classList.add("is-hide");
            }*/


            window.parent.API_LoadingEnd();
            if (p != null) {
                updateBaseInfo();
                if (marqueeText) {
                    document.getElementById("idMarqueeText").innerText = marqueeText;
                }
                window.parent.sleep(500).then(() => {
                    if (WebInfo.UserLogined) {
                        document.getElementById("idGoRegBtn").classList.add("is-hide");
                        $(".register-list").hide();
                    }
                })
            } else {
                window.parent.showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路錯誤"), function () {
                    window.parent.location.href = "index.aspx";
                });
            }
        });

        setBulletinBoard();
    }

    /*function setBulletinBoard() {
        var GUID = Math.uuid();
        p.GetBulletinBoard(GUID, function (success, o) {
            if (success) {
                if (o.Result == 0) {
                    var ParentMain = document.getElementById("idBulletinBoardContent");
                    ParentMain.innerHTML = "";

                      if (o.Datas.length > 0) {
                        var RecordDom;
                        //var numGameTotalValidBetValue = new BigNumber(0);
                        for (var i = 0; i < o.Datas.length; i++) {
                            var record = o.Datas[i];
                   
                            RecordDom = c.getTemplate("idTempBulletinBoard");
                        
                            var recordDate = new Date(parseInt(record.CreateDate.replace(')/', '').replace('/Date(', '')));
                            var date = recordDate.getFullYear() + '.' + (recordDate.getMonth()+1)+'.'+recordDate.getDate();
                            c.setClassText(RecordDom, "CreateDate", null, date);
                            c.setClassText(RecordDom, "BulletinTitle", null, record.BulletinTitle);
   
   

                         RecordDom.onclick =   new Function("window.parent.showMessageOK('','" + record.BulletinContent + "')");
                               
                           
                            ParentMain.appendChild(RecordDom);
           
                        }
                    }
                }
            }
        });
    }*/

    function EWinEventNotify(eventName, isDisplay, param) {
        switch (eventName) {
            case "LoginState":
                //updateBaseInfo();

                break;
            case "BalanceChange":
                break;
            case "SetLanguage":
                lang = param;

                mlp.loadLanguage(lang, function () {
                    updateBaseInfo();
                });

                $('#HomeCss').remove();
                $('head').append(`<link href="/css/Home.${lang}.css" rel="stylesheet" id="HomeCss" />`);

                break;
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

    function openHotArticle(orgin) {
        if (!orgin) {
            orgin = "guides";
        }

        orgin = "Article/" + orgin + ".html";

        window.parent.API_LoadPage("Article", orgin);
    }

    function setDefaultIcon(brand, name) {
        var img = event.currentTarget;
        img.onerror = null;
        img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + brand + "/PC/" + WebInfo.Lang + "/" + name + ".png";
    }

</script>
<body>
    <div class="page-container">
     
        <!-- 輪播 banner -->
        <div class="hero-container">
            <div class="swiper-container hero-main" id="hero">
                <div class="swiper-wrapper">
                    <div class="swiper-slide" style="background-image: linear-gradient(to right, #030003 0%, #030003 50%, #030003 51%, #030003 100%);">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-09.jpg" class="desktop">
                                <img src="images/games/hero/hero-09-m.jpg" class="mobile">
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide" style="background-color: #020d48;">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-10.jpg?20211004" class="desktop">
                                <img src="images/games/hero/hero-10-m.jpg" class="mobile">
                            </div>
                            <!--div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">貂蟬の甘い罠</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace" style="font-size: .7em">三国志で大人気のあの貂蝉がスロットに登場、呂布と董卓を翻弄し、歴史を大きく転換させた三国志随一の美人が皆さんを誘惑しますよー！</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('PG', '1')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                </div>
                            </div-->
                        </div>
                    </div>
                    <div class="swiper-slide" style="background-image: linear-gradient(to right, #09887b 0%, #09887b 50%, #00252b 51%, #00252b 100%);">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-11.jpg?20211004" class="desktop">
                                <img src="images/games/hero/hero-11-m.jpg" class="mobile">
                            </div>
                            <!--div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">貂蟬の甘い罠</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace" style="font-size: .7em">三国志で大人気のあの貂蝉がスロットに登場、呂布と董卓を翻弄し、歴史を大きく転換させた三国志随一の美人が皆さんを誘惑しますよー！</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('PG', '1')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                </div>
                            </div-->
                        </div>
                    </div>
					<div class="swiper-slide" style="background-image: linear-gradient(to right, #200512 0%, #200512 50%, #200512 51%, #200512 100%);">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-12.jpg?20211004" class="desktop">
                                <img src="images/games/hero/hero-12-m.jpg" class="mobile">
                            </div>
                            <!--div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">貂蟬の甘い罠</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace" style="font-size: .7em">三国志で大人気のあの貂蝉がスロットに登場、呂布と董卓を翻弄し、歴史を大きく転換させた三国志随一の美人が皆さんを誘惑しますよー！</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('PG', '1')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                </div>
                            </div-->
                        </div>
                    </div>
					<div class="swiper-slide" style="background-image: linear-gradient(to right, #251455 0%, #251455 50%, #251455 51%, #251455 100%);">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-13.jpg?20211004" class="desktop">
                                <img src="images/games/hero/hero-13-m.jpg" class="mobile">
                            </div>
                            <!--div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">貂蟬の甘い罠</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace" style="font-size: .7em">三国志で大人気のあの貂蝉がスロットに登場、呂布と董卓を翻弄し、歴史を大きく転換させた三国志随一の美人が皆さんを誘惑しますよー！</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('PG', '1')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                </div>
                            </div-->
                        </div>
                    </div>
<%--                    <div class="swiper-slide" style="background: #efd21e">
                        <div class="hero-item">
                            <a onclick="window.parent.API_LoadPage('OpenBonusDeposit_03012022', '/Activity/OpenBonusDeposit_03012022/index.html')">
                                <div class="img-wrap">
                                    <img src="images/games/hero/OpenBonusDeposit-10.jpg" class="desktop">
                                    <img src="images/games/hero/OpenBonusDeposit-10-m.jpg" class="mobile">
                                </div>
                            </a>
                        </div>
                    </div>
                    <div class="swiper-slide" style="background-image: linear-gradient(to right, #29040b 0%, #29040b 50%, #341f26 51%, #341f26 100%);">
                        <div class="hero-item">
                            <a onclick="window.parent.API_LoadPage('OpenIntroBonus_03012022', '/Activity/OpenIntroBonus_03012022/index.html')">
                                <div class="img-wrap">
                                    <img src="images/games/hero/OpenIntroBonus-11.jpg" class="desktop">
                                    <img src="images/games/hero/OpenIntroBonus-11-m.jpg" class="mobile">
                                </div>
                            </a>
                        </div>
                    </div>--%>
                    <div class="swiper-slide" style="background-image: linear-gradient(to right, #c1a679 0%, #c1a679 50%, #11100f 51%, #11100f 100%);">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-02.jpg?20211007" class="desktop">
                                <img src="images/games/hero/hero-02-m.jpg" class="mobile">
                            </div>
                            <div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">真人百家樂</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace" style="font-size: .7em">真人即時視訊，公平公正的真實百家樂遊戲!</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('EWin', 'EWinGaming')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                    <!--p class="hero-info-period language_replace">活動期間: 2021年9月24日午前0時00分開始</p-->
                                </div>
                            </div>
                        </div>
                    </div>


                    <!-- <div class="swiper-slide" style="background-color: #6f3f17;">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-07.jpg?20211004" class="desktop">
                                <img src="images/games/hero/hero-07-m.jpg" class="mobile">
                            </div>
                            <div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">真人百家樂</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace">真人即時視訊，公平公正的真實百家樂遊戲!</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('PP', '401')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                    <p class="hero-info-period language_replace">活動期間: 2021年9月24日午前0時00分開始</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide" style="background-color: #8f0000;">
                        <div class="hero-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/hero-08.jpg?20211004" class="desktop">
                                <img src="images/games/hero/hero-08-m.jpg" class="mobile">
                            </div>
                            <div class="hero-info">
                                <div class="hero-info-inner">
                                    <div class="hero-info-title language_replace">超級幸運輪</div>
                                    <div class="hero-info-text">
                                        <p class="language_replace">活動期間儲值，享10%額外獎勵金! 沒有儲值次數限制!</p>
                                    </div>
                                    <a onclick="window.parent.API_OpenGameCode('PP', '801')" class="btn btn-primary">
                                        <span class="language_replace">Game Now</span>
                                    </a>
                                    <p class="hero-info-period language_replace">活動期間: 2021年9月24日午前0時00分開始</p>
                                </div>
                            </div>
                        </div>
                    </div> -->
                </div>
                <div class="swiper-pagination"></div>
                <div class="swiper-button-prev"></div>
                <div class="swiper-button-next"></div>
            </div>
            <%--     <div class="swiper-container hero-thumb" id="hero-thumb">
                <div class="swiper-wrapper">
                    <div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-06.jpg?20211004">
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-07.jpg?20211004">
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-08.jpg?20211004">
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-02.jpg?20211004">
                            </div>
                        </div>
                    </div>
                   
                    <!--<div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-03.jpg">
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-04.jpg">
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <div class="thumb-item">
                            <div class="img-wrap">
                                <img src="images/games/hero/thumb-05.jpg">
                            </div>
                        </div>
                    </div> -->
                </div>
            </div>--%>
        </div>

        <main class="main-container">
            <!-- 最新消息 -->
            <section class="section-wrap news">
                <div class="news-inner">
                    <div class="news-item">
                        <div class="news-item-inner">
                            <a class="news-item-link"></a>
                            <i class="icon-news"></i>
                            <div id="" class="marquee">
                                <p id="idMarqueeText" class="marqueeText"></p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <div class="main-contain">

                <!-- 左側 - 遊戲分類-->
                <aside class="Sidebar_Left">
                    <nav class="section-wrap section-category category-game">

                        <div onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx?Category=Live&SubCategory=Baccarat')" class="category-item category-casino cat-rwd">
                            <div class="category-item-inner">
                                <div class="content">
                                    <div class="img-wrap">
                                        <img src="images/games/sidebar_category_casino.jpg">
                                    </div>
                                    <div class="detail">
                                        <div class="text">
                                            <h3 class="title language_replace">賭場遊戲</h3>
                                            <div class="desc">
                                                <p class="language_replace">真人的即時視訊遊戲</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx?Category=Live')" class="category-item category-classic cat-rwd">
                            <div class="category-item-inner">
                                <div class="content">
                                    <div class="img-wrap">
                                        <img src="images/games/sidebar_category_classic.jpg">
                                    </div>
                                    <div class="detail">
                                        <div class="text">
                                            <h3 class="title language_replace">經典遊戲</h3>
                                            <div class="desc">
                                                <p class="language_replace">廣受歡迎的精選遊戲</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%--<div onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx?Category=Sports')" class="category-item category-sport cat-rwd">
                            <div class="category-item-inner">
                                <div class="content">
                                    <div class="img-wrap">
                                        <img src="images/games/sidebar_category_sport.jpg">
                                    </div>
                                    <div class="detail">
                                        <div class="text">
                                            <h3 class="title language_replace">體育遊戲</h3>
                                            <div class="desc">
                                                <p class="language_replace">刺激的體育競賽遊戲</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>--%>
                        <div onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx?Category=Slot')" class="category-item category-slot cat-rwd">
                            <div class="category-item-inner">
                                <div class="content">
                                    <div class="img-wrap">
                                        <img src="images/games/sidebar_category_slot.jpg">
                                    </div>
                                    <div class="detail">
                                        <div class="text">
                                            <h3 class="title language_replace">老虎機遊戲</h3>
                                            <div class="desc">
                                                <p class="language_replace">最新最好玩的不敗遊戲</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </nav>
                </aside>

                <div class="page-content">
                    <!-- 大推遊戲 -->
                    <section class="section-wrap push">
                        <div class="wrap-box">
                            <div class="game-rules" onclick="openHotArticle('guide-03')">
                                <img src="images/games/rules_game_n_s.jpg" class="mobile" alt="">
                                <img src="images/games/rules_game_n.jpg" class="desk" alt="">
                                <span class="btn btn-primary language_replace">規則介紹</span>
                            </div>
                        </div>
                        <!--div class="wrap-box">
                            <div class="game-play" onclick="window.parent.API_OpenGameCode('EWin', 'EWinGaming')">
                                <img src="images/games/play_game_n_s.jpg" class="mobile" alt="">
                                <img src="images/games/play_game_n.jpg" class="desk" alt="">
                                <span class="btn btn-primary language_replace">開始遊戲</span>
                            </div>
                        </div-->
						<div class="wrap-box">
                            <div class="game-play" onclick="location.href='https://game.ewin-soft.com/GetDownloadLink.aspx?Tag=4AY6PD0F';">
                                <img src="images/games/app_game_n_s.png" class="mobile" alt="">
                                <img src="images/games/app_game_n.png" class="desk" alt="">
                                <span class="btn btn-primary language_replace">App Download</span>
                            </div>
                        </div>
                    </section>
                    <!-- 熱門遊戲 -->
                    <%--      <section class="section-wrap pop">
                        <!-- 熱門賭場遊戲 -->
                        <div class="wrap-box" style="display:none">
                            <div class="sec-title-container">
                                <div class="sec-title-wrap">
                                    <h3 class="title language_replace">熱門賭場遊戲</h3>
                                    <a class="text-link" onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx?Category=Baccarat&SubCategory=Hot', true)">
                                        <span class="language_replace">全部顯示</span><i class="icon-arrow-right"></i>
                                    </a>
                                </div>
                            </div>
                            <div class="swiper-container round-arrow theme-purple" id="pop-casino">
                                <div id="idCasinoItemGroup" class="swiper-wrapper">
                                </div>
                                <div class="swiper-button-next"></div>
                            </div>
                        </div>
                        <div class="wrap-box" style="display:none">
                            <div class="sec-title-container">
                                <div class="sec-title-wrap">
                                    <h3 class="title language_replace">人氣經典</h3>
                                    <a class="text-link" onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx?Category=Classic&SubCategory=Hot', true)">
                                        <span class="language_replace">全部顯示</span><i class="icon-arrow-right"></i>
                                    </a>
                                </div>
                            </div>
                            <div class="swiper-container round-arrow" id="pop-slot">
                                <div id="idSlotItemGroup" class="swiper-wrapper">
                                </div>
                                <div class="swiper-button-next"></div>
                            </div>
                        </div>
                    </section>--%>

                    <!-- 獎勵步驟 -->
                    <section class="section-wrap register-list is-hide" id="idRegisterBonus">
                        <div class="sec-title-container">
                            <div class="sec-title-wrap">
                                <h3 class="title language_replace">簡單三步驟拿獎勵</h3>
                            </div>
                        </div>
                        <div class="register-steps">
                            <div id="register-steps" class="swiper-container">
                                <div class="swiper-wrapper">
                                    <div class="swiper-slide">
                                        <div class="step-item step-1">
                                            <div class="step-item-inner">
                                                <span class="num">1</span>
                                                <div class="content">
                                                    <h3 class="title language_replace">60秒註冊</h3>
                                                    <div class="img-wrap">
                                                        <img class="MultImg" data-src="images/games/register_step_01_" data-extension=".jpg" src="images/games/register_step_01_JPN.jpg">
                                                    </div>
                                                    <div class="desc">
                                                        <span class="language_replace">免費且快速的註冊帳號!</span>
                                                        <span class="language_replace">輸入基本資料到完成登入只需短短1分鐘!</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="swiper-slide">
                                        <div class="step-item step-2">
                                            <div class="step-item-inner">
                                                <span class="num">2</span>
                                                <div class="content">
                                                    <h3 class="title language_replace">簡單儲值</h3>
                                                    <div class="img-wrap">
                                                        <img class="MultImg" data-src="images/games/register_step_02_" data-extension=".jpg" src="images/games/register_step_02_JPN.jpg">
                                                    </div>
                                                    <div class="desc">
                                                        <span class="language_replace">選擇入金的管道，並完成入款，取得對應幣值的遊戲幣 Ocoin。</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="swiper-slide">
                                        <div class="step-item step-3">
                                            <div class="step-item-inner">
                                                <span class="num">3</span>
                                                <div class="content">
                                                    <h3 class="title language_replace">拿到獎勵!</h3>
                                                    <div class="img-wrap">
                                                        <img class="MultImg" data-src="images/games/register_step_03_" data-extension=".jpg" src="images/games/register_step_03_JPN.jpg">
                                                    </div>
                                                    <div class="desc">
                                                        <span class="language_replace">入金完成即可獲得專屬的獎勵，</span>
                                                        <span class="language_replace">立刻進入遊戲使用!!</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                        <div class="btn-container btn-register-steps">
                            <button id="idGoRegBtn" type="button" class="btn btn-primary" onclick="window.parent.API_LoadPage('Register', 'Register.aspx')"><span class="language_replace">馬上註冊</span></button>
                        </div>
                    </section>

                    <!-- 推薦遊戲 -->
                    <section class="section-wrap recommend">
                        <div class="sec-title-container">
                            <div class="sec-title-wrap">
                                <h3 class="title language_replace">來玩推薦的遊戲</h3>
                                <a class="text-link" onclick="window.parent.API_LoadPage('Casino', 'Casino.aspx', true)">
                                    <span class="language_replace">全部顯示</span><i class="icon-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                        <div class="box-item-container recommend-list">

                            <div id="idRecommend1" class="box-item">
                                <a class="box-item-link">
                                    <div class="box-item-inner">
                                        <div class="game-item">
                                            <div class="img-wrap">
                                                <img src="images/games/icon/icon-01.jpg">
                                            </div>
                                        </div>
                                        <div class="box-item-detail">
                                            <div class="box-item-title gameName">Texas Ｈold'em</div>
                                            <div class="box-item-desc language_replace gameDescription"></div>
                                        </div>
                                        <i class="icon-arrow-right circle"></i>
                                    </div>
                                </a>
                            </div>

                            <div id="idRecommend2" class="box-item">
                                <a class="box-item-link">
                                    <div class="box-item-inner">
                                        <div class="game-item">
                                            <div class="img-wrap">
                                                <img src="images/games/icon/icon-01.jpg">
                                            </div>
                                        </div>
                                        <div class="box-item-detail">
                                            <div class="box-item-title gameName">Texas Ｈold'em</div>
                                            <div class="box-item-desc language_replace gameDescription"></div>
                                        </div>
                                        <i class="icon-arrow-right circle"></i>
                                    </div>
                                </a>
                            </div>

                            <div id="idRecommend3" class="box-item">
                                <a class="box-item-link">
                                    <div class="box-item-inner">
                                        <div class="game-item">
                                            <div class="img-wrap">
                                                <img src="images/games/icon/icon-01.jpg">
                                            </div>
                                        </div>
                                        <div class="box-item-detail">
                                            <div class="box-item-title gameName">Texas Ｈold'em</div>
                                            <div class="box-item-desc language_replace gameDescription"></div>
                                        </div>
                                        <i class="icon-arrow-right circle"></i>
                                    </div>
                                </a>
                            </div>

                            <div id="idRecommend4" class="box-item">
                                <a class="box-item-link">
                                    <div class="box-item-inner">
                                        <div class="game-item">
                                            <div class="img-wrap">
                                                <img src="images/games/icon/icon-01.jpg">
                                            </div>
                                        </div>
                                        <div class="box-item-detail">
                                            <div class="box-item-title gameName">Texas Ｈold'em</div>
                                            <div class="box-item-desc language_replace gameDescription"></div>
                                        </div>
                                        <i class="icon-arrow-right circle"></i>
                                    </div>
                                </a>
                            </div>
                            <div id="idRecommend5" class="box-item">
                                <a class="box-item-link">
                                    <div class="box-item-inner">
                                        <div class="game-item">
                                            <div class="img-wrap">
                                                <img src="images/games/icon/icon-01.jpg">
                                            </div>
                                        </div>
                                        <div class="box-item-detail">
                                            <div class="box-item-title gameName">Texas Ｈold'em</div>
                                            <div class="box-item-desc language_replace gameDescription"></div>
                                        </div>
                                        <i class="icon-arrow-right circle"></i>
                                    </div>
                                </a>
                            </div>
                            <div id="idRecommend6" class="box-item">
                                <a class="box-item-link">
                                    <div class="box-item-inner">
                                        <div class="game-item">
                                            <div class="img-wrap">
                                                <img src="images/games/icon/icon-01.jpg">
                                            </div>
                                        </div>
                                        <div class="box-item-detail">
                                            <div class="box-item-title gameName">Texas Ｈold'em</div>
                                            <div class="box-item-desc language_replace gameDescription"></div>
                                        </div>
                                        <i class="icon-arrow-right circle"></i>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </section>

                    <!-- 我的遊戲 -->
                    <section class="section-wrap mygame">
                        <div class="sec-title-container">
                            <div id="idMyGameTitle" class="sec-title-wrap">
                                <h3 class="title language_replace">曾經遊玩</h3>
                            </div>
                        </div>
                        <div class="game-item-group" id="idMyGameItemGroup">
                            <%--   <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="images/games/icon/icon-01.jpg">
                                </div>
                            </div>
        
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="images/games/icon/icon-02.jpg">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="images/games/icon/icon-03.jpg">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="images/games/icon/icon-04.jpg">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>
                            <div class="game-item">
                                <a class="game-item-link" href="#"></a>
                                <div class="img-wrap">
                                    <img src="">
                                </div>
                            </div>--%>
                        </div>
                    </section>

                    <!-- 我的最愛 -->
                    <section class="section-wrap mygame">
                        <div class="sec-title-container">
                            <div id="idFavoGameTitle" class="sec-title-wrap">
                                <h3 class="title language_replace">我的最愛</h3>
                            </div>
                        </div>
                        <div class="game-item-group" id="idFavoGameItemGroup">
                        </div>
                    </section>


                    <!-- 右側客服 + 熱門文章 -->
                    <aside class="Sidebar_Right">
                        <section class="section-wrap section-category category-related">
                            <!-- eWIN Banner -->
                            <div class="category-item banner-activity b-01" onclick="">
                                <div class="category-item-inner">
                                    <div class="img-wrap b-cover">
                                        <img src="images/games/sidebar_category_activity_ewin.jpg?<%:Version%>">
                                    </div>
                                    <div class="img-wrap b-reflect">
                                        <img src="images/games/sidebar_category_activity_ewin.jpg?<%:Version%>">
                                    </div>
                                    <div class="b-bg"></div>
                                    <div class="content">
                                        <div class="detail">
                                            <%-- 
                                            <div class="logo">
                                                <div class="img-wrap">
                                                    <img src="images/logo/logo-ewin_w.svg" alt=""></div>
                                            </div>--%>
                                            <div class="intro">
                                                <h3 class="title language_replace">eWin 真人百家樂</h3>
                                                <p class="desc language_replace">真人即時視訊，公平公正百家樂</p>
                                            </div>
                                        </div>

                                        <div class="game-link">
                                            <button class="btn game-play language_replace" onclick="window.parent.API_OpenGameCode('EWin', 'EWinGaming')">玩遊戲</button>
                                            <%-- <button class="btn game-site language_replace">遊戲官網</button>--%>
                                        </div>
                                    </div>

                                </div>
                            </div>

                            <!-- Bti Banner -->
                    <%--        <div class="category-item banner-activity b-02" onclick="">
                                <div class="category-item-inner">
                                    <div class="img-wrap b-cover">
                                        <img src="images/games/sidebar_category_activity_bti_01.jpg">
                                    </div>
                                    <div class="img-wrap b-reflect">
                                        <img src="images/games/sidebar_category_activity_bti_01.jpg">
                                    </div>
                                    <div class="b-bg"></div>
                                    <div class="content">
                                        <div class="detail">
                                         
                                            <div class="logo">
                                                <div class="img-wrap">
                                                    <img src="images/logo/logo-Bti_w.png" alt=""></div>
                                            </div>
                                            <div class="intro">
                                                <h3 class="title language_replace">Bti 綜合娛樂游戲</h3>
                                                <p class="desc language_replace">提供1000+ 多種投注類型</p>
                                            </div>
                                        </div>
                                        <div class="game-link">
                                            <button class="btn game-play language_replace" onclick="window.parent.API_OpenGameCode('BTI', 'Sport')">玩遊戲</button>
                                        </div>
                                    </div>

                                </div>
                            </div>--%>
                            <!-- 熱門活動 -->
                         <%--   <div class="category-item category-activity cat-rwd" onclick="window.parent.showMessage('',mlp.getLanguageKey('即將開放'))">
                                <div class="category-item-inner">
                                    <div class="content">
                                        <h3 class="title language_replace">熱門活動</h3>
                                        <div class="img-wrap">
                                            <img src="images/games/sidebar_category_activity.jpg?20211014">
                                        </div>
                                    </div>
                                </div>
                            </div>--%>
                        </section>
                        <!-- 客服 -->
                        <!-- <div class="customer-service" onclick="window.parent.API_OpenServiceChat()">
                        <div class="text">
                           <h3 class="title language_replace">聯絡客服</h3>                         
                        </div>
                        <div class="img-wrap">
                         <img src="images/games/a-chi-service.svg">
                        </div>
                     </div> -->

                        <section class="section-wrap section-article">
                            <div class="sec-title-container">
                                <div class="sec-title-wrap">
                                    <a onclick="openHotArticle('guides')">
                                        <h3 class="title language_replace">熱門文章</h3>
                                    </a>
                                </div>
                                <div class="article-list">
                                    <ul class="article-list-inner">
                                        <!--li class="article-item">
                                            <a onclick="window.parent.API_LoadPage('guide_QnA', '/Article/guide_Q&A_jp.html', false)" class="content">
                                                <h4 class="title language_replace">よくあるＱ＆Ａ集</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <li class="article-item">
                                            <a onclick="window.parent.API_LoadPage('guide_Rolling', 'guide_Rolling.html', false)" class="content">
                                                <h4 class="title language_replace">ローリングのルール</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li-->
                                        <li class="article-item">
                                            <a onclick="window.parent.API_LoadPage('instructions-crypto', 'instructions-crypto.html', false)" class="content">
                                                <h4 class="title language_replace">虛擬貨幣存款說明</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>


                                        <li class="article-item">
                                            <a onclick="openHotArticle('guide-03')" class="content">
                                                <h4 class="title language_replace">百家樂攻略法 - 基礎規則篇</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <li class="article-item">
                                            <a onclick="openHotArticle('guide-04')" class="content">
                                                <h4 class="title language_replace">百家樂攻略法 - 中級篇</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <%--li class="article-item">
                                            <a onclick="openHotArticle('guide-05')" class="content">
                                                <h4 class="title language_replace">路單是? 百家樂的攻略 - 上級篇 1：珠盤路和大路</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <li class="article-item">
                                            <a onclick="openHotArticle('guide-06')" class="content">
                                                <h4 class="title language_replace">路單是? 百家樂的攻略 - 上級篇 2：大眼仔路</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <li class="article-item">
                                            <a onclick="openHotArticle('guide-07')" class="content">
                                                <h4 class="title language_replace">路單是? 百家樂的攻略 - 上級篇 3：小路</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <li class="article-item">
                                            <a onclick="openHotArticle('guide-08')" class="content">
                                                <h4 class="title language_replace">路單是? 百家樂的攻略 - 上級篇 4：小強路</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>--%>
                                        <li class="article-item">
                                            <a onclick="openHotArticle('guide-09')" class="content">
                                                <h4 class="title language_replace">老虎機攻略導覽</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li>
                                        <!--li class="article-item">
                                            <a onclick="openHotArticle('guide-10')" class="content">
                                                <h4 class="title language_replace">德州撲克攻略導覽</h4>
                                                <i class="icon-arrow-right"></i></a>
                                        </li-->
                                    </ul>
                                </div>

                            </div>
                        </section>
                    </aside>
                    <!-- 最新公告 -->
                    <section class="section-wrap news" style="display: none;">
                        <div class="sec-title-container">
                            <div class="sec-title-wrap">
                                <h3 class="title ">
                                    <!-- <i class="title-icon icon-service"></i> -->
                                    <span class="language_replace">最新公告</span></h3>
                            </div>
                        </div>
                        <div class="box-item-container news-list" id="idBulletinBoardContent">
                        </div>
                    </section>

                    <!-- 關於我們 -->
                    <section class="section-wrap  about" style="display: none">
                        <div class="sec-title-container">
                            <div class="sec-title-wrap">
                                <h3 class="title language_replace">關於我們</h3>
                            </div>
                        </div>
                        <article class="text-wrap">
                            <p class="language_replace">マハラジャ囊括世界上最知名的遊戲品牌，提供公正、公平的遊戲環境，免安裝的HTML5網頁技術提供了真人直播的經典遊戲，讓您不論用電腦、手機甚至電視，一個帳號多平台通用。更透過專有網路技術，達到最高規格的直播視訊同步速度與畫質，請您務必親自體驗。</p>
                            <p class="language_replace">而除了真人遊戲外，更提供了多款高水準的老虎機和體育遊戲，結合多元性、樂趣、公正公平於一身的就是マハラジャ，預祝您玩得開心，用的滿意。</p>
                            <p class="language_replace">我們也很重視您的意見，若有任何建議，還請不吝使用客服信箱告知。</p>
                        </article>
                    </section>

                    <!-- 浮動側邊 -->
					<%--
                    <div class="float_SideBar">
                        <div class="guide-QA" onclick="window.parent.API_LoadPage('guide_QnA', '/Article/guide_Q&A_jp.html', false)">
                            <a>
                                <div class="text">
                                    <h3 class="title language_replace">Q&A</h3>
                                </div>
                                <div class="img-wrap">
                                    <img src="images/games/a-chi-QA.svg">
                                </div>
                            </a>
                        </div>
                        <%--<div class="customer-service" onclick="window.parent.showMessage('','service@OCW888.com')" >--%>
                        <%--
                        <div class="customer-service" onclick="window.parent.showContactUs()">
                            <a>
                                <div class="text">
                                    <h3 class="title language_replace">聯絡客服</h3>
                                </div>
                                <div class="img-wrap">
                                    <img src="images/games/a-chi-service.svg">
                                </div>
                            </a>
                        </div>
                        <div class="Line-AddFriend"> 
                            <a onclick="window.open('https://lin.ee/KD05l9X')">
                                <!-- <span class="qr-code">
                                    <img src="https://qr-official.line.me/sid/M/476uzdvf.png?shortenUrl=true">
                                </span> -->
                                <span class="addFriend">
                                    <span class="logo"><img src="images/assets/LINE/Line_W.png" alt=""></span>                  
                                    <!-- <span class="text language_replace">加入好友</span> -->
                                </span>
                            </a>
                        </div>
                       
                    </div>--%>

                </div>

                <div id="idTempGameItem" class="is-hide">
                    <div class="swiper-slide">
                        <div class="game-item">
                            <a class="game-item-link"></a>
                            <div class="img-wrap">
                                <img src="">
                            </div>
                            <div class="game-item-info">
                                <h3 class="game-item-name GameCode"></h3>
                                <button type="button" class="btn btn-primary game-item-btn OpenGame"><span class="language_replace">GO</span></button>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="idMyGameItem" class="is-hide">
                    <div class="game-item">
                        <a class="game-item-link"></a>
                        <div class="img-wrap">
                            <img src="">
                        </div>
                        <div class="game-item-info">
                            <h3 class="game-item-name GameCode"></h3>
                            <button type="button" class="btn btn-primary game-item-btn OpenGame"><span class="language_replace">GO</span></button>
                        </div>
                    </div>
                </div>
                <div id="idTempBulletinBoard" class="is-hide">
                    <div class="box-item">
                        <a class="box-item-link">
                            <div class="box-item-inner normal">
                                <div class="box-item-detail">
                                    <div class="box-item-prep language_replace time CreateDate"></div>
                                    <div class="box-item-title BulletinTitle"></div>
                                </div>
                                <i class="icon-arrow-right circle detailbtn"></i>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </main>
        <!-- footer -->
        <!-- 合作夥伴 -->
        <section class="partner">
            <!-- <div class="container-fluid"> -->
            <div class="page-content">
                <div class="sec-title-container">
                    <div class="sec-title-wrap">
                        <h3 class="title language_replace">合作夥伴</h3>
                    </div>
                </div>
                <!-- <h3 class="title language_replace">合作夥伴</h3> -->
                <div class="logo">
                    <div class="row">
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-PG.png" alt="">
                            </div>
                        </div>
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-CG.png" alt="">
                            </div>
                        </div>
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-PP.png" alt="">
                            </div>
                        </div>
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-BG.png" alt="">
                            </div>
                        </div>
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-VA.png" alt="">
                            </div>
                        </div>
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-BNG.png" alt="">
                            </div>
                        </div>
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-pagcor.png" alt="">
                            </div>
                        </div>
                        <!--div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-Bti.png" alt="">
                            </div>
                        </div-->
                        <div class="logo-item">
                            <div class="img-crop">
                                <img src="images/logo/logo-zeus.png" alt="">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
	<script>
        function fullAdClose() {
            var idFullAD = document.getElementById("idFullAD");
            idFullAD.style.display = "none";
        }
    </script>
	
	<!-- 蓋板公告 -->
	<div id="idFullAD" class="popupFullAD">
		<div class="fullADDDiv">
			<div class="close" onClick="fullAdClose()"><i class="CloseIcon"></i></div>
			<div class="fullADDText">
				<!-- 公告寫在這裡面 -->
				<p><%=Bulletin %></p>
			</div>
		</div>	
	</div>
</body>
</html>
