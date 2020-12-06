function preview(inputs_selector, target_selector) {
    var inputs = $(inputs_selector);
    var target = $(target_selector);

    var previewTimeout = null;
    inputs.on('input', function () {
        if (previewTimeout != null) {
            clearTimeout(previewTimeout);
        }
        previewTimeout = setTimeout(function () {
            previewTimeout = null;
            load_preview(inputs, target);
        }, 200);
    });
    load_preview(inputs, target);
}

function load_preview(inputs, target) {
    target.load('preview', inputs).map(function () {
        return "" + $(this).attr('name') + "=" + encodeURIComponent($(this).val())
    }).get().join("&")
}
