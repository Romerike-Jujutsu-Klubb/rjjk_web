//= require jquery
// require jquery.turbolinks
//= require jquery_ujs
// require turbolinks
//= require tinymce-jquery
//= require expanding
//= require tether
//= require bootstrap
//= require moment
//= require moment/nb
//= require bootstrap-datetimepicker
//= require bootstrap-datetimepicker-init
//= require nprogress
//= require nprogress-turbolinks
//= require chosen-jquery
//= require remember_tab
//= require jquery.lazyload
//= require fileinput
//= require fileinput-fa-theme

// Switch to Bootstrap modal
NProgress.configure({showSpinner: false,  ease: 'ease',  speed: 500});

$().ready(function () {
    $('.chosen-select').chosen();
});

// Lazy load marked images
$(window).on('load', function () {
    $("img[data-original]").each(function () {
        var container = $(this).closest(".lazy-container")[0];
        if (container) {
            $(this).lazyload({container: container});
        } else {
            $(this).lazyload();
        }
    });
});

$().ready(function () {
    $('[data-toggle=tooltip]').tooltip()
});
