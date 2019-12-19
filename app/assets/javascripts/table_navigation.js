function activate_table_navigation() {
  $('table[data-record-path] tr[data-record-id]').click(function(event) {
    var row = $(event.target).closest('tr');
    var record_id = row.data('record-id');
    if (!record_id) {
      return
    }
    window.location = row.closest('table').data('record-path') + '/' + record_id
  }).css('cursor', 'pointer').addClass('table-hover').hover(function() {
    $(this).css('background-color', 'rgba(0,0,0,.075)')
  }, function() {
    $(this).css('background-color', '')
  });
}

if (typeof Turbolinks !== 'undefined' && Turbolinks.supported) {
  $(document).on('turbolinks:load', activate_table_navigation);
} else {
  $(activate_table_navigation);
}
