//= require jquery
// require jquery.turbolinks
//= require jquery_ujs
// require turbolinks
//= require expanding
//= require popper
//= require bootstrap
//= require moment
//= require moment/nb
//= require bootstrap-datetimepicker
//= require bootstrap-datetimepicker-init
//= require nprogress
//= require nprogress-turbolinks
//= require chosen-jquery
//= require bootstrap_tabs_ios
//= require remember_tab
//= require jquery.lazyload
//= require fileinput
//= require fileinput-fa-theme
//= require Chart.bundle
//= require chartkick
//= require serviceworker-companion
//= require changed_selector
//= require table_navigation
//= require draggable
//= require image_dropzone
//= require preview

NProgress.configure({showSpinner: false,  ease: 'ease',  speed: 500});

$(function () {
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

$(function () {
    $('[data-toggle=tooltip]').tooltip()
});

$(function () {
  $('[data-toggle="popover"]').popover()
});
