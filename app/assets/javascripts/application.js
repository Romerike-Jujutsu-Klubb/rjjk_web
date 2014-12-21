//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require tinymce-jquery
//= require gmaps4rails/gmaps4rails.base
//= require gmaps4rails/gmaps4rails.googlemaps
//= require colorbox-rails
//= require expanding
//= require bootstrap-sprockets
//= require moment
//= require moment/nb
//= require bootstrap-datetimepicker
//= require nprogress
//= require nprogress-turbolinks
//= require chosen-jquery
//= require remember_tab
$(function () {
    $(".colorbox").colorbox({
        inline: true,
        title: function () {
            return $(this).attr("title")
        },
        href: function () {
            return $(this).attr("href")
        },
        returnFocus: false
    });
});

NProgress.configure({showSpinner: false,  ease: 'ease',  speed: 500});

$().ready(function () {
    $(window).on('popstate', function () {
        $('.stretch').parent('.row').scrollTop(0);
        setTimeout(function () {
            $('.stretch').parent('.row').scrollTop(0)
        }, 50)
    });
    $('.stretch').parent('.row').addClass("row-stretch");
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
    $('.date,[dateFormat]').datetimepicker({format: 'YYYY-MM-DD', pickTime: false});
    $('.datetime,[dateFormat][timeFormat]').datetimepicker({format: 'YYYY-MM-DD H.mm'});
});
