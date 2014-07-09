//= require jquery
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require jquery-ui/slider
//= require jquery-ui-timepicker-addon
//= require tinymce-jquery
//= require gmaps4rails/gmaps4rails.base
//= require gmaps4rails/gmaps4rails.googlemaps
//= require bootstrap
//= require colorbox-rails.js
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

$().ready(function () {
    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        tab = $('#' + $(e.target).attr('href').substr(1));
        window.location.hash = $(e.target).attr("href").substr(1);

        if (!tab.html()) {
            tab.html('<div class="text-center" style="padding: 3em">Loading...</div>');
            tab.load(tab.attr('data-target'));
        }
        return true;
    });
    $(window).on('popstate', function () {
        if (window.location.hash) {
            $('a[href="' + window.location.hash + '"]').tab('show');
        } else {
            default_tab = $('li.active > a[data-toggle="tab"]');
            if (default_tab[0]) {
                window.history.replaceState({}, window.title, window.location + default_tab.attr("href"));
            }
        }
        $('.stretch').parent('.row').scrollTop(0);
        setTimeout(function () {
            $('.stretch').parent('.row').scrollTop(0)
        }, 50)
    });
    $('.stretch').parent('.row').addClass("row-stretch");
})

// http://makandracards.com/makandra/1383-rails-3-make-link_to-remote-true-replace-html-elements-with-jquery
// link_to 'Do something', path_returning_partial, :remote => true, :"data-replace" => '#some_id'
$().ready(function () {
    $('[data-remote][data-replace]').data('type', 'html');
    $(document).on('ajax:success', '[data-remote][data-replace]', function (event, data) {
        var $this = $(this);
        $($this.data('replace')).replaceWith(data);
        $this.trigger('ajax:replaced');
    });
});
