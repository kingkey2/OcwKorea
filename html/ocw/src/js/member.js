$(function () { 
    // 載入元件
    $('#footer').load('../_footer.html');

    // pincode
    $('.pincode-box input').keyup(function () {
        if (this.value.length == this.maxLength) {
          $(this).next('.pincode-box input').focus();
        }
    });
    
    $("form").click(function(e){
        e.preventDefault();
    });

    // 頭像選擇
    var swiper = new Swiper("#avatar-select", {
        loop: true,
        slidesPerView: 3,
        freeMode: true,
        preventClicks: false,
        navigation: {
            nextEl: ".swiper-button-next",
            prevEl: ".swiper-button-prev"
        },

        onSetTranslate: {
            function(){
                var checkedSlideIndex = $('input:checked').parents('.swiper-slide').attr('data-swiper-slide-index');
                var hasDuplicates = $('.swiper-slide[data-swiper-slide-index="'+checkedSlideIndex+'"]').length > 1;
                if (hasDuplicates) {
                    if ($('.swiper-slide-active').attr('data-swiper-slide-index') === checkedSlideIndex) {
                        $('.swiper-slide-active').find('input').prop('checked', true);
                    }
                    else {
            	        $('.swiper-slide-active').nextAll('.swiper-slide[data-swiper-slide-index="'+checkedSlideIndex+'"]').eq(0).find('input').prop('checked', true);
                    }
                }
            }
        }
        
    });
    setTimeout(() => {
        swiper.update()
    }, 500)

    //編輯收合
    $('[data-click-btn="openPanel"]').click(function(){
        $(this).parents('.expansion').addClass('cur');
    });

    //取款密碼設定 
    var editpincodeStep2 = $('[data-click-btn="pincodeStep2"]'),
        editAvatar = $('[data-click-btn="avatar"]'),
        closeAvatar = $('[data-click-btn="closeAvatar"]'),
        closePanel = $('[data-click-btn="closePanel"]'),
        

        avatar = $('[data-form-group="avatar"]'),
        pincodeStep1 = $('[data-form-group="pincodeStep1"]'),
        pincodeStep2 = $('[data-form-group="pincodeStep2"]');

        editpincodeStep2.click(function(){
            pincodeStep1.addClass('is-hide');
            pincodeStep2.removeClass('is-hide').addClass('is-show');
        });
        
        closePanel.click(function(){
            $(this).parents('.box-item').removeClass('cur');
        });

        editAvatar.click(function(){
            avatar.removeClass('is-hide').addClass('is-show');
            $('body').addClass('body-lock');
        });
        closeAvatar.click(function(){
            avatar.removeClass('is-show').addClass('is-hide');
            $('body').removeClass('body-lock');
        });


});
function goBack() {
    window.history.back();
}
