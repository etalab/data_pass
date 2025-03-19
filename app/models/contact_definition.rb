class ContactDefinition
  attr_reader :type, :options

  EXCLUDED_FROM_APPLICANT_DATA_TYPES = %i[responsable_traitement delegue_protection_donnees].freeze

  def initialize(type, options = {})
    @type = type
    @options = options
  end

  def required_personal_email?
    options.fetch(:required_personal_email, false)
  end

  def fill_data_with_applicant_data?
    options.fetch(:fillable_with_applicant_data) do
      !type.in?(EXCLUDED_FROM_APPLICANT_DATA_TYPES)
    end
  end
end
