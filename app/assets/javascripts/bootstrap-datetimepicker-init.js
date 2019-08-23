// http://makandracards.com/makandra/1383-rails-3-make-link_to-remote-true-replace-html-elements-with-jquery
// link_to 'Do something', path_returning_partial, :remote => true, :"data-replace" => '#some_id'
$().ready(function () {
    var iconSet = {
        time: 'far fa-clock',
        date: 'fa fa-calendar-alt',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down',
        previous: 'fa fa-chevron-left',
        next: 'fa fa-chevron-right',
        today: 'fa fa-screenshot',
        clear: 'fa fa-trash',
        close: 'fa fa-remove'
    };
    $('[data-remote][data-replace]').data('type', 'html');
    $(document).on('ajax:success', '[data-remote][data-replace]', function (event, data) {
        var $this = $(this);
        $($this.data('replace')).replaceWith(data);
        $this.trigger('ajax:replaced');
    });

    // http://eonasdan.github.io/bootstrap-datetimepicker/#options
    $('.date,[dateFormat]').each(function () {
        const format = 'YYYY-MM-DD';
        var value = $(this).val();
        if (value) {
            $(this).val('');
            $(this).datetimepicker({format: format, defaultDate: value, icons: iconSet});
        } else {
            var defaultDate = $(this).data('default-date');
            if (defaultDate) {
                $(this).datetimepicker({format: format, defaultDate: defaultDate, icons: iconSet});
                $(this).val('');
            } else {
                $(this).datetimepicker({format: format, useCurrent: false, icons: iconSet});
            }
        }
    });
    $('.datetime,[dateFormat][timeFormat]').each(function () {
        var value = $(this).val();
        if (value) {
            $(this).val('');
            $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', defaultDate: value, icons: iconSet});
        } else {
            var defaultDate = $(this).data('default-date');
            if (defaultDate) {
                $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', defaultDate: defaultDate, icons: iconSet});
                $(this).val('');
            } else {
                $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', useCurrent: false, icons: iconSet});
            }
        }
    });
    $('.time,[timeFormat]').datetimepicker({format: 'HH:mm', icons: iconSet});
});
