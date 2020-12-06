$(window).on('load', function() {
  var iOSdevice = !!navigator.platform && /iPad|iPhone|iPod/.test(navigator.platform);
  if (iOSdevice)
    $('[role="tablist"] .nav-link').each(function(i,e) {
      if (!$(e).attr('href'))
        $(e).attr('href', $(e).data('target'))
    })
});
