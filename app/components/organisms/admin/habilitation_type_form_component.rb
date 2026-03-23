class Organisms::Admin::HabilitationTypeFormComponent < ApplicationComponent
  def initialize(habilitation_type:, disabled: false, data_providers: DataProvider.order(:name))
    @habilitation_type = habilitation_type
    @disabled = disabled
    @data_providers = data_providers
  end

  def disabled?
    @disabled == true
  end

  def structural_fields_locked?
    @disabled == :structural || disabled?
  end

  private

  attr_reader :habilitation_type, :data_providers
end
