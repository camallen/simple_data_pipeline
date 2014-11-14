require 'jbundler'
require 'jruby-kafka'
require 'logger'
require 'pry'

class JrubyKafkaConsumer

  # Internal queue size used to hold events in memory after it has been read from Kafka
  QUEUE_SIZE = 20
  #for options see: https://github.com/joekiller/logstash-kafka/blob/master/lib/logstash/inputs/kafka.rb
  OPTIONS = {
    zk_connect: 'localhost:2181',
    group_id: 'pantopes_classifications',
    topic_id: 'test',
    rebalance_max_retries: 4,
    rebalance_backoff_ms: 2000,
    reset_beginning: nil,
    consumer_timeout_ms: -1,
    consumer_restart_on_error: true,
    consumer_restart_sleep_ms: 0,
    consumer_id: nil,
    fetch_message_max_bytes: 1048576,
  }

  def initialize
    @log = Logger.new(STDOUT)

    @queue = SizedQueue.new(QUEUE_SIZE)
    @group = Kafka::Group.new(options)
    reg_details = { group_id: options[:group_id],
                    topic_id: options[:topic_id],
                    zk_connect: options[:zk_connect] }
    log_event("Registering kafka, #{ reg_details }")
  end

  def run
    begin
      @group.run(1,@queue)
      begin
        while true
          #note: pop is blocking here!
          queue_event("#{@queue.pop}")
        end
      rescue ShutdownSignal
        log_event('Kafka got shutdown signal')
        @group.shutdown
      end
      until @queue.empty?
        queue_event("#{@queue.pop}")
      end
      log_event('Done running kafka input')
    rescue NoMethodError => e
      log_event("No method error: check your code! -> #{e.message}")
      raise e
    rescue => e
      log_event("attempting restarting after kafka client threw exception: #{e.message}")
      @group.shutdown if @group.running?
      backoff_consuming
      retry
    end
  end

  private

  def options
    OPTIONS
  end

  #create a formatter here to create the csv output / message
  def queue_event(message)
    log_event(message)
  end

  def log_event(message)
    @log.info(message)
  end

  def backoff_consuming
    sleep(Float(options[:consumer_restart_sleep_ms]) * 1 / 1000)
  end
end
