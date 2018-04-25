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
      Thread.start do
        Rails.application.executor.wrap do
          begin
            loop { yield queue.pop(true), queue }
          rescue ThreadError => e
            logger.debug "ThreadError running parallel tasks: #{e}"
          end
        end
      end
    end
    threads.each(&:join)
  end
end
