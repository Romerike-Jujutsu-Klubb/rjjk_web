# frozen_string_literal: true

LAZYLOAD_PLACEHOLDER = <<~IMAGE.chomp
  data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAANSURBVBhXYzh8+PB/AAffA0nNPuCLAAAAAElFTkSuQmCC
IMAGE
# LAZYLOAD_PLACEHOLDER = <<~IMAGE.chomp
#   data:image/gif;base64,R0lGODdhAQABAPAAAMPDwwAAACwAAAAAAQABAAACAkQBADs=
# IMAGE

ActionView::Helpers::AssetTagHelper.module_eval do
  alias_method :rails_image_tag, :image_tag

  def image_tag(*attrs)
    options, args = extract_options_and_args(*attrs)
    image_html = rails_image_tag(*args)

    if options[:lazy]
      to_lazy(image_html)
    else
      image_html
    end
  end

  private

  def to_lazy(image_html)
    img = Nokogiri::HTML::DocumentFragment.parse(image_html).at_css('img')

    img['class'] = "#{img['class']} lazyload"
    img['data-src'] = img['src']
    img['src'] = LAZYLOAD_PLACEHOLDER

    img.to_s.html_safe # rubocop: disable Rails/OutputSafety
  end

  def extract_options_and_args(*attrs)
    args = attrs

    if args.size > 1
      options = attrs.last.dup
      args.last.delete(:lazy)
    else
      options = {}
    end

    [options, args]
  end
end
