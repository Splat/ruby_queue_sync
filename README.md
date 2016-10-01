# ruby_queue_sync

This is just a little project to illustrate Ruby threads processing off a queue. There are normal consumers which are cheap and take and arbitrary amount of time to execute. Furthermore there is a monitor thread which also processes work but if the amount of time a job has spent in the queue exceeds a predefined threashold, the monitor will "priority" process those jobs until the threshold is satisfied. Essentially we don't define the priority processing but assume it's expensive and blazing fast. 

Threads except the producer assume there will always be a potential of work to execute.

# notes... 
* the monitor is probably unneeded as consumers can also play the monitor role
* could use some graceful shutdown
* should move all the thresholds and timing stuff to a config.yaml

# to run
ruby main.rb
