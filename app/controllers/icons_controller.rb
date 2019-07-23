# frozen_string_literal: true

class IconsController < ActionController::Base
  caches_page :inline, :notification_icon

  def inline
    width = params[:width].to_i
    icon = ChunkyPNG::Image.from_file("#{Rails.root}/public/favicon.ico")
    data = icon.resample_bilinear(width, width).to_blob
    send_data(data, disposition: 'inline', type: 'image/png', filename: "icon-#{width}x#{width}.png")
  end

  COLORS = {
    ChunkyPNG::Color.parse('030303FF') => ChunkyPNG::Color::WHITE,
    ChunkyPNG::Color.parse('FFFFFFFF') => ChunkyPNG::Color::TRANSPARENT,
    ChunkyPNG::Color.parse('E10916FF') => ChunkyPNG::Color::TRANSPARENT,
    ChunkyPNG::Color.parse('FFB403FF') => ChunkyPNG::Color::WHITE,
    ChunkyPNG::Color.parse('026CB6FF') => ChunkyPNG::Color::TRANSPARENT,
    ChunkyPNG::Color.parse('03145CFF') => ChunkyPNG::Color::WHITE,
  }.freeze

  def notification_icon
    width = 320
    icon = ChunkyPNG::Image.from_file("#{Rails.root}/public/favicon.ico")
    icon.width.times do |x|
      icon.height.times do |y|
        icon[x, y] =
            if ChunkyPNG::Color.a(icon[x, y]) < 0x40
              ChunkyPNG::Color::TRANSPARENT
            else
              color = ChunkyPNG::Color.opaque!(icon[x, y])
              COLORS.min_by { |c, _t| ChunkyPNG::Color.euclidean_distance_rgba(c, color) }[1]
            end
      end
    end
    send_data(icon.to_blob, disposition: 'inline', type: 'image/png',
        filename: "notification_icon-#{width}x#{width}.png")
  end
end
