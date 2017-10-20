# frozen_string_literal: true

module ParallelRunner
  # TODO(uwe): Test with multiple threads when https://github.com/vcr/vcr/issues/200 is fixed
  CONCURRENT_REQUESTS = Rails.env.test? ? 1 : 7
  # ODOT

  private

  def in_parallel(values)
    queue = Queue.new
    values.each { |value| queue << value }
    threads = Array.new(CONCURRENT_REQUESTS) do
      Thread.start do
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            loop { yield queue.pop(true) }
          rescue ThreadError => e
            logger.debug "ThreadError running parallel tasks: #{e}"
          end
        end
      end
    end
    threads.each(&:join)
  end
end
