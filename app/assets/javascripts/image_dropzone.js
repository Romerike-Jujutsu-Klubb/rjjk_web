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

        var data_html = e.originalEvent.dataTransfer.getData('text/html');
        image_src = $(data_html).filter('img').attr('src');

        if (image_src) {
            image_url = image_src;
        } else {
            image_url = e.originalEvent.dataTransfer.getData('URL');
        }
        if (image_url) {
            if (image_url.startsWith("data:")) {
                return;
            }
            var l = getLocation(image_url);
            if (l.hostname === window.location.hostname) {
                image_url = l.pathname
            }

            target.val(function (i, text) {
                if (text && !text.endsWith("\n")) {
                    prefix = "\n";
                } else {
                    prefix = '';
                }
                return text + prefix + "![Bilde](" + image_url + " \"Bilde\"){:width=\"50%\" align=\"right\"}\n";
            });
            target.trigger('input');
        }

        var images = e.originalEvent.dataTransfer.files;
        if (images.length > 0) {
            console.log(images);
            target.val(function (i, text) {
                if (text && !text.endsWith("\n")) {
                    prefix = "\n";
                } else {
                    prefix = '';
                }
                return text + prefix + images + "\n";
            });
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
