require 'poseidon'

producer = Poseidon::Producer.new(["localhost:9092"], "test_producer")

messages = []
messages << Poseidon::MessageToSend.new("topic1", "value1")
messages << Poseidon::MessageToSend.new("topic2", "value for topic2")
producer.send_messages(messages)
