<%@ Page Language="C#" %>

<%
    string Version = EWinWeb.Version;
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maharaja</title>

    <link rel="stylesheet" href="Scripts/OutSrc/lib/bootstrap/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="Scripts/OutSrc/lib/swiper/css/swiper-bundle.min.css" type="text/css" />
    <link rel="stylesheet" href="css/icons.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/global.css?<%:Version%>" type="text/css" />
    <link rel="stylesheet" href="css/games.css" type="text/css" />

</head>
<script type="text/javascript" src="/Scripts/Common.js?<%:Version%>"></script>
<script type="text/javascript" src="/Scripts/UIControl.js"></script>
<script type="text/javascript" src="/Scripts/MultiLanguage.js"></script>
<script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
<script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
<script src="Scripts/OutSrc/lib/jquery/jquery.min.js"></script>
<script src="Scripts/OutSrc/lib/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="Scripts/OutSrc/lib/swiper/js/swiper-bundle.min.js"></script>
<%--<script src="Scripts/OutSrc/js/games.js"></script>--%>


<script type="text/javascript">      
    if (self != top) {
        window.parent.API_LoadingStart();
    }
    var ui = new uiControl();
    var c = new common();
    var mlp;
    var sumask;
    var Webinfo;
    var p;
    var nowCateg = "All";
    var nowSubCateg = "Hot";
    var LobbyGameList;
    var lang;
    var nowGameBrand = "All";
    var gameBrandList = [];
    var v = "<%:Version%>";
    function loginRecover() {
        window.location.href = "LoginRecover.aspx";
    }

    function selGameCategory(categoryCode, subCategoryCode) {
        var idGameItemTitle = document.getElementById("idGameItemTitle");
        var idGameItemSubTitle = document.getElementById("idGameItemSubTitle");
        nowCateg = categoryCode;

        idGameItemSubTitle.querySelectorAll('.subCateg').forEach(li => {
            idGameItemSubTitle.removeChild(li);
        });

        idGameItemTitle.querySelectorAll(".tab-item").forEach(GI => {
            GI.classList.remove("actived");

            if (GI.classList.contains("tab_" + nowCateg)) {
                GI.classList.add("actived");
                document.getElementById("idHeadText").innerText = mlp.getLanguageKey(nowCateg);
            }
        });

        if (categoryCode != 'All') {
            LobbyGameList.CategoryList.find(x => x.Categ == nowCateg).SubCategList.forEach(sc => {
                if (sc != 'Other' && sc != 'others') {
                    //上方tab
                    var li = document.createElement("li");
                    var li_a = document.createElement("a");
                    var li_a_span = document.createElement("span");

                    //上方tab
                    li_a.appendChild(li_a_span);
                    li.appendChild(li_a);
                    li.classList.add("tab-item");
                    li.classList.add("subCateg");
                    li.classList.add("tab_" + sc);
                    li_a.classList.add("tab-item-link");
                    li_a_span.innerText = mlp.getLanguageKey(sc);

                    li_a.onclick = new Function("selSubGameCategory('" + sc + "')");
                    idGameItemSubTitle.appendChild(li);
                }
            });
        }

        selSubGameCategory(subCategoryCode);
    }

    function selSubGameCategory(subCategoryCode) {
        var idGameItemSubTitle = document.getElementById("idGameItemSubTitle");

        if (subCategoryCode) {
            nowSubCateg = subCategoryCode;
        } else {
            nowSubCateg = "Hot";
        }


        idGameItemSubTitle.querySelectorAll(".tab-item").forEach(GI => {
            GI.classList.remove("actived");

            if (GI.classList.contains("tab_" + nowSubCateg)) {
                GI.classList.add("actived");
                //history.replaceState(null, null, "?" + "Category=" + categoryCode);
                history.replaceState(null, null, "?" + "Category=" + nowCateg + "&" + "SubCategory=" + nowSubCateg);
            }
        });

        showGame(nowCateg, nowSubCateg);
    }

    function changeGameBrand() {
        nowGameBrand = document.getElementById("idGameBrandSel").value;
        showGame(nowCateg, nowSubCateg);
    }

    function showGame(categoryCode, subCategoryCode) {
        var idNoGameExist = document.getElementById("idNoGameExist");
        idNoGameExist.classList.add("is-hide");

        document.querySelectorAll(".game-item").forEach(GI => {
            var orderVal = 3;

            if (subCategoryCode == 'Hot' || subCategoryCode == 'New') {
                GI.classList.remove("is-hide");

                if (categoryCode == "All") {

                } else {
                    if (!GI.classList.contains("gc_" + nowCateg)) {
                        GI.classList.add("is-hide");
                    }
                }

                if (GI.classList.contains("subGc_Hot") || GI.classList.contains("subGc_New")) {
                    if (GI.classList.contains("subGc_Hot") && GI.classList.contains("subGc_New")) {
                        orderVal = 0;
                    } else if (GI.classList.contains("subGc_" + subCategoryCode)) {
                        orderVal = 1;
                    } else {
                        orderVal = 2;
                    }
                }  
            } else {
                GI.classList.add("is-hide");

                if (categoryCode == "All") {
                    if (GI.classList.contains("subGc_" + subCategoryCode)) {
                        GI.classList.remove("is-hide");
                    }
                } else {
                    if (GI.classList.contains("gc_" + nowCateg) && GI.classList.contains("subGc_" + subCategoryCode)) {
                        GI.classList.remove("is-hide");
                    }
                }
            }

            GI.style.order = orderVal;


            //補上遊戲廠牌篩選
            if (nowGameBrand == "All") {

            } else {
                if (!GI.classList.contains("brand_" + nowGameBrand)) {
                    GI.classList.add("is-hide");
                }
            }
        });

        if (!document.querySelector(".game-item:not(.is-hide)")) {
            idNoGameExist.classList.remove("is-hide");
        }
    }

    function updateGameCode() {
        var idGameItemTitle = document.getElementById("idGameItemTitle");
        //var idSecContent = document.getElementById("idSecContent");

        var idGameItemGroup = document.getElementById("idGameItemGroup");
        var idGameBrandSel = document.getElementById("idGameBrandSel");


        idGameItemTitle.innerHTML = "";
        idGameItemGroup.innerHTML = "";
        idGameBrandSel.innerHTML = '<option value="All">All</option>';
        // 尋找新增
        if (LobbyGameList) {
            if (LobbyGameList.CategoryList) {
                for (var i = 0; i < LobbyGameList.CategoryList.length; i++) {
                    if (LobbyGameList.CategoryList[i].Categ != "Sports") {
                        //上方tab
                        var li = document.createElement("li");
                        var li_a = document.createElement("a");
                        var li_a_span = document.createElement("span");
                        var li_a_i = createITag(LobbyGameList.CategoryList[i].Categ);
                        //下方遊戲內容，全隱藏
                        //var secGameCateg = document.createElement("section");


                        //上方tab

                        li_a.appendChild(li_a_i);
                        li_a.appendChild(li_a_span);
                        li.appendChild(li_a);
                        li.classList.add("tab-item");
                        li.classList.add("tab_" + LobbyGameList.CategoryList[i].Categ);
                        li_a.classList.add("tab-item-link");
                        li_a_span.innerText = mlp.getLanguageKey(LobbyGameList.CategoryList[i].Categ);

                        li_a.onclick = new Function("selGameCategory('" + LobbyGameList.CategoryList[i].Categ + "')");
                        idGameItemTitle.appendChild(li);

                        //下方遊戲內容建立
                        //secGameCateg.classList.add("game-list");
                        //secGameCateg.classList.add("section-wrap");
                        //secGameCateg.classList.add("sec_" + LobbyGameList.CategoryList[i].Categ);
                        //secGameCateg.classList.add("is-hide");

                        //idSecContent.appendChild(secGameCateg);
                    }
                }
            }

            if (LobbyGameList.GameList) {
                LobbyGameList.GameList.forEach(gameItem => {
                    /* 
                      <div id="idTemGameItem" class="is-hide">
                           <div class="game-item">
                               <a class="game-item-link" href="#"></a>
                               <div class="img-wrap">
                                   <img src="../src/img/games/icon/icon-01.jpg">
                               </div>
                           </div>
                       </div>
                    */
                    if (gameBrandList.findIndex(x => x == gameItem.GameBrand) == -1) {
                        gameBrandList.push(gameItem.GameBrand);
                        var opt = document.createElement("option");
                        opt.value = gameItem.GameBrand;
                        opt.innerText = mlp.getLanguageKey(gameItem.GameBrand);
                        idGameBrandSel.appendChild(opt);
                    }

                    var GI = c.getTemplate("idTemGameItem");
                    var GI_img = GI.querySelector("img");
                    var GI_a = GI.querySelector(".OpenGame");

                    if (GI_img != null) {
                        GI_img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + gameItem.GameBrand + "/PC/" + WebInfo.Lang + "/" + gameItem.GameName + ".png";
                        GI_img.onerror = new Function("setDefaultIcon('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    }


                    c.setClassText(GI, "GameCode", null, window.parent.API_GetGameLang(1, gameItem.GameBrand, gameItem.GameName));
                    c.setClassText(GI, "GameID", null, c.padLeft(gameItem.GameID.toString(), 5));
                    GI_a.onclick = new Function("window.parent.API_OpenGameCode('" + gameItem.GameBrand + "', '" + gameItem.GameName + "')");
                    GI.classList.add("is-hide");
                    GI.classList.add("gc_" + gameItem.Categ);
                    GI.classList.add("subGc_" + gameItem.SubCateg);
                    GI.classList.add("brand_" + gameItem.GameBrand);

                    if (gameItem.IsHot == 1) {
                        GI.classList.add("subGc_Hot");
                        GI.classList.add("label-hot");
                    }

                    if (gameItem.IsNew == 1) {
                        GI.classList.add("subGc_New");
                        GI.classList.add("label-new");
                    }

                    idGameItemGroup.appendChild(GI);

                });
            }
        }
    }

    function updateBaseInfo() {
        //LobbyGameList = window.parent.API_GetGameList();
        //updateGameCode();
        //selGameCategory(nowCateg);
    }

    function init() {
        if (self == top) {
            window.location.href = "index.aspx";
        }

        WebInfo = window.parent.API_GetWebInfo();
        p = window.parent.API_GetLobbyAPI();
        nowCateg = c.getParameter("Category");
        nowSubCateg = c.getParameter("SubCategory");
        lang = window.parent.API_GetLang();

        if (WebInfo.IsOpenGame) {
            WebInfo.IsOpenGame = false;
            window.parent.SwitchGameHeader(0);
        }

        if (nowCateg == undefined || nowCateg == "") {
            nowCateg = "All";
        }

        if (nowSubCateg == undefined || nowSubCateg == "") {
            nowSubCateg = "Hot";
        }

        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            window.parent.API_LoadingEnd();
            if ((WebInfo.SID != null)) {
                updateBaseInfo()
                LobbyGameList = window.parent.API_GetGameList();
                updateGameCode();
                selGameCategory(nowCateg, nowSubCateg);
            } else {
                loginRecover();
            }
        });
    }

    function setDefaultIcon(brand, name) {
        var img = event.currentTarget;
        img.onerror = null;
        img.src = WebInfo.EWinGameUrl + "/Files/GamePlatformPic/" + brand + "/PC/" + WebInfo.Lang + "/" + name + ".png";
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

                mlp.loadLanguage(lang, function () {
                    updateGameCode();
                    selGameCategory(nowCateg);
                });
                break;
        }
    }

    function createITag(Category) {
        var iTag = document.createElement("i");
        var iTagCls = "";
        
        switch (Category) {
            case "All":
                iTagCls = "icon-casinoworld-menu";
                break;
            case "Baccarat":
                iTagCls = "icon-casino";
                break;
            case "Live":
                iTagCls = "icon-casino";
                break;
            case "Sports":
                iTagCls = "icon-casinoworld-football";
                break;
            case "Classic":
                iTagCls = "icon-poker";
                break;
            case "Electron":
                iTagCls = "icon-casinoworld-poker";
                break;
            case "Slot":
                iTagCls = "icon-slot";
                break;
            case "Fish":
                iTagCls = "icon-casinoworld-fish-1";
                break;
            case "Finance":
                iTagCls = "icon-casinoworld-linear-chart-2";
                break;
            default:
                iTagCls = "icon-casinoworld-game-default";
                break;
        }

        iTag.classList.add(iTagCls);

        return iTag;
    }

    window.onload = init;
</script>
    
<body>
    <div class="page-container">
        <header class="heading-top-container">
            <div class="heading-top-inner">
                <h2 id="idHeadText" class="heading-top-title"></h2>
            </div>
            <img class="heading-top-img" src="images/assets/heading-img-01.jpg">
        </header>
        <div id="idSecContent" class="">

            <section class="section-wrap">
                <div class="menu-wrap menu-wrap-main">
                    <div class="menu-container">
                        <ul id="idGameItemTitle" class="tab-menu menu-main">
                        </ul>
                    </div>
                </div>
                <div class="menu-wrap menu-wrap-sub">
                    <div class="menu-container">
                        <ul id="idGameItemSubTitle" class="tab-menu menu-sub">
                            <li class="tab-item tab_Hot">
                                <a class="tab-item-link" onclick="selSubGameCategory('Hot')">
                                    <span class="language_replace">熱門</span>
                                </a>
                            </li>
                            <li class="tab-item tab_New">
                                <a class="tab-item-link" onclick="selSubGameCategory('New')">
                                    <span class="language_replace">最新</span>
                                </a>
                            </li>
                        </ul>
                        <div class="menu-filter brand">
                            <select id="idGameBrandSel" onchange="changeGameBrand();" class="form-control custom-style">
                                <option value="All">All</option>
                            </select>
                        </div>
                    </div>

                </div>
            </section>

            <!-- 遊戲列表 -->
            <section class="section-wrap game-list">
                <div class="page-content">
                    <div id="idGameItemGroup" class="game-item-group">
                    </div>
                    <div id="idNoGameExist" class="is-hide">
                        <span class="language_replace">搜尋不到相關遊戲，請重設分類與廠牌</span>
                    </div>
                </div>
            </section>


        </div>
        <div id="idTemGameItem" class="is-hide">
            <div class="game-item">
                <a class="game-item-link"></a>
                <div class="img-wrap">
                    <img src="">
                </div>
                <div class="game-item-info">
                    <h3 class="game-item-name GameCode"></h3>
                    <button type="button" class="btn btn-primary game-item-btn OpenGame"><span class="language_replace">GO</span></button>
                    <div class="game-item-name" style="text-align: right; position: absolute; bottom: 10px; right: 5px; font-size: 12px;">
                        No:<span class="GameID"></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
