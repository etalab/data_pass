class Organisms::Admin::HabilitationTypeFormComponent < ApplicationComponent
  def initialize(habilitation_type:)
    @habilitation_type = habilitation_type
    @data_providers = DataProvider.order(:name)
  end

  private

  attr_reader :habilitation_type, :data_providers
end
