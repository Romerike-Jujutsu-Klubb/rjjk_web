//= require jquery
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require jquery.ui.slider
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
                window.location.hash = default_tab.attr("href").substr(1);
            }
        }
        $('.stretch').parent('.row').scrollTop(0);
        setTimeout(function () {
            $('.stretch').parent('.row').scrollTop(0)
        }, 50)
    });
    $('.stretch').parent('.row').addClass("row-stretch");
})
