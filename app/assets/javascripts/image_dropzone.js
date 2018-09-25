function image_dropzone(target) {
    target.on("dragover", function (event) {
        event.preventDefault();
        event.stopPropagation();
    }).on("dragleave", function (event) {
        event.preventDefault();
        event.stopPropagation();
    }).on('drop', function (e, e2) {
        console.log('drop'); // for debugging reasons
        e.preventDefault();  // stop default behaviour
        var uri = e.originalEvent.dataTransfer.getData('text/uri-list');
        var newURL = uri.replace(/^[a-z]{4,5}\:\/{2}[a-z]{1,}\:[0-9]{1,4}.(.*)/, '$1'); // http or https
        console.trace(newURL);
        console.trace(e.originalEvent.dataTransfer.getData('text/html'));
        $(this).val($(this).val() + '![IMAGE](/' + newURL + ' "Image")\n');
        preview();
    })
}
