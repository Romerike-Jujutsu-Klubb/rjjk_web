# frozen_string_literal: true

# http://tenderlove.github.io/heap-analyzer/

class StatusController < ApplicationController
  HEAP_DUMP_PATH = "#{Rails.root}/public"
  HEAP_DUMP_PREFIX = 'heap_'
  HEAP_DUMP_SUFFIX = '.json'

  def index
    @heap_dumps = Dir["#{HEAP_DUMP_PATH}/#{HEAP_DUMP_PREFIX}*#{HEAP_DUMP_SUFFIX}"]
        .map { |f| [f.split('/').last, File.size(f)] }
  end

  def heap_dump
    public_file = "/#{HEAP_DUMP_PREFIX}#{Time.current.strftime('%F_%H%M')}#{HEAP_DUMP_SUFFIX}"
    File.open("#{HEAP_DUMP_PATH}#{public_file}", 'w') { |file| ObjectSpace.dump_all(output: file) }
    redirect_to public_file
  end
end
