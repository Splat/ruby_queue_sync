require 'thread'

queue = Queue.new
puts 'made Queue'

producer = Thread.new do
  10.times do |i|
    sleep rand(i) # simulate expense
    # lets assume the producer sends the published
    # time stamps in seconds or an eventual Queue
    # extension override on push would handle this
    # hash creation. 
    queue << {num:i, ts: Time.now.sec}
    puts "#{i} produced"
  end
end

# simulates normal consumption... longer running
def consume(value)
 sleep(5) # simulate slow computation
 puts "consumed #{value.to_s}"
end

# simulates priority consumption... fast and expensive
def priority_consume(value)
 sleep(1) # simulate BLAZING computation
 puts "priority consumed #{value.to_s}"
end

consumer = Thread.new do
  # empty wouldn't be bounded and instead be sleep in prod
  while true 
    if not queue.empty?
      consume queue.pop
    else
      puts "queue currently empty"
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
#
# the monitor thread essentially pops just like the 
# consumer thread but sleeps the time of the popped 
# itemminus the threshold that's acceptable. If the 
# item is within bounds it processes like a consumer
# and if not it offloads to the high priority process.
monitor = Thread.new do
  while true
    if not queue.empty?
      # here is where the lock/mutex would force the
      # normal consumer to wait while peeking
      value = queue.pop
      if (Time.now.sec - value[:ts]) > 1
        priority_consume value
      else
        # instead we will act as a normal consumer
        consume value
      end
    else
      puts "queue currently empty"
      sleep(1)
    end
  end
end                                 

consumer.join
monitor.join

#threads = []
#threads << consumer
#threads << monitor
#threads.each { |thread| thread.join }
