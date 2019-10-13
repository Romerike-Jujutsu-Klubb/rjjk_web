function show_tab() {
    console.log("show_tab: " + decodeURIComponent(location.hash));

    if (location.hash) {
        var selected_tab = $('a[data-target="' + decodeURIComponent(location.hash).slice(0, -4) + '"]');

        // Show parent tab
        parent_tab_content = selected_tab.closest('.tab-pane');
        if (parent_tab_content[0]) {
            console.log("In parent tab.");
            parent_tab_id = parent_tab_content.attr('id');
            console.log("parent_tab_id: " + parent_tab_id);
            parent_tab = $('a[data-target="#' + parent_tab_id + '"]');
            if (parent_tab[0]) {
                console.log("found parent tab: " + parent_tab.data('target'));
                if (parent_tab.hasClass('active')) {
                    console.log("Parent tab already shown.");
                } else {
                    console.log("Show parent tab.");
                    parent_tab.tab('show');
                }
            } else {
                console.log("In parent tab content, but no parent tab.");
            }
        } else {
            console.log("No parent tab.");
        }

        if (selected_tab.hasClass('active')) {
            console.log("Tab already shown.");
            // selected_tab.trigger('show.bs.tab');
        } else {
            console.log("Show tab: " + selected_tab.data('target'));
            selected_tab.tab('show');
        }
    } else {
        console.log("location.hash empty");

        var default_tab = $('a.nav-link.active[data-toggle="tab"]');
        if (default_tab[0]) {
            console.log("found active tab: " + default_tab.attr("data-target"));

            // Find and activate child tab
            default_tab_content = $(default_tab.attr("data-target"));
            child_tab = default_tab_content.find('a.nav-link.active[data-toggle="tab"]');
            if (child_tab.length === 0) {
                child_tab = default_tab_content.find('a.nav-link[data-toggle="tab"]');
            }
            if (child_tab[0]) {
                console.log("found child tab: " + child_tab.attr("data-target"));
                console.log("replaceState: " + window.location.href.replace(location.hash, "") + child_tab.attr("data-target") + '_tab');
                window.history.replaceState({}, window.title, window.location.href.replace(location.hash, "") + child_tab.attr("data-target") + '_tab');
                console.log("location.hash: " + decodeURIComponent(location.hash));
            } else {
                // Store tab id in location hash

                // default_tab.trigger('show.bs.tab');
                console.log("replaceState: " + window.location.href.replace(location.hash, "") + default_tab.attr("data-target") + '_tab');
                window.history.replaceState({}, window.title, window.location.href.replace(location.hash, "") + default_tab.attr("data-target") + '_tab');
                console.log("location.hash: " + decodeURIComponent(location.hash));
            }
        } else {
            default_tab = $('a.nav-link[data-toggle="tab"]');
            if (default_tab[0]) {
                default_tab.trigger('show.bs.tab');
                console.log("replaceState: " + window.location.href.replace(location.hash,"") + default_tab.attr("data-target") + '_tab');
                window.history.replaceState({}, window.title, window.location.href.replace(location.hash,"") + default_tab.attr("data-target") + '_tab');
                console.log("location.hash: " + decodeURIComponent(location.hash));

            }
        }
    }
}

$(function () {
    if (isMobile.iOS()) {
        $('a.nav-link[data-target][data-toggle="tab"]').each(function (i, link_el) {
            var link = $(link_el);
            link.attr('href', link.data('target')).data('target', null);
        });
    }

    $('a[data-toggle="tab"]').on('show.bs.tab', function (e) {
        var event_target = $(e.target);
        var tab_id = (event_target.attr('data-target') || event_target.attr('href')).substr(1);
        var tab = $('#' + tab_id);

        console.log('Event show.bs.tab: ' + tab_id);
        console.log("location.hash: " + decodeURIComponent(location.hash));

        // Find and activate child tabs
        tab_content = tab;
        active_child_tab = tab_content.find('a.nav-link.active[data-toggle="tab"]');
        if (active_child_tab[0]) {
            console.log("Found active child tab: " + active_child_tab.attr("data-target"));
            let active_child_tab_id = (active_child_tab.attr('data-target') || active_child_tab.attr('href')).substr(1);
            let desired_hash = '#' + active_child_tab_id + '_tab';

            if (decodeURIComponent(location.hash) !== desired_hash) {
                if (history.pushState) {
                    console.log("push desired_hash: " + desired_hash);
                    history.pushState(null, null, desired_hash);
                    console.log("location.hash: " + decodeURIComponent(location.hash));
                } else {
                    console.log("store desired_hash: " + desired_hash);
                    location.hash = active_child_tab_id + '_tab';
                    console.log("location.hash: " + decodeURIComponent(location.hash));

                }
            } else {
                console.log("Location hash already correct.")
            }
        } else {
            child_tab = tab_content.find('a.nav-link[data-toggle="tab"]');
            if (child_tab[0]) {
                console.log("found hidden child tab: " + $(child_tab[0]).attr('data-target') + ' trigger');
                $(child_tab[0]).tab('show');
            } else {
                // Store tab id in the location hash
                let desired_hash = '#' + tab_id + '_tab';

                if (decodeURIComponent(location.hash) !== desired_hash) {
                    if (history.pushState) {
                        console.log("push desired_hash: " + desired_hash);
                        history.pushState(null, null, desired_hash);
                        console.log("location.hash: " + decodeURIComponent(location.hash));
                    } else {
                        console.log("store desired_hash: " + desired_hash);
                        location.hash = tab_id + '_tab';
                        console.log("location.hash: " + decodeURIComponent(location.hash));

                    }
                } else {
                    console.log("Location hash already correct.")
                }
            }
            console.log("location.hash: " + decodeURIComponent(location.hash) + ", history: " + window.history.length);
        }

        // Load remote content
        if (!tab.html()) {
            var target = tab.attr('data-target');
            if (target) {
                tab.html('<div class="text-center" style="padding: 3em"><i class="fa fa-circle-notch fa-spin fa-5x mb-3"/><br/>Et øyeblikk...</div>');
                tab.load(target, function (responseText, textStatus) {
                    if (textStatus === "error") {
                        tab.html('<div class="text-center text-danger" style="padding: 3em">Hoppsann!  Der gikk det galt.</div>');
                        tab.append('<pre>' + responseText + '</pre>');
                    }
                });
            }
        }
        return true;
    });
    $(window).on('popstate', show_tab);
    show_tab();
});
