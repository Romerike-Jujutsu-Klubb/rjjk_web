$().ready(function () {
    $('.stretch').parent('.row').addClass("row-stretch");
    $('.row-stretch').on('scroll', function () {
        $( this ).scrollTop(0);
    });
});
