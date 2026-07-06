RSpec.describe 'Automated emails declarations', type: :notifier do
  include ActiveJob::TestHelper

  let!(:dgfip_data_provider) { create(:data_provider, :dgfip) }
  let(:instructor) { create(:user) }

  before do
    allow(Instruction::NotificationRecipients).to receive(:submit).and_return([instructor])
  end

  it 'declares on each definition exactly the emails enqueued by its notifier' do
    AuthorizationDefinition.yaml_records.each do |definition|
      enqueued_ids = enqueued_automated_email_ids(definition)

      expect(enqueued_ids).to match_array(definition.automated_email_ids),
        "#{definition.id}: declares #{definition.automated_email_ids.sort} but notifier enqueues #{enqueued_ids.sort}"
    end
  end

  EVENTS = %w[submit approve refuse request_changes revoke].freeze

  def enqueued_automated_email_ids(definition)
    authorization_request = sample_authorization_request(definition)
    notifier = notifier_for(definition, authorization_request)

    EVENTS.flat_map { |event|
      new_mail_jobs { notifier.public_send(event, {}) }.map { |job| automated_email_id_for(job) }
    }.uniq
  end

  def new_mail_jobs
    already_enqueued = enqueued_jobs.size
    yield

    enqueued_jobs[already_enqueued..].select { |job| job['job_class'] == 'ActionMailer::MailDeliveryJob' }
  end

  def automated_email_id_for(job)
    mailer, action, _delivery_method, options = job['arguments']

    case mailer
    when 'AuthorizationRequestMailer' then "#{action}_to_applicant"
    when 'Instruction::AuthorizationRequestMailer' then 'submit_to_instructors'
    when 'GDPRContactMailer' then "approve_to_#{action}"
    when 'FranceConnectMailer' then 'approve_to_france_connect'
    when 'DGFIP::APIMMailer' then 'approve_to_dgfip_apim'
    when 'HubEEMailer' then "approve_to_hubee_administrateur_metier_#{hubee_kind_from(options)}"
    else
      raise "Unknown mailer #{mailer}##{action}"
    end
  end

  def hubee_kind_from(options)
    options['args'].first['value']
  end

  def notifier_for(definition, authorization_request)
    notifier_class_for(definition).new(authorization_request)
  end

  def notifier_class_for(definition)
    "#{definition.authorization_request_class.to_s.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end

  def sample_authorization_request(definition)
    authorization_request = build(
      :authorization_request,
      type: definition.authorization_request_class_as_string,
      form_uid: definition.default_form.id,
    )
    assign_contact_emails(authorization_request)
    authorization_request.save!(validate: false)

    allow(authorization_request).to receive(:with_france_connect?)
      .and_return(can_use_france_connect?(definition.authorization_request_class))

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
