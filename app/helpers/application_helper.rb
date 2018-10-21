# frozen_string_literal: true

module ApplicationHelper
  include UserSystem
  include GraduationAccess

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

    time&.strftime('%H:%M')
  end

  def wday(wday_index)
    %w[Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag Søndag][wday_index]
  end

  def textalize(s)
    return '' if s.blank?

    html = Kramdown::Document.new(s.strip).to_html
    with_links = auto_link(html, link: :all, target: '_blank', sanitize: false)
    with_links.force_encoding(Encoding::UTF_8)
    absolute_links(with_links).html_safe # rubocop: disable Rails/OutputSafety
  end

  def textify(s)
    return '' if s.blank?

    h = Kramdown::Document.new(s.strip).to_kramdown.gsub(/\{: .*?\}\s*/, '')
    absolute_links(h)
  end

  def kramdown(src)
    src && (document = Kramdown::Document.new(src, html_to_native: true)) &&
        document.to_kramdown.gsub(/\s+\z/, "\n")
  end

  def absolute_links(html)
    base = root_url

    html.gsub(%r{\b(href|src)="(?:#{base}|/)([^?"]*)(\?[^"]*)?"}i) do |_m|
      with_base = %(#{Regexp.last_match(1)}="#{base}#{Regexp.last_match(2)}#{Regexp.last_match(3)}")

      params = []
      params << "email=#{Base64.encode64(@email)}" if @email
      params << "newsletter_id=#{@newsletter.id}" if @newsletter

      if params.any?
        %(#{with_base}#{Regexp.last_match(3) ? '&' : '?'}#{params.join('&')})
      else
        with_base
      end
    end
  end

  def holiday_label(date)
    return unless date

    date.month < 8 ? 'sommer' : 'jule'
  end
end

class Array
  def to_options(method = :name)
    map { |r| [r.respond_to?(:method) ? r.send(method) : r.to_s, r.id] }
  end
end
