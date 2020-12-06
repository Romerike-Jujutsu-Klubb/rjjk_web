// DateTime selector work in Datek Support
// .ui-dialog-content{
//     overflow:visible !important;
//  }

$().ready(function () {
    const iconSet = {
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
    // http://eonasdan.github.io/bootstrap-datetimepicker/#options
    $('.date,[dateFormat]').each(function () {
        const format = 'YYYY-MM-DD';
        const value = $(this).val();
        if (value) {
            $(this).val('');
            $(this).datetimepicker({format: format, defaultDate: value, icons: iconSet});
        } else {
            const defaultDate = $(this).data('default-date');
            if (defaultDate) {
                $(this).datetimepicker({format: format, defaultDate: defaultDate, icons: iconSet});
                $(this).val('');
            } else {
                $(this).datetimepicker({format: format, useCurrent: false, icons: iconSet});
            }
        }
        $(this).attr('autocomplete', 'off');
    });
    $('.datetime,[dateFormat][timeFormat]').each(function () {
        const value = $(this).val();
        if (value) {
            $(this).val('');
            $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', defaultDate: value, icons: iconSet});
        } else {
            const defaultDate = $(this).data('default-date');
            if (defaultDate) {
                $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', defaultDate: defaultDate, icons: iconSet});
                $(this).val('');
            } else {
                $(this).datetimepicker({format: 'YYYY-MM-DD HH:mm', useCurrent: false, icons: iconSet});
            }
        }
        $(this).attr('autocomplete', 'off');
    });
    $('.time,[timeFormat]').datetimepicker({format: 'HH:mm', icons: iconSet});
});
