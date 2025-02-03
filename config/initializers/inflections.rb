# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'API'
  inflect.acronym 'DGFIP'
  inflect.acronym 'DSFR'
  inflect.acronym 'GDPR'
  inflect.acronym 'INSEE'
  inflect.acronym 'NAF'
  inflect.acronym 'CRM'
  inflect.acronym 'QF'

  inflect.acronym 'HubEE'
  inflect.acronym 'DC'

  inflect.acronym 'CaptchEtat'
  inflect.irregular 'Hermes', 'Hermes'
  inflect.acronym 'ENSU'
  inflect.acronym 'CESU'
  inflect.acronym 'SFiP'
end

class String
  def classify
    custom_classifications = {
      'api_e_contacts' => 'APIEContacts',
      'APIEContacts' => 'APIEContacts',
      'api_ensu_documents' => 'APIENSUDocuments',
      'APIENSUDocuments' => 'APIENSUDocuments'
    }

    return custom_classifications[self] if custom_classifications.key?(self)

    ActiveSupport::Inflector.classify(self)
  end
end
