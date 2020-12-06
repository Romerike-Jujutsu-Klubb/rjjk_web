# frozen_string_literal: true

module ParallelRunner
  CONCURRENT_REQUESTS = 3

  private

  # TODO(uwe): Use concurrent-ruby instead?
  def in_parallel(values)
    queue = Queue.new
    values.each { |value| queue << value }
    threads = Array.new(CONCURRENT_REQUESTS) do
      Thread.start { Rails.application.executor.wrap { yield(queue.pop(true), queue) until queue.empty? } }
    end
    threads.each(&:join)
  end
end
