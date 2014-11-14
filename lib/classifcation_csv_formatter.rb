require_relative 'test_classification'
require 'pry'

class ClassificationCsvFormatter

  def format_classification(classification)
    @classification_hash = JSON.parse(classification)
    @non_annotation_hash = flatten_hash
    convert_annotations_to_arrays
  end

  private

  def flatten_hash
    {}.tap do |flat_hash|
      @classification_hash.each do |key, value|
        case key
        when 'completed', 'gold_standard'
          flat_hash[key] = value
        when 'metadata', 'links'
          flat_hash.merge!(value)
        end
      end
    end
  end

  def merge_annotations
    @classification_hash['annotations'].map do |annotation|
      @non_annotation_hash.dup.merge!(annotation)
    end
  end

  def convert_annotations_to_arrays
    merge_annotations.map do |hash|
      hash.values.to_a
    end
  end
end
