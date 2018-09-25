// https://phppot.com/jquery/responsive-image-upload-using-jquery-drag-and-drop/
function image_dropzone(target) {
    $('img').on("dragstart", function (event) {
        target.css('border', '#07c6f1 2px dashed');
        target.css('background', '#FFF');
    }).on("dragend", function (event) {
        target.css('border', '1px solid #ced4da');
        target.css('background', '#FFF');
    });

    target.on("dragstart", function (event) {
        target.css('border', '#07c6f1 2px dashed');
        target.css('background', '#FFF');
        event.preventDefault();
        event.stopPropagation();
    }).on('dragenter', function (e) {
        e.preventDefault();
        $(this).css('border', '#39b311 2px dashed');
        $(this).css('background', '#f1ffef');
    }).on('dragover', function (e) {
        e.preventDefault();
    }).on('drop', function (e) {
        $(this).css('border', '1px solid #ced4da');
        $(this).css('background', '#FFF');
        e.preventDefault();

        var data_url = e.originalEvent.dataTransfer.getData('URL');

        if (data_url) {
            if (data_url.startsWith("data:")) {
                return;
            }
            var l = getLocation(data_url);
            target.val(function (i, text) {
                if (text && !text.endsWith("\n")) {
                    prefix = "\n";
                } else {
                    prefix = '';
                }
                return prefix + text + "![Bilde](" + l.pathname + "){:width=\"50%\" align=\"right\" title=\"Bilde\"}\n";
            });
            target.trigger('input');
        }

        var images = e.originalEvent.dataTransfer.files;
        if (images.length > 0) {
            console.log(images);
        }
    }).on("dragleave", function (event) {
        $(this).css('border', '#07c6f1 2px dashed');
        $(this).css('background', '#FFF');
        event.preventDefault();
        event.stopPropagation();
    });
}

function getLocation(href) {
    var l = document.createElement("a");
    l.href = href;
    return l;
}
