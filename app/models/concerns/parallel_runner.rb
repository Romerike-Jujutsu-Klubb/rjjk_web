# frozen_string_literal: true

module ParallelRunner
  # TODO(uwe): Test with multiple threads when https://github.com/vcr/vcr/issues/200 is fixed
  CONCURRENT_REQUESTS = Rails.env.development? || Rails.env.test? ? 1 : 7
  # ODOT

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
