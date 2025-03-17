class ContactDefinition
  attr_reader :type, :options

  FILLABLE_WITH_APPLICANT_DATA_TYPES = %i[contact_technique contact_metier administrateur_metier].freeze

  def initialize(type, options = {})
    @type = type
    @options = options
  end

  def required_personal_email?
    options.fetch(:required_personal_email, false)
  end

  def fill_data_with_applicant_data?
    type.in?(FILLABLE_WITH_APPLICANT_DATA_TYPES)
  end
end
