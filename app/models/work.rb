require 'thread'
require 'timeout'

module Work
  @queue = Queue.new
  @n_threads = 7
  @workers = []
  @running = true

  Job = Struct.new(:worker, :params)

  module_function

  def enqueue(worker, *params)
    @queue << Job.new(worker, params)
  end

  def start
    @workers = Array.new(@n_threads) { Thread.new { process_jobs } }
  end

  def process_jobs
    while @running
      job = nil
      Timeout.timeout(1) do
        job = @queue.pop
      end
      job.worker.new.call(*job.params)
    end
  end

  def drain
    loop do
      break if @queue.empty?
      sleep 1
    end
  end

  def stop
    @running = false
    @workers.each(&:join)
  end
end
