module UserHelper
  DEFAULT_HEAD_OPTIONS = {
    :notice => true,
    :message => true,
    :error => false
  }.freeze unless defined? DEFAULT_HEAD_OPTIONS

  def title_helper
    "#{controller.class.name} #{controller.action_name}"
  end

  def head_helper(label, options = {})
    opts = DEFAULT_HEAD_OPTIONS.dup
    opts.update(options.symbolize_keys)
    s = "<h3>#{label}</h3>"
    if flash['notice'] && (not opts[:notice].nil?) && opts[:notice]
      notice = "<div><p style=\"padding-left: 0.5em;padding-bottom: 0.5em;color: #08C\">#{flash['notice']}</p></div>"
      s = s + notice
    end
    if flash['message'] && (not opts[:message].nil?) && opts[:message]
      message = "<div><p style=\"padding-left: 0.5em;padding-bottom: 0.5em;color: #08C\">#{flash['message']}</p></div>"
      s = s + message
    end
    if (not opts[:error].nil?) && opts[:error]
      error = error_messages_for('user')
      s << error if error
    end
    s.html_safe
  end
end
