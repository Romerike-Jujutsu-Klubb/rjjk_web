function show_tab() {
    if (window.location.hash) {
        var selected_tab = $('a[data-target="' + window.location.hash.slice(0, -4) + '"]');
        if (selected_tab.hasClass('active')) {
            selected_tab.trigger('show.bs.tab');
        } else {
            selected_tab.tab('show');
        }
    } else {
        var default_tab = $('a.nav-link.active[data-toggle="tab"]');
        if (default_tab[0]) {
            window.history.replaceState({}, window.title, window.location + default_tab.attr("data-target") + '_tab');
            default_tab.trigger('show.bs.tab');
        }
    }
}

$().ready(function () {
    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        var event_target = $(e.target);
        var tab_id = (event_target.attr('data-target') || event_target.attr('href')).substr(1);
        var tab = $('#' + tab_id);
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
                tab.html('<div class="text-center" style="padding: 3em"><i class="fa fa-circle-o-notch fa-spin fa-5x mb-3"/><br/>Et øyeblikk...</div>');
                tab.load(target, function (responseText, textStatus) {
                    if (textStatus === "error") {
                        tab.html('<div class="text-center text-danger" style="padding: 3em">Hoppsann!  Der gikk det galt.</div>');
                        tab.append('<pre>' + responseText + '</pre>');
                    }
                });            }
        }
        return true;
    });
    $(window).on('popstate', show_tab);
    show_tab();
});
