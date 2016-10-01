class Consumer
  # Just print the value and sleep a random
  # amount of time to simulate computation.
  def process(value)
    sleep rand(10) # simulate computation time
    puts "consumed: #{value.to_s}"
  end
end

class MonitorConsumer < Consumer
  # @param priority - denotes whether job should be
  # processed as priority or normal
  def process(job, priority=false)
    if priority
      puts "priority consumed: #{job.to_s}"
    else
      # instead we will act as a normal consumer
      super job
    end
  end
end
