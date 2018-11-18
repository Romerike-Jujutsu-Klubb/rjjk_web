# frozen_string_literal: true

class StatusController < ApplicationController
  PUBLIC_FILE = '/heap.json'

  def index; end

  def heap_dump
    File.open("#{Rails.root}/public#{PUBLIC_FILE}", 'w') { |file| ObjectSpace.dump_all(output: file) }
    redirect_to PUBLIC_FILE
  end
end
