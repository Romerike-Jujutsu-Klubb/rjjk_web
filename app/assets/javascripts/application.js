//= require @fortawesome/fontawesome-free/js/all.js
//= require @fortawesome/fontawesome-free/js/v4-shims
//= require jquery3
// require jquery.turbolinks
//= require jquery_ujs
// require turbolinks
//= require isMobile
//= require expanding
//= require popper
//= require bootstrap
//= require moment/moment
//= require moment/locale/nb
//= require pc-bootstrap4-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require bootstrap-datetimepicker-init
//= require nprogress
//= require nprogress-turbolinks
//= require chosen-jquery
//= require bootstrap_tabs_ios
//= require remember_tab
//= require jquery.lazyload
//= require bootstrap-fileinput/js/fileinput
//= require bootstrap-fileinput/themes/fa/theme
//= require Chart.bundle
//= require chartkick
//= require serviceworker-companion
//= require changed_selector
//= require table_navigation
//= require draggable
//= require image_dropzone
//= require preview
//= require data-replace
//= require bs-custom-file-input/dist/bs-custom-file-input

NProgress.configure({showSpinner: false, ease: 'ease', speed: 500});

$(function() {
  $('.chosen,.chosen-select').chosen();
});

// Lazy load marked images
$(window).on('load', function() {
  $("img[data-original]").each(function() {
    const container = $(this).closest(".lazy-container")[0];
    if (container) {
      $(this).lazyload({container: container});
    } else {
      $(this).lazyload();
    }
  });
});

$(function() {
  $('[data-toggle=tooltip]').tooltip()
});

$(function() {
  $.fn.popover.Constructor.Default.whiteList.table = [];
  $.fn.popover.Constructor.Default.whiteList.tr = [];
  $.fn.popover.Constructor.Default.whiteList.td = [];
  $.fn.popover.Constructor.Default.whiteList.tbody = [];
  $.fn.popover.Constructor.Default.whiteList.thead = [];

  $('[data-toggle="popover"]').popover()
});

FontAwesomeConfig.autoReplaceSvg = 'nest';

$(function() {
  bsCustomFileInput.init()
});
