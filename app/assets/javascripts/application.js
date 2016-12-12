//= require jquery
// require jquery.turbolinks
//= require jquery_ujs
// require turbolinks
//= require tinymce-jquery
//= require gmaps4rails/gmaps4rails.base
//= require gmaps4rails/gmaps4rails.googlemaps
//= require expanding
//= require bootstrap-sprockets
//= require moment
//= require moment/nb
//= require bootstrap-datetimepicker
//= require nprogress
//= require nprogress-turbolinks
//= require chosen-jquery
//= require remember_tab
//= require stretch-columns
//= require jquery.lazyload

// Switch to Bootstrap modal
NProgress.configure({showSpinner: false,  ease: 'ease',  speed: 500});

$().ready(function () {
    $('.chosen-select').chosen();
});

// http://makandracards.com/makandra/1383-rails-3-make-link_to-remote-true-replace-html-elements-with-jquery
// link_to 'Do something', path_returning_partial, :remote => true, :"data-replace" => '#some_id'
$().ready(function () {
    $('[data-remote][data-replace]').data('type', 'html');
    $(document).on('ajax:success', '[data-remote][data-replace]', function (event, data) {
        var $this = $(this);
        $($this.data('replace')).replaceWith(data);
        $this.trigger('ajax:replaced');
    });

    // http://eonasdan.github.io/bootstrap-datetimepicker/#options
    $('.date,[dateFormat]').each(function () {
        const format = 'YYYY-MM-DD';
        var value = $(this).val();
        if (value) {
            $(this).val('');
            $(this).datetimepicker({format: format, defaultDate: value});
        } else {
            var defaultDate = $(this).data('default-date');
            if (defaultDate) {
                $(this).datetimepicker({format: format, defaultDate: defaultDate});
                $(this).val('');
            } else {
                $(this).datetimepicker({format: format, useCurrent: false});
            }
        }
    });
    $('.datetime,[dateFormat][timeFormat]').each(function () {
        var value = $(this).val();
        if (value) {
            $(this).val('');
            $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', defaultDate: value});
        } else {
            var defaultDate = $(this).data('default-date');
            if (defaultDate) {
                $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', defaultDate: defaultDate});
                $(this).val('');
            } else {
                $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', useCurrent: false});
            }
        }
    });
    $('.time,[timeFormat]').datetimepicker({format: 'HH:mm'});
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
