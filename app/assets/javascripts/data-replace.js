// http://makandracards.com/makandra/1383-rails-3-make-link_to-remote-true-replace-html-elements-with-jquery
// link_to 'Do something', path_returning_partial, :remote => true, :"data-replace" => '#some_id'

$(function () {
    $('[data-remote][data-replace]').data('type', 'html');
    $(document).on('ajax:success', '[data-remote][data-replace]', function (event, data) {
        var $this = $(this);
        $($this.data('replace')).replaceWith(data);
        $this.trigger('ajax:replaced');
    });
});
