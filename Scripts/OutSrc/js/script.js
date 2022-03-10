//100vh fix
let vh = window.innerHeight * 0.01;
document.documentElement.style.setProperty('--vh', `${vh}px`);

window.addEventListener('resize', () => {
    let vh = window.innerHeight * 0.01;
    document.documentElement.style.setProperty('--vh', `${vh}px`);
});


//$(window).on('load', function(){
//    $('.loader-backdrop').addClass('is-show');
//    $('.loader-container').delay(500).fadeOut(250, function(){
//        $('.iframe-container').addClass('is-show');
//    });
//});
$(function() {

    //登入註冊流程
    //$('#sign').load('_sign.html', function(){
    //    $("form").click(function(e){
    //        e.preventDefault();
    //    });
        
    //    var goSignIn = $('[data-click-btn="signIn"]'),
    //    goResetPassword = $('[data-click-btn="restPassword"]'),
    //    gomailSend = $('[data-click-btn="mailSend"]'),
    //    goRegisterStep1 = $('[data-click-btn="registerStep1"]'),
    //    goRegisterStep2 = $('[data-click-btn="registerStep2"]'),
    //    goRegisterComplete = $('[data-click-btn="registerComplete"]'),
    //    backToHome = $('[data-click-btn="backToHome"]'),
        

    //    allform = $('[data-form-group="signIn"], [data-form-group="restPassword"], [data-form-group="mailSend"], [data-form-group="register"], [data-form-group="registerStep1"], [data-form-group="registerStep2"], [data-form-group="registerComplete"]'),
    //    signContainer = $('.sign-container'),
    //    signIn = $('[data-form-group="signIn"]'),
    //    resetPassword = $('[data-form-group="restPassword"]'),
    //    mailSend = $('[data-form-group="mailSend"]'),
    //    register = $('[data-form-group="register"]'),
    //    registerStep1 = $('[data-form-group="registerStep1"]'),
    //    registerStep2 = $('[data-form-group="registerStep2"]'),
    //    registerComplete = $('[data-form-group="registerComplete"]'),
    //    logo = $('.sign-container .logo'),
    //    btnPrev = $('.sign-container .btn-back');
        
    //    logo.show();
    //    btnPrev.addClass('is-hide');

    //    //登入
    //    goSignIn.click(function(){
    //        signContainer.removeClass('is-hide').addClass('is-show');
    //        allform.removeClass('is-show').addClass('is-hide');
    //        signIn.removeClass('is-hide').addClass('is-show');
    //    });
    //    //重設密碼
    //    goResetPassword.click(function(){
    //        allform.removeClass('is-show').addClass('is-hide');
    //        resetPassword.removeClass('is-hide').addClass('is-show');
    //        logo.hide();
    //        btnPrev.removeClass('is-hide');
    //    });
    //    //重設密碼 回登入
    //    btnPrev.click(function(){
    //        $(this).addClass('is-hide');
    //        logo.show();
    //        signContainer.removeClass('is-hide').addClass('is-show');
    //        allform.removeClass('is-show').addClass('is-hide');
    //        signIn.removeClass('is-hide').addClass('is-show');
    //    });

    //    //重設密碼 回登入
    //    gomailSend.click(function(){
    //        btnPrev.addClass('is-hide');
    //        logo.show();
    //        resetPassword.removeClass('is-show').addClass('is-hide');
    //        mailSend.removeClass('is-hide').addClass('is-show');
    //    });
    //    goRegisterStep1.click(function(){
    //        signIn.removeClass('is-show').addClass('is-hide');
    //        register.removeClass('is-hide').addClass('is-show');
    //        registerStep1.removeClass('is-hide').addClass('is-show');
    //    });
    //    goRegisterStep2.click(function(){
    //        registerStep1.removeClass('is-show').addClass('is-hide');
    //        registerStep2.removeClass('is-hide').addClass('is-show');
    //    });
    //    goRegisterComplete.click(function(){
    //        registerStep2.removeClass('is-show').addClass('is-hide');
    //        register.removeClass('is-show').addClass('is-hide');
    //        registerComplete.removeClass('is-hide').addClass('is-show');
    //    });
        
    //    backToHome.click(function(){
    //        signContainer.removeClass('is-show').addClass('is-hide');
    //        all.removeClass('is-show').addClass('is-hide');
    //    });

    //});


    ////載入 system msg (404)
    //$('#system-msg').load('_system-msg.html');
    //$('#system-msg').hide();
    //$('[data-btn-click="system-msg"]').click(function(){
    //    $('#system-msg').show();
    //});

    ////載入客服
    //$('#conversation').load('_conversation.html', function(){

    //    //開啟
    //    $('a[data-btn-click="conversation"]').click(function(){
    //        $('#conversation .conversation-container').removeClass('is-hide').addClass('is-show');
    //    });
    //    //關閉
    //    $('button[data-btn-click="closeConversation"]').click(function(){
    //        $('#conversation .conversation-container').removeClass('is-show').addClass('is-hide');
    //    });
        
    //});

    //語言選單
    $('[data-btn-click="openLag"]').click(function(){
        $('.lang-select-panel').fadeToggle('fast');
    });

    $('.lang-select-panel a').click(function(){
        var curLang = $(this).text();
        $('.lang-select-panel').fadeToggle('fast');
        $('[data-btn-click="openLag"]').find('span').text(curLang);
    });
    //主選單收合
    $('.nav-toggle').click(function(){
        $('.nav-toggle, .nav').toggleClass('open');
    });
    $('.nav .body-backdrop, .nav-group a').click(function(){
        $('.nav-toggle, .nav').removeClass('open');
    });

    ////主選單換頁 loader
    //$('.nav a[target="page"]').click(function(){
    //    $('.loader-container').fadeIn();
    //    $('.loader-backdrop').removeClass('is-show');

    //    $('iframe').on('load', function() {
    //        $('.loader-backdrop').addClass('is-show');
    //        $('.loader-container').delay(500).fadeOut(250, function(){
    //            $('.iframe-container').addClass('is-show');
    //        });
    //    });
    //});


});

function goBack() {
    window.history.back();
}

