//= require @fortawesome/fontawesome-free/js/all.js
//= require @fortawesome/fontawesome-free/js/v4-shims
//= require jquery/dist/jquery
// require jquery.turbolinks
//= require rails-ujs
// require turbolinks
//= require includes/isMobile
//= require includes/expanding
//= require popper.js/dist/umd/popper.js
//= require bootstrap
//= require moment/moment
//= require moment/locale/nb
//= require pc-bootstrap4-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require includes/bootstrap-datetimepicker-init
//= require chosen-jquery
//= require includes/bootstrap_tabs_ios
//= require includes/remember_tab
//= require lazyload/lazyload
//= require bootstrap-fileinput/js/fileinput
//= require bootstrap-fileinput/themes/fa/theme
//= require Chart.bundle
//= require chartkick
//= require serviceworker-companion
//= require includes/changed_selector
//= require includes/table_navigation
//= require includes/draggable
//= require includes/image_dropzone
//= require includes/preview
//= require includes/data-replace
//= require bs-custom-file-input/dist/bs-custom-file-input

$(function() {
  $('.chosen,.chosen-select').chosen();

  // Lazy load marked images
  lazyload();

  $('[data-toggle=tooltip]').tooltip()

  $.fn.popover.Constructor.Default.whiteList.table = [];
  $.fn.popover.Constructor.Default.whiteList.tr = [];
  $.fn.popover.Constructor.Default.whiteList.td = [];
  $.fn.popover.Constructor.Default.whiteList.tbody = [];
  $.fn.popover.Constructor.Default.whiteList.thead = [];
  $('[data-toggle="popover"]').popover()

  bsCustomFileInput.init()
});

FontAwesomeConfig.autoReplaceSvg = 'nest';

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
