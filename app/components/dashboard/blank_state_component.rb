class Dashboard::BlankStateComponent < ApplicationComponent
  renders_one :action

  attr_reader :pictogram_path, :message

  def initialize(pictogram_path:, message:)
    @pictogram_path = pictogram_path
    @message = message
  end
end
