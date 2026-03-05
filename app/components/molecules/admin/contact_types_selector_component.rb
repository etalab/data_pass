class Molecules::Admin::ContactTypesSelectorComponent < ApplicationComponent
  CONTACT_TYPES = %w[contact_technique contact_metier responsable_traitement delegue_protection_donnees].freeze

  def initialize(form:, habilitation_type:)
    @form = form
    @habilitation_type = habilitation_type
  end

  private

  attr_reader :form, :habilitation_type

  def checked_contact_types
    habilitation_type.contact_types || []
  end
end
