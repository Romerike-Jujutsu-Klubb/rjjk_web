# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RjjkWeb::Application.initialize!

#FIXME(uwe): Report to RedCloth
if RUBY_PLATFORM =~ /java/
  module RedCloth
    class TextileDoc
      def initialize( string, restrictions = [] )
        restrictions.each { |r| method("#{r}=").call( true ) }
        super(string.chars.map{|x| x.bytes.to_a.size > 1 ? "&##{x.unpack("U*").join};" : x}.join)
      end
    end
  end
end

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>".html_safe }
