# frozen_string_literal: true

# http://tenderlove.github.io/heap-analyzer/

class StatusController < ApplicationController
  HEAP_DUMP_PATH = "#{Rails.root}/public"
  HEAP_DUMP_PREFIX = 'heap_'
  HEAP_DUMP_SUFFIX = '.json'

  def index
    render layout: false
    @heap_dumps = Dir["#{HEAP_DUMP_PATH}/#{HEAP_DUMP_PREFIX}*#{HEAP_DUMP_SUFFIX}"].sort
        .map { |f| [f.split('/').last, File.size(f)] }
  end

  def health
    render plain: 'OK'
  end

  def heap_dump
    public_file = "/#{HEAP_DUMP_PREFIX}#{Time.current.strftime('%F_%H%M')}#{HEAP_DUMP_SUFFIX}"
    File.open("#{HEAP_DUMP_PATH}#{public_file}", 'w') { |file| ObjectSpace.dump_all(output: file) }
    redirect_to public_file
  end

  def gc
    GC.start
    redirect_to :status, notice: 'GC started.'
  end
end
