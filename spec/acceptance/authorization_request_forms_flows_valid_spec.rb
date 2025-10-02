RSpec.describe 'Authorization requests forms validations', type: :acceptance do
  let(:applicant) { create(:user) }

  it 'ensures all authorization request forms are valid with the step mecanism' do # rubocop:disable RSpec/NoExpectationExample
    AuthorizationDefinition.all.each do |definition|
      next if excluded_definition?(definition)

      definition.public_available_forms.each do |request_form|
        next unless request_form.multiple_steps?

        validate_request_form_steps(request_form, definition)
      end
    end
  end

  private

  def excluded_definition?(definition)
    %w[api-mobilic].include?(definition.id)
  end

  def validate_request_form_steps(request_form, definition)
    request_form = AuthorizationRequestForm.find(request_form.id)
    authorization_request = build_authorization_request_for_form(request_form)
    full_request = build_full_request_for_form(request_form)

    authorization_request.form.steps.each do |step|
      fill_step_attributes(authorization_request, full_request, step, definition.id)
      authorization_request.current_build_step = step[:name]
      assert_step_validity(authorization_request, step)
    end

    print_request_info(request_form) if ENV['DEBUG']
  end

  def build_authorization_request_for_form(authorization_request_form)
    BuildAuthorizationRequest.call(
      authorization_request_form:,
      applicant:,
    ).authorization_request
  end

  def build_full_request_for_form(request_form)
    build(:authorization_request, request_form.id.underscore, fill_all_attributes: true, applicant:)
  end

  def fill_step_attributes(authorization_request, full_request, step, definition_id)
    handle_special_steps(authorization_request, full_request, step[:name])

    attributes = attributes_for_step(step[:name], authorization_request)
    custom_attributes = custom_attributes_for_step(definition_id, step[:name])

    (attributes + custom_attributes).flatten.each do |key|
      assign_attribute_to_request(authorization_request, full_request, key)
    end
  end

  def handle_special_steps(authorization_request, full_request, step_name)
    case step_name
    when 'modalities'
      authorization_request.modalities = full_request.modalities if authorization_request.respond_to?(:modalities)
    when 'france_connect'
      authorization_request.france_connect_authorization_id = full_request.france_connect_authorization_id if authorization_request.respond_to?(:france_connect_authorization_id)
    end
  end

  def attributes_for_step(step_name, authorization_request)
    return contact_attributes(authorization_request) if step_name == 'contacts'

    step_attributes_mapping.fetch(step_name, [])
  end

  def step_attributes_mapping
    {
      'basic_infos' => %w[
        intitule
        description
        date_prevue_mise_en_production
        volumetrie_approximative
      ],
      'personal_data' => %w[
        destinataire_donnees_caractere_personnel
        duree_conservation_donnees_caractere_personnel
      ],
      'legal' => %w[
        cadre_juridique_url
        cadre_juridique_nature
      ],
      'scopes' => %w[scopes],
      'france_connect_eidas' => %w[france_connect_eidas],
      'technical_team' => %w[
        technical_team_type
        technical_team_value
      ],
      'safety_certification' => %w[
        safety_certification_document
        safety_certification_authority_name
        safety_certification_authority_function
        safety_certification_begin_date
        safety_certification_end_date
      ],
      'volumetrie' => %w[
        volumetrie_appels_par_minute
        volumetrie_justification
      ],
    }
  end

  def contact_attributes(authorization_request)
    authorization_request.class.contacts.flat_map do |contact|
      %W[
        #{contact.type}_family_name
        #{contact.type}_given_name
        #{contact.type}_email
        #{contact.type}_phone_number
        #{contact.type}_job_title
      ]
    end
  end

  def custom_attributes_for_step(definition_id, step_name)
    mapping = {
      'api_declaration_cesu' => {
        'supporting_documents' => 'attestation_fiscale',
      },
      'api_declaration_auto_entrepreneur' => {
        'supporting_documents' => 'attestation_fiscale',
      }
    }

    return [] unless mapping[definition_id] && mapping[definition_id][step_name]

    [mapping[definition_id][step_name]]
  end

  def assign_attribute_to_request(authorization_request, full_request, key)
    return unless full_request.respond_to?(key)

    if document_attribute?(authorization_request, key)
      authorization_request.public_send("#{key}=", full_request.send(key).blobs)
    else
      authorization_request.public_send("#{key}=", full_request.send(key))
    end
  end

  def document_attribute?(authorization_request, key)
    authorization_request.class.documents.map(&:name).include?(key.to_sym)
  end

  def assert_step_validity(authorization_request, step)
    return if authorization_request.valid?

    print_validation_errors(authorization_request, step) if ENV['DEBUG']

    expect(authorization_request).to be_valid,
      "'#{authorization_request.form_uid}' is not valid after filling step #{step[:name]}: #{authorization_request.errors.full_messages.join(', ')}"
  end

  def print_validation_errors(authorization_request, step)
    print_debug "'#{authorization_request.form_uid}' is not valid after filling step #{step[:name]}"
    print_debug "\nerrors:\n#{authorization_request.errors.full_messages.join("\n")}"
    print_debug "\n"
  end

  def print_request_info(request_form)
    print_debug "\n'#{request_form.name_with_definition}' (#{request_form.id})"
  end

  # rubocop:disable Rails/Output
  def print_debug(message)
    print "\n#{message}\n"
  end
  # rubocop:enable Rails/Output
end
