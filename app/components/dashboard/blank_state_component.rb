class Dashboard::BlankStateComponent < ApplicationComponent
  renders_one :action

  attr_reader :pictogram_path, :pictogram_alt, :pictogram_class, :message

  def initialize(pictogram_path:, message:, pictogram_alt: '', pictogram_class: 'fr-responsive-img fr-artwork--large')
    @pictogram_path = pictogram_path
    @pictogram_alt = pictogram_alt
    @pictogram_class = pictogram_class
    @message = message
  end
end
