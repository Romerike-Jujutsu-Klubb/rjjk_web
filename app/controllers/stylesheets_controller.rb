class StylesheetsController < ApplicationController
  layout false

  def dark_ritual
    @content_width = (params[:width] && params[:width].to_i) || 540
    render :content_type => 'text/css'
  end
  
end
