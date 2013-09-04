Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Load the rails application
require File.expand_path('../application', __FILE__)

require 'schema_plus_fix'

# Initialize the rails application
RjjkWeb::Application.initialize!

#FIXME(uwe): Report to RedCloth
require 'redcloth/textile_doc'
module RedCloth
  module Formatters
    module Plain
      class Sanitizer
        def self.strip_tags(text)
          # use Rails Sanitizer if available
          begin
            text.force_encoding(Encoding::UTF_8)
            text = ActionController::Base.helpers.strip_tags(text)
          rescue
            # otherwise, use custom method inspired from:
            # RedCloth::Formatters::HTML.clean_html
            # not very secure, but it's ok as output is still
            # meant to be escaped if it needs to be shown
            text.gsub!( /<!\[CDATA\[/, '' )
            text.gsub!( /<(\/*)([A-Za-z]\w*)([^>]*?)(\s?\/?)>/ ){|m| block_given? ? yield(m) : ""}
          end
          CGI.unescapeHTML(text)
        end
      end
    end
  end

  class TextileDoc
    def initialize(string, restrictions = [])
      restrictions.each { |r| method("#{r}=").call(true) }
      super(string.chars.map { |x| x.bytesize > 1 ? "&##{x.unpack('U*').first};" : x }.join)
    end

    def to_plain(*rules)
      apply_rules(rules)
      output = to(Formatters::Plain)
      output.force_encoding(Encoding::UTF_8)
      output = Formatters::Plain::Sanitizer.strip_tags(output)
      output.gsub('!LINK_OPEN_TAG!', '<').gsub('!LINK_CLOSE_TAG!', '>')
    end
  end
end

ActionView::Base.field_error_proc = Proc.new { |html_tag, _| "<span class=\"fieldWithErrors\">#{html_tag}</span>".html_safe }

class TimeOfDay
  def min
    minute
  end
  def day
    nil
  end
  def month
    nil
  end
  def year
    nil
  end
  def day_phase
    self < self.class.new(17, 0) ? 'dag' : 'kveld'
  end
end
