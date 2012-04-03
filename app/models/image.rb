# encoding: utf-8
class Image < ActiveRecord::Base
  include UserSystem

  belongs_to :user
  has_many :user_images
  has_many :likers, :class_name => 'User', :through => :user_images, :conditions => "user_images.rel_type = 'LIKE'", :source => :user

  before_create do
    self.user ||= current_user
  end

  validates_uniqueness_of :content_data, :on => :create

  def file=(file)
    return if file == ""
    self.name = file.original_filename if name.blank?
    self.content_data = file.read.force_encoding("ASCII-8BIT")
    self.content_type = file.content_type
  end

  if Rails.env == 'development'
    def content_data
      data = super
      if data =~ /^\\3(77|30)/
        logger.error "Image id=#{id} has invalid data."
        return eval("%Q{#{data}}")
      end
      data
    end
  end

  def format
    name.split('.').last
  end

  def video?
    content_type =~ /^video\//
  end

end
