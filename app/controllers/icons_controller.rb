# frozen_string_literal: true

class IconsController < ApplicationController
  caches_page :inline

  def inline
    width = params[:width].to_i
    icon = ChunkyPNG::Image.from_file("#{Rails.root}/public/favicon.ico")
    data = icon.resample_bilinear(width, width).to_blob

    send_data(data,
        disposition: 'inline',
        type: 'image/png',
        filename: "icon-#{width}x#{width}.png")
  end
end
