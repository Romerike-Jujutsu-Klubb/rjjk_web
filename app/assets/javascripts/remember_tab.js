function show_tab() {
    if (window.location.hash) {
        $('a[href="' + window.location.hash + '"]').tab('show');
    } else {
        default_tab = $('a.nav-link.active[data-toggle="tab"]');
        if (default_tab[0]) {
            window.history.replaceState({}, window.title, window.location + default_tab.attr("href"));
        }
    }
};

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
    $(window).on('popstate', show_tab);
    show_tab();
});
