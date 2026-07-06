RSpec.describe 'Automated emails declarations', type: :notifier do
  let!(:dgfip_data_provider) { create(:data_provider, :dgfip) }

  before do
    allow(Instruction::NotificationRecipients).to receive(:submit).and_return([instance_double(User)])
    allow(RegisterOrganizationWithContactsOnCRMJob).to receive(:perform_later)
  end

  it 'declares on each definition exactly the emails triggered by its notifier' do
    AuthorizationDefinition.yaml_records.each do |definition|
      triggered_ids = triggered_automated_email_ids(definition)

      expect(triggered_ids).to match_array(definition.automated_email_ids),
        "#{definition.id}: declares #{definition.automated_email_ids.sort} but notifier triggers #{triggered_ids.sort}"
    end
  end

  EVENTS = %w[submit approve refuse request_changes revoke].freeze

  MAILER_CAPTURES_TO_IDS = {
    'AuthorizationRequestMailer' => ->(action, _args) { "#{action}_to_applicant" },
    'Instruction::AuthorizationRequestMailer' => ->(_action, _args) { 'submit_to_instructors' },
    'GDPRContactMailer' => ->(action, _args) { "approve_to_#{action}" },
    'FranceConnectMailer' => ->(_action, _args) { 'approve_to_france_connect' },
    'DGFIP::APIMMailer' => ->(_action, _args) { 'approve_to_dgfip_apim' },
    'HubEEMailer' => ->(_action, args) { "approve_to_hubee_administrateur_metier_#{args.first}" },
  }.freeze

  class MailerSpy
    attr_reader :mailer_class, :captures

    def initialize(mailer_class, captures)
      @mailer_class = mailer_class
      @captures = captures
    end

    def method_missing(action, *args)
      captures << [mailer_class, action, args]
      NullDelivery.new
    end

    def respond_to_missing?(_method_name, _include_private = false)
      true
    end

    class NullDelivery
      def deliver_later(...) = nil
      def deliver_now(...) = nil
    end
  end

  def triggered_automated_email_ids(definition)
    captures = []
    spy_on_mailers(captures)
    notifier = notifier_for(definition)

    EVENTS.each { |event| notifier.public_send(event, {}) }

    captures.map { |mailer_class, action, args|
      MAILER_CAPTURES_TO_IDS.fetch(mailer_class.to_s).call(action, args)
    }.uniq
  end

  def spy_on_mailers(captures)
    MAILER_CAPTURES_TO_IDS.each_key do |mailer_class_name|
      mailer_class = mailer_class_name.constantize

      allow(mailer_class).to receive(:with).and_return(MailerSpy.new(mailer_class, captures))
    end
  end

  def notifier_for(definition)
    notifier_class_for(definition).new(sample_authorization_request(definition))
  end

  def notifier_class_for(definition)
    "#{definition.authorization_request_class.to_s.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end

  def sample_authorization_request(definition)
    authorization_request = definition.authorization_request_class.new
    assign_contact_emails(authorization_request)

    allow(authorization_request).to receive_messages(
      applicant: instance_double(User, email: 'demandeur@example.org'),
      with_france_connect?: can_use_france_connect?(definition.authorization_request_class),
    )

    authorization_request
  end

  def assign_contact_emails(authorization_request)
    %w[responsable_traitement_email delegue_protection_donnees_email administrateur_metier_email].each do |attribute|
      writer = :"#{attribute}="

      authorization_request.public_send(writer, "#{attribute}@example.org") if authorization_request.respond_to?(writer)
    end
  end

  def can_use_france_connect?(authorization_request_class)
    authorization_request_class.instance_method(:with_france_connect?).owner != AuthorizationRequest
  end
end
