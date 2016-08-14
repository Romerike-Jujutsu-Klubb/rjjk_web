module ApplicationHelper
  include UserSystem

  def menu_item(name, options = {})
    options[:controller] ||= 'info'
    link_to name,
        { controller: options[:controller], action: options[:action],
            id: options[:id], anchor: options[:anchor] },
        class: (controller.controller_name.to_s == options[:controller].to_s ? 'active' : nil)
  end

  def yes_no(bool)
    if bool == true
      'Ja'
    else
      'Nei'
    end
  end

  def l(time)
    return t(time) if time.is_a?(Symbol) || time.is_a?(String)
    super
  end

  def t(time)
    return super if time.is_a?(Symbol) || time.is_a?(String)
    time && time.strftime('%H:%M')
  end

  def wday(wday_index)
    %w(Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag Søndag)[wday_index]
  end

  def textalize(s)
    return '' if s.nil?
    with_emails = s.gsub(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) do |m|
      mail_to m, nil # , :encode => :javascript
    end
    html = Kramdown::Document.new(with_emails.strip).to_html
    html.force_encoding(Encoding::UTF_8)
    html_with_base = absolute_links(html)
    html_with_bold_links = html_with_base
        .gsub(/(<a href="[^"]*")>/i,
            %(\\1 style="color: #CD071E;text-decoration:none;font-weight:bold;">))
    html_with_bold_links.html_safe
  end

  def absolute_links(html)
    base = url_for(controller: :welcome, action: :index, only_path: false)

    html.gsub(%r{\b(href|src)="(?:#{base}|/)([^?"]*)(\?[^"]*)?"}i) do |_m|
      with_base = %(#{$1}="#{base}#{$2}#{$3}")

      params = []
      params << "email=#{Base64.encode64(@email)}" if @email
      params << "newsletter_id=#{@newsletter.id}" if @newsletter

      if params.any?
        %(#{with_base}#{$3 ? '&' : '?'}#{params.join('&')})
      else
        with_base
      end
    end
  end

  def textify(s)
    return '' if s.blank?
    h = Kramdown::Document.new(s.strip).to_kramdown.gsub(/\{: .*?\}\s*/, '')
    h2 = absolute_links(h)
    h2
  end
end

class Array
  def to_options(method = :name)
    map { |r| [r.respond_to?(:method) ? r.send(method) : r.to_s, r.id] }
  end
end
