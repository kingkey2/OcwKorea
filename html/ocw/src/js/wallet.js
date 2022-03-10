$(function () {
    
    //載入元件
    $('#heading-top').load('_heading-top.html');
    $('#footer').load('../_footer.html');


    //存取款紀錄 下拉明細
    $('.record-table-drop-panel').hide();

    $('.btn-toggle').click(function(){
        $(this).toggleClass('cur');
        $(this).parents('.record-table-item').find('.record-table-drop-panel').slideToggle();
    });

    //存款步驟
    var Step2 = $('[data-deposite="step2"]'),
        Step3 = $('[data-deposite="step3"]'),
        Step4 = $('[data-deposite="step4"]');

        Step3.hide();
        Step4.hide();

        $('button[data-deposite="step2"]').click(function(){
            Step2.hide();
            Step3.fadeIn();
            $('.progress-step:nth-child(3)').addClass('cur');
        });
        $('button[data-deposite="step3"]').click(function(){
            Step3.hide();
            Step4.fadeIn();
            $('.progress-step:nth-child(4)').addClass('cur');
        });

    //提款步驟
    var wdStep2 = $('[data-withdraw="step2"]'),
        wdStep3 = $('[data-withdraw="step3"]');

        wdStep3.hide();

        $('button[data-withdraw="step2"]').click(function(){
            wdStep2.hide();
            wdStep3.fadeIn();
            $('.progress-step:nth-child(3)').addClass('cur');
        });
    
    //錢包設定
    var setBank = $('[data-account-type="bank"]'),
        setCrypto = $('[data-account-type="crypto"]');

        setBank.show();
        setCrypto.hide();

    $('label[data-type="bank"]').click(function(){
        setBank.fadeIn();
        setCrypto.hide();
    });
    $('label[data-type="crypto"]').click(function(){
        setBank.hide();
        setCrypto.fadeIn();
    });

    //虛擬帳戶 編輯工具
    $('[data-tool="showTool"]').click(function(){
        $(this).parent().toggleClass('cur');
    });

    // credit card num
    $('.multi-input.credit-num input').keyup(function () {
        if (this.value.length == this.maxLength) {
          $(this).next('.multi-input input').focus();
        }
    });
    // pincode
    $('.pincode-box input').keyup(function () {
        if (this.value.length == this.maxLength) {
          $(this).next('.pincode-box input').focus();
        }
    });



    // dropdown-selector
    $('[data-click-btn="toggle-dropdown"]').click(function(){
        $(this).parent().toggleClass('cur');
    });
    

    $('.dropdown-selector-panel .btn-radio').click(function(){
        var curGame = $(this).find('span').text();
        setTimeout(function() {
            $('.dropdown-selector-tab span').text(curGame);
            $('.dropdown-selector').removeClass('cur');
        }, 100);
    });
});

function goBack() {
    window.history.back();
}
