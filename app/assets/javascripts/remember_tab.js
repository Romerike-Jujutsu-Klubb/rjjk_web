function show_tab() {
    if (window.location.hash) {
        $('a[data-target="' + window.location.hash.slice(0, -4) + '"]').tab('show');
    } else {
        default_tab = $('a.nav-link.active[data-toggle="tab"]');
        if (default_tab[0]) {
            window.history.replaceState({}, window.title, window.location + default_tab.attr("data-target") + '_tab');
        }
    }
};

$().ready(function () {
    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        var tab_id = $(e.target).attr('data-target').substr(1);
        tab = $('#' + tab_id);
        if (location.hash.slice(1, -4) !== tab_id) {
            if (history.pushState) {
                history.pushState(null, null, '#' + tab_id + '_tab');
            } else {
                location.hash = tab_id + '_tab';
            }
        }

        if (!tab.html()) {
            var target = tab.attr('data-target');
            if (target) {
                tab.html('<div class="text-center" style="padding: 3em">Loading...</div>');
                tab.load(target);
            }
        }
        return true;
    });
    $(window).on('popstate', show_tab);
    show_tab();
});
