dgfip_authorizations_definitions = AuthorizationDefinition.all.select { |definition| definition.provider.id == 'dgfip' }
dgfip_authorizations_types = dgfip_authorizations_definitions.map { |definition| definition.authorization_request_class.to_s }

invalid_ar = AuthorizationRequest.where(dirty_from_v1: true, type: dgfip_authorizations_types)

invalid_ar_with_errors = invalid_ar.map do |ar| 
  begin
    if ar.valid?
      nil
    else
      { id: ar.id, form: ar.form_uid, state: ar.state, errors: ar.errors.full_messages.join("\n") }
    end
  rescue => e
    { id: ar.id, form: ar.form_uid, state: ar.state, errors: e.message }
  end
end.compact

require 'csv'

csv_string = CSV.generate(force_quotes: true) do |csv|
  csv << %w[demande_id form state errors]
  invalid_ar_with_errors.each do |ar|
    csv << ar.values
  end
end

puts csv_string
