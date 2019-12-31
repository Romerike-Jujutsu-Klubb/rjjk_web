# frozen_string_literal: true

module ApplicationHelper
  include UserSystem
  include GraduationAccess

  def accepts_webp?
    request.headers['HTTP_ACCEPT'] =~ %r{image/webp}
  end

  def image_url_with_cl(image, width: nil)
    format = if accepts_webp?
               image.video? && accepts_webp? ? :webm : :webp
             else
               image.format
             end
    if image.cloudinary_identifier
      options = { format: format }
      options.merge!(width: width, height: width, crop: :fit) if width
      if image.video?
        cl_video_path(image.cloudinary_identifier, options)
      else
        cl_image_path(image.cloudinary_identifier, options)
      end
    else
      image_path(image.id, format: format)
    end
  end

  def menu_item(name, options = {})
    if options.is_a? Hash
      options[:controller] ||= 'info'
      path = url_for(controller: options[:controller], action: options[:action], id: options[:id],
          anchor: options[:anchor])
    else
      path = options
    end
    target_controller = Rails.application.routes.recognize_path(path)[:controller]
    css_class = (controller.controller_name.to_s == target_controller ? 'active' : nil)
    link_to name, path, class: css_class
  end

  def yes_no(bool)
    if bool == true
      'Ja'
    else
      'Nei'
    end
  end

  def day_name(wday_index)
    I18n.t('date.day_names')[wday_index % 7]
  end

  def month_name(month_index)
    name = I18n.t('date.month_names')[month_index]
    name = name.downcase if I18n.locale == :nb
    name
  end

  def textalize(s, newlines: false)
    return '' if s.blank?

    s = s.strip
    s.gsub!(/(?<!\n)\n(?!\n)/, '<br/>') if newlines

    html = Kramdown::Document.new(s).to_html
    with_links = auto_link(html, link: :all, target: '_blank', sanitize: false)
    with_links.force_encoding(Encoding::UTF_8)
    with_inline_images = with_links.gsub(%r{(src=".*/images/\d+)(\.[^."])?"}) do
      %(#{Regexp.last_match(1)}/inline#{Regexp.last_match(2) || '.jpg'}")
    end
    absolute_links(with_inline_images).html_safe # rubocop: disable Rails/OutputSafety
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
