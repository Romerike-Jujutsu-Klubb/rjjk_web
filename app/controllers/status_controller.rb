# frozen_string_literal: true

class StatusController < ApplicationController
  def index; end

  def heap_dump
    render plain: ObjectSpace.dump_all(output: :string)
  end
end
