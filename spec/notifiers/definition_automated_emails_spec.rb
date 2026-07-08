RSpec.describe 'Automated emails wiring per definition', type: :notifier do
  include ActiveJob::TestHelper

  # Needed so DGFiP-provider definitions resolve their provider and enqueue DGFIP::APIMMailer#approve
  before { create(:data_provider, :dgfip) }

  STARTING_STATE_TRAIT = {
    'approve' => :submitted,
    'request_changes' => :submitted,
    'refuse' => :submitted,
    'revoke' => :validated,
  }.freeze

  def self.states_for(event_config)
    if event_config['authorization_request_states']
      event_config['authorization_request_states'].map do |state_config|
        [state_config['state'] || {}, state_config['emails'] || []]
      end
    else
      [[{}, event_config['emails'] || []]]
    end
  end

  config = YAML.load_file(Rails.root.join('spec/notifiers/definition_automated_emails.yaml'), aliases: true)
  events = config['authorization_request_events']

  config['authorization_definitions'].each do |definition_config|
    definition_id = definition_config['definition_id'] # rubocop:disable RSpec/LeakyLocalVariable

    describe "definition #{definition_id}" do
      events.each do |event_name|
        event_config = definition_config['events'].find { |event| event['event_name'] == event_name } || { 'emails' => [] }

        states_for(event_config).each do |state, expected_emails|
          context "when #{event_name} event happens with state #{state}" do
            let(:instructor) { create_instructor_for(definition_id) }
            let(:authorization_request) { build_authorization_request(definition_id, state, event_name) }

            it "triggers exactly the #{expected_emails.count} expected emails" do
              instructor
              authorization_request

              triggered = capture_enqueued_mails do
                trigger_event(authorization_request, event_name, instructor)
              end

              expect(triggered).to match_array(expected_emails)
            end
          end
        end
      end
    end
  end

  # An in-database definition (backed by an habilitation type) with only the basic_infos
  # block falls back to BaseNotifier and matches the basic wiring. Its synthetic definition
  # is not a static entry, so the full organizers cannot run against it (params extraction
  # raises EntryNotFound); the notifier is exercised directly to assert the fallback wiring.
  describe 'in-database definition backed by an habilitation type' do
    let(:habilitation_type) { create(:habilitation_type) }
    let(:authorization_request) { build_in_database_authorization_request(habilitation_type) }

    before { create_instructor_for(habilitation_type.uid) }

    events.each do |event_name|
      event_config = config['shared_event_lists']['basic'].find { |event| event['event_name'] == event_name } || { 'emails' => [] }

      states_for(event_config).each do |state, expected_emails|
        context "when #{event_name} event happens with state #{state}" do
          it "triggers exactly the #{expected_emails.count} basic emails" do
            triggered = capture_enqueued_mails do
              trigger_notifier_event(authorization_request, event_name, state)
            end

            expect(triggered).to match_array(expected_emails)
          end
        end
      end
    end
  end

  def build_authorization_request(definition_id, state, event_name)
    extra_traits = Array(state['factory_traits']).map(&:to_sym)
    extra_traits << STARTING_STATE_TRAIT[event_name] if STARTING_STATE_TRAIT[event_name]
    attributes = { fill_all_attributes: true }

    if state['with_france_connect']
      extra_traits << :with_france_connect
      attributes[:modalities] = %w[france_connect] if modalities_supported?(definition_id)
    end

    authorization_request = create_with_definition_trait(definition_id, extra_traits, attributes)
    fake_reopening(authorization_request) if state['reopening']
    authorization_request
  end

  def modalities_supported?(definition_id)
    AuthorizationDefinition.find(definition_id).authorization_request_class
      .include?(AuthorizationExtensions::Modalities)
  end

  def create_with_definition_trait(definition_id, extra_traits, attributes)
    [definition_id.to_sym, :"#{definition_id}_production"].each do |base_trait|
      return create(:authorization_request, base_trait, *extra_traits, **attributes)
    rescue KeyError
      next
    end

    raise KeyError, "no factory trait for #{definition_id}"
  end

  def build_in_database_authorization_request(habilitation_type)
    AuthorizationRequest.const_get(habilitation_type.uid.classify).new(
      organization: create(:organization),
      applicant: create(:user),
      form_uid: habilitation_type.uid
    ).tap { |authorization_request| authorization_request.save(validate: false) }
  end

  def fake_reopening(authorization_request)
    allow(authorization_request).to receive(:reopening?).and_return(true)
  end

  def create_instructor_for(definition_id)
    create(:user, :instructor, authorization_request_types: [definition_id])
  end

  def trigger_event(authorization_request, event_name, instructor)
    case event_name
    when 'submit'
      SubmitAuthorizationRequest.call(authorization_request:, user: authorization_request.applicant)
    when 'approve'
      ApproveAuthorizationRequest.call(authorization_request:, user: instructor, authorization_message: 'Demande validée')
    when 'request_changes'
      RequestChangesOnAuthorizationRequest.call(authorization_request:, user: instructor, instructor_modification_request_params: { reason: 'Merci de compléter votre demande' })
    when 'refuse'
      RefuseAuthorizationRequest.call(authorization_request:, user: instructor, denial_of_authorization_params: { reason: 'Demande non conforme' })
    when 'revoke'
      RevokeAuthorizationRequest.call(authorization_request:, user: instructor, revocation_of_authorization_params: { reason: 'Habilitation révoquée' })
    end
  end

  def trigger_notifier_event(authorization_request, event_name, state)
    notifier_class_for(authorization_request)
      .new(authorization_request)
      .public_send(event_name, within_reopening: state.fetch('reopening', false))
  end

  def notifier_class_for(authorization_request)
    "#{authorization_request.class_name.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end

  def capture_enqueued_mails
    clear_enqueued_jobs
    yield

    enqueued_jobs.filter_map do |job|
      next unless job[:job] == ActionMailer::MailDeliveryJob

      mailer, action = job[:args]
      "#{mailer}##{action}"
    end
  end
end
