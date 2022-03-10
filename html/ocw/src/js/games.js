$(function () {
    //載入元件
    $('#footer').load('../_footer.html');
    
    // 輪播 banner
    var swiper = new Swiper("#hero-thumb", {
        slidesPerView: 4,
        watchSlidesVisibility: true,
        watchSlidesProgress: true,
        preventClicks: true,
    });

    var swiper2 = new Swiper("#hero", {
        loop: true,
        slidesPerView: 1,
        autoplay: {
            delay: 8000,
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
        thumbs: {
            swiper: swiper
        }

    });

    document.addEventListener('mouseenter', event => {
        const el = event.target;
        if (el && el.matches && el.matches('#hero .swiper-container')) {
            el.swiper.autoplay.stop();
            el.classList.add('swiper-paused');
            
            const activeNavItem = el.querySelector('#hero .swiper-pagination-bullet-active');
            activeNavItem.style.animationPlayState="paused";
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
        loop: true,
        slidesPerView: 4,
        freeMode: true,
        navigation: {
            nextEl: "#pop-casino .swiper-button-next",
        },
        breakpoints: {
            540: {
                slidesPerView: 3,
                freeMode: false,
            },
        }
    });
   
    // 熱門老虎機
    var swiper4 = new Swiper("#pop-slot", {
        loop: true,
        slidesPerView: 4,

        navigation: {
            nextEl: "#pop-slot .swiper-button-next",
        },
        breakpoints: {
            540: {
                slidesPerView: 3,
                freeMode: false,
            },
        }
    });

});
