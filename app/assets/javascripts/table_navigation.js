$(function () {
    $('table[data-record-path]').click(function (event) {
        console.trace(event);
        console.trace(event.target);
        var row = $(event.target).closest('tr');
        console.trace(row);
        window.location = row.closest('table').data('record-path') + '/' + row.data('record-id')
    }).css('cursor', 'pointer').addClass('table-hover');
});
