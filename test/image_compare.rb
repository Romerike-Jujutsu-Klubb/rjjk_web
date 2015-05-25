#!ruby

require 'chunky_png'

class ImageCompare
  include ChunkyPNG::Color

  def self.compare(file_name, old_file_name, dimensions = nil)
    name = file_name.chomp('.png')
    org_file_name = "#{name}_0.png~"
    new_file_name = "#{name}_1.png~"

    return nil unless File.exists? old_file_name

    old_file = File.read(old_file_name)
    new_file = File.read(file_name)

    return false if old_file == new_file

    images = [
        ChunkyPNG::Image.from_blob(old_file),
        ChunkyPNG::Image.from_blob(new_file),
    ]

    if dimensions
      images.map! do |i|
        if i.dimension.to_a == dimensions || i.width < dimensions[0] || i.height < dimensions[1]
          i
        else
          i.crop(0, 0, *dimensions)
        end
      end
    end

    sizes = images.map(&:width).uniq + images.map(&:height).uniq
    if sizes.size != 2
      puts "Image size has changed for #{name}: #{images.map { |i| "#{i.width}x#{i.height}" }.join(' => ')}"
      return true
    end

    org_img = images.first
    new_img = images.last

    if org_img.pixels == new_img.pixels
      File.delete(org_file_name) if File.exists?(org_file_name)
      File.delete(new_file_name) if File.exists?(new_file_name)
      return false
    end

    top = bottom = nil
    left = org_img.width
    right = 0
    org_img.height.times do |y|
      (0...left).find do |x|
        unless org_img[x, y] == new_img[x, y]
          top ||= y
          bottom = y
          right = x if right < x
          left = x
        end
      end
      (org_img.width - 1).step(right + 1, -1).find do |x|
        unless org_img[x, y] == new_img[x, y]
          top ||= y
          bottom = y
          right = x
        end
      end
    end
    (1..2).each do |i|
      images.each do |image|
        image.rect(left - 1, top - 1, right + 1, bottom + 1, ChunkyPNG::Color.rgb(255, 0, 0))
      end
    end
    org_img.save(org_file_name)
    new_img.save(new_file_name)
    true
  end
end

if $0 == __FILE__
  unless ARGV.size == 2
    puts "Usage:  #$0 <image1> <image2>"
    exit 1
  end
  ImageCompare.compare(ARGV[0], ARGV[1])
end
