$(function () {
    $('table[data-record-path]').click(function (event) {
        var row = $(event.target).closest('tr');
        var record_id = row.data('record-id');
        if (!record_id) {
            return
        }
        window.location = row.closest('table').data('record-path') + '/' + record_id
    }).css('cursor', 'pointer').addClass('table-hover');
});
