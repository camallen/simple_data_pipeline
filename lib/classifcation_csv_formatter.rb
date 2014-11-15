require_relative 'test_classification'
require 'pry'
require 'rb-readline'

class ClassificationCsvFormatter

  class FormatError < StandardError; end

  def format_classification(classification)
    begin
      @classification_hash = JSON.parse(classification)
    rescue JSON::ParserError
      raise FormatError.new
    end
    arrayify_hash
  end

  private

  def arrayify_hash
    {}.tap do |array_hash|
      @classification_hash.each do |key, value|
        case key
        when 'completed', 'gold_standard'
          array_hash[key] = value
        when 'metadata', 'links'
          array_hash.merge!(value)
        when 'annotations'
          array_hash[key] = value.to_json
        end
      end
    end
  end
end
