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

    $('a[href="' + window.location.hash + '"]').tab('show');
    $('.stretch').parent('.row').addClass("row-stretch");
})
$(window).load(function () {
    $('.stretch').parent('.row').scrollTop(0);
    setTimeout(function(){$('.stretch').parent('.row').scrollTop(0)}, 50)
})
