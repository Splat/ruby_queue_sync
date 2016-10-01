require 'thread'
require_relative 'consumer'

semaphore = Mutex.new
queue = Queue.new

producer = Thread.new do
  100.times do |i|
    sleep rand(3) # simulate time between production
    # lets assume the producer sends the published time stamp
    # this would eventually be handled my queue extension on push
    item = {num:i, ts: Time.now.to_i}
    queue << item
    puts "produced - #{item.to_s}"
  end
end

consumer = Thread.new do
  consumer = Consumer.new
  
  loop do
    job = nil
    
    semaphore.synchronize {
      job = queue.pop unless queue.empty?
    }
    # process or wait outside the lock
    unless job.nil?
      consumer.process job
    else
      puts "consumer sleeping - queue currently empty"
      sleep(1)
    end
  end
end

# there is a better solution here where the monitor
# would peek to see if the queue is behind and the 
# peek and pop operations would have a lock around
# them. However extending the Queue class to do this
# and test across many threads is a bit much for this
# proof of concept. 
monitor = Thread.new do
  monitor_consumer = MonitorConsumer.new
  behind_threshold = 0.5 # seconds denoting behind. problem asks for 60 seconds but this is to illustrate

  loop do
    job = nil
    # check needs a lock in case popped after empty check
    semaphore.synchronize { 
      job = queue.pop unless queue.empty?
    }
    
    if job # attempt to process outside the mutex
      if Time.now.to_i - job[:ts] > behind_threshold # check if processing is behind
        monitor_consumer.process job, true
        next # since we are behind go right to the next loop
      else
        monitor_consumer.process job
      end
    end

    # if we get here the job wasn't priority so we can sleep outside mutex
    puts "monitor sleeping - queue currently empty"
    sleep(1)
  end
end                                 

threads = []
threads << consumer
threads << monitor
threads.each { |thread| thread.join }
