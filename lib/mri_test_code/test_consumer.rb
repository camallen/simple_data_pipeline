require 'poseidon'

class TestConsumer

  CONSUMER_ID = 'test_consumer'
  BROKERS = ["localhost:9092"]
  TOPICS = ['topic1', 'topic2']
  READ_OFFSET = :earliest_offset

  def initialize
    @broker = Poseidon::BrokerPool.new(CONSUMER_ID, BROKERS)
    @consumers = []
    @cluster_metadata = Poseidon::ClusterMetadata.new
    setup_topic_parition_consumers
  end

  def consume_messages
    loop do
      @consumers.each do |consumer|
        # puts 'attempting to fetch message from partition consumer'
        messages = consumer.fetch
        messages.each do |m|
          puts m.value
        end
        sleep 1
      end
    end

  end

  private

  def topic_partition_count(topic)
    @cluster_metadata.update(@broker.fetch_metadata([topic]))
    @cluster_metadata.topic_metadata[topic].partition_count
  end

  def lead_broker_for_topic_parition(topic, partition)
    @cluster_metadata.lead_broker_for_partition(topic, partition)
  end

  def setup_topic_parition_consumers
    TOPICS.each do |topic|
      topic_partition_count(topic).times do |partition_count|
        consumer_opts = [CONSUMER_ID, BROKERS, topic, partition_count, READ_OFFSET]
        @consumers << Poseidon::PartitionConsumer.consumer_for_partition(*consumer_opts)
      end
    end
  end
end

#drive it!
test_consumer = TestConsumer.new
test_consumer.consume_messages
