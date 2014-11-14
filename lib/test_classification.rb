require 'date'
require 'json'

class TestClassification

  def self.json_string
    {
      completed: true,
      metadata: self.metadata_values,
      annotations: self.annotation_values,
      links: {
        project: 1,
        workflow: 1,
        set_member_subject: 55,
      }
    }.to_json
  end

  private

  def self.metadata_values
    {
      started_at: DateTime.now,
      finished_at: DateTime.now,
      workflow_version: "1.1",
      user_language: 'en',
      user_agent: "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0"
    }
  end

  def self.annotation_values
    [ { "question_key" => "question_answer"},
      { "age" => "adult"} ]
  end
end
