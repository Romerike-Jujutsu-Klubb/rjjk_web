//= require @fortawesome/fontawesome-free/js/all.js
//= require @fortawesome/fontawesome-free/js/v4-shims
//= require jquery/dist/jquery
// require jquery.turbolinks
//= require rails-ujs
// require turbolinks
//= require isMobile
//= require expanding
//= require popper.js/dist/umd/popper.js
//= require bootstrap
//= require moment/moment
//= require moment/locale/nb
//= require pc-bootstrap4-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require bootstrap-datetimepicker-init
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

function setAttendanceBtn(btn) {
  $btn = $(btn);
  const btnColor = $btn.attr('class').match(/(?:btn|text)-(.+?)\b/)[1];
  var match = $btn.attr('href').match(/\/(\d{4})\/(\d{1,2})\/(\d+)\/([A-Z])\/(\d+)/);
  const year = match[1];
  const week = match[2];
  const gs_id = match[3];
  const state = match[4];
  const user_id = match[5];
  $('#btn_' + year + '_' + week + '_' + gs_id + '_' + user_id)
      .removeClass('btn-info btn-success btn-warning btn-danger').addClass('btn-' + btnColor).html($(btn).html())
      .data('status', state).find('i').attr('class', 'fa fa-sync fa-spin');
  $(btn).closest('.btn-group.show').find('[data-toggle=dropdown]').dropdown('toggle');
  $(btn).closest('.btn-group').find('[data-toggle=dropdown]')
      .removeClass('btn-info btn-success btn-warning btn-danger').addClass('btn-' + btnColor);
}
