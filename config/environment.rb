# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RjjkWeb::Application.initialize!

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>".html_safe }
