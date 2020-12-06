function append_line(target, line) {
    target.val(function (i, text) {
        if (text && !text.endsWith("\n")) {
            prefix = "\n";
        } else {
            prefix = '';
        }
        return text + prefix + line + "\n";
    });
}

function upload_tag(name) {
    return '<Uploading ' + name + ' />';
}

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

            var base = new String(image_url).substring(image_url.lastIndexOf('/') + 1);
            if (base.length > 16) {
                base = 'Bilde'
            }
            append_line(target, "![" + base + "](" + image_url + ' "' + base + '"){:width="50%" align="right"}');
            target.trigger('input');
        }

        var images = e.originalEvent.dataTransfer.files;

        for (var i = 0; i < images.length; i++) {
            var image = images[i];
            var name = image.name;
            append_line(target, upload_tag(name));
            var fd = new FormData();
            fd.append('image[file]', image);
            fd.append('image[name]', name);
            $.ajax({
                url: '/image_dropzone/upload',
                type: 'post',
                data: fd,
                contentType: false,
                processData: false,
                dataType: 'json',
                success: function (response) {
                    target.val(
                        target.val().replace(upload_tag(response.org_name), '![' + response.name + '](/images/' + response.id + ' "' + response.name + '"){:width="50%" align="right"}')
                    );
                    target.trigger('input');
                }
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
