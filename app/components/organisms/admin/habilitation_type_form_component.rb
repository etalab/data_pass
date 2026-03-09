class Organisms::Admin::HabilitationTypeFormComponent < ApplicationComponent
  def initialize(habilitation_type:, data_providers: DataProvider.order(:name))
    @habilitation_type = habilitation_type
    @data_providers = data_providers
  end

  private

  attr_reader :habilitation_type, :data_providers
end
