class Organisms::Stats::TranscriptionComponent < ApplicationComponent
  def initialize(id:, title:, description:)
    @id = id
    @title = title
    @description = description
  end

  attr_reader :id, :title, :description
end
