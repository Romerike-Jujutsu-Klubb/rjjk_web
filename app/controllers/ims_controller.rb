# frozen_string_literal: true

class ImsController < ApplicationController
  def index; end

  def import
    flash.notice = 'File'
    redirect_to ims_index_path, notice: 'Filen er importert.'
  end
end
