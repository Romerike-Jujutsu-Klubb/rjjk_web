# frozen_string_literal: true

class ImageGalleryController < ApplicationController
  before_action :authenticate_user, only: %i[mine].freeze

  caches_page :show, :inline
  cache_sweeper :image_sweeper, only: %i[update destroy]

  def gallery
    image_select = Image
        .select(%i[approved content_type description google_drive_reference height id name public user_id
                   width])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
    image_select = image_select.includes(:user)
    image_select = image_select.where('approved = ?', true) unless admin?
    image_select = image_select.where('public = ?', true) unless user?
    @image = image_select.where(id: params[:id]).first || image_select.first
    @images = image_select.to_a
  end

  def mine
    image_select = Image
        .select(%i[approved content_type description google_drive_reference height id name public user_id
                   width])
        .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
        .order('created_at DESC')
        .includes(:user_like)
    image_select = image_select.where('user_id = ?', current_user.id)
    image_select = image_select.includes(:user)
    @images = image_select.to_a
    @image = Image.find_by(id: params[:id]) || @images.first
    render action: :gallery
  end
end
