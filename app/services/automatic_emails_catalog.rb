class AutomaticEmailsCatalog
  EVENTS = %w[submit approve refuse request_changes revoke].freeze

  SUBJECT_DUMMY_VALUES = {
    authorization_request_id: 'N°0001',
    authorization_request_name: 'Ma demande d\'habilitation',
    api_name: 'API',
    organization_name: 'Mon organisation',
  }.freeze

  GDPR_CONTACTS = %i[responsable_traitement delegue_protection_donnees].freeze

  AutomaticEmailEntry = Struct.new(:event_name, :recipient_type, :subject, :body_text, :recipient_emails, keyword_init: true)
  PreviewAuthorization = Struct.new(:formatted_id)

  def initialize(definition)
    @definition = definition
  end

  def build
    spy = build_spy_notifier

    EVENTS.flat_map do |event|
      spy.clear_captures
      spy.public_send(event, {})
      spy.captures.map { |capture| build_entry(event, capture) }
    rescue StandardError
      []
    end
  end

  private

  def build_entry(event_name, capture)
    template = capture[:template_path] || resolve_template_path(capture[:mailer_class], capture[:mailer_action])
    subject = capture[:subject] || render_subject(capture[:mailer_class], capture[:mailer_action])

    AutomaticEmailEntry.new(
      event_name:,
      recipient_type: capture[:recipient_type],
      recipient_emails: capture[:recipient_emails],
      subject:,
      body_text: render_body(template, extra_assigns: capture.fetch(:extra_assigns, {})),
    )
  end

  def render_subject(mailer_class, mailer_action)
    key = subject_locale_key(mailer_class, mailer_action)
    I18n.t(key, **SUBJECT_DUMMY_VALUES)
  rescue I18n::MissingInterpolationArgument
    I18n.t(key)
  end

  def subject_locale_key(mailer_class, mailer_action)
    if mailer_class == Instruction::AuthorizationRequestMailer
      "instruction.authorization_request_mailer.#{mailer_action}.subject"
    else
      "authorization_request_mailer.#{mailer_action}.subject"
    end
  end

  def render_body(template, extra_assigns: {})
    return nil unless template

    ar = PreviewAuthorizationRequest.new(@definition)

    ApplicationController.render(
      template:,
      assigns: { authorization_request: ar }.merge(extra_assigns),
      formats: [:text],
    )
  rescue StandardError
    nil
  end

  def resolve_template_path(mailer_class, mailer_action)
    return nil unless mailer_class && mailer_action
    return instruction_template_path(mailer_action) if mailer_class == Instruction::AuthorizationRequestMailer

    standard_template_path(mailer_action)
  end

  def instruction_template_path(mailer_action)
    path = "instruction/authorization_request_mailer/#{mailer_action}"
    template_exists?(path) ? path : nil
  end

  def standard_template_path(mailer_action)
    kind_specific = "authorization_request_mailer/#{@definition.id}/#{mailer_action}"
    generic = "authorization_request_mailer/#{mailer_action}"

    if template_exists?(kind_specific) then kind_specific
    elsif template_exists?(generic) then generic
    end
  end

  def template_exists?(path)
    ApplicationController.new.lookup_context.exists?(path, [], false)
  end

  def build_spy_notifier
    notifier_class = resolve_notifier_class
    ar_stub = @definition.authorization_request_class.new
    spy_class = build_spy_class(notifier_class)
    spy = spy_class.new(ar_stub)
    spy.definition = @definition
    spy
  end

  def build_spy_class(notifier_class)
    spy = build_base_spy_class(notifier_class)
    add_hubee_spy_overrides(spy) if notifier_class <= HubEENotifier
    spy
  end

  def build_base_spy_class(notifier_class) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    Class.new(notifier_class) do
      attr_reader :captures
      attr_accessor :definition

      def initialize(authorization_request)
        super
        @captures = []
      end

      def clear_captures
        @captures = []
      end

      protected

      def email_notification(event_name, _params)
        @captures << { recipient_type: :applicant, mailer_class: AuthorizationRequestMailer, mailer_action: event_name.to_s }
      end

      def email_notification_with_reopening(base_event, _params, mailer: AuthorizationRequestMailer)
        recipient_type = mailer == Instruction::AuthorizationRequestMailer ? :instructors : :applicant
        @captures << { recipient_type:, mailer_class: mailer, mailer_action: base_event.to_s }
      end

      def deliver_gdpr_emails
        AutomaticEmailsCatalog::GDPR_CONTACTS.each do |contact|
          @captures << {
            recipient_type: contact,
            subject: I18n.t(
              "gdpr_contact_mailer.#{contact}.subject",
              authorization_request_contact_kind: I18n.t("authorization_request.contacts.#{contact}"),
              authorization_request_name: AutomaticEmailsCatalog::SUBJECT_DUMMY_VALUES[:authorization_request_name],
            ),
            template_path: "gdpr_contact_mailer/#{contact}",
          }
        end
      end

      def notify_france_connect
        @captures << {
          recipient_type: :france_connect,
          recipient_emails: ['support.partenaires@franceconnect.gouv.fr'],
          subject: "[DataPass] nouveaux scopes pour « #{AutomaticEmailsCatalog::SUBJECT_DUMMY_VALUES[:organization_name]} - #{AutomaticEmailsCatalog::SUBJECT_DUMMY_VALUES[:authorization_request_id]} »",
          template_path: 'france_connect_mailer/new_scopes',
          extra_assigns: { france_connect_authorization_request: AutomaticEmailsCatalog::PreviewAuthorizationRequest.new(definition) },
        }
      end

      def notify_dgfip_apim(_params)
        apim_emails = Rails.application.credentials.dgfip_apim_emails || []
        api_emails = (Rails.application.credentials.dgfip_api_specific_emails || {})[definition.id.to_sym] || []

        @captures << {
          recipient_type: :dgfip_apim,
          recipient_emails: apim_emails + api_emails,
          subject: I18n.t('dgfip_apim_mailer.approve.subject', authorization_request_id: AutomaticEmailsCatalog::SUBJECT_DUMMY_VALUES[:authorization_request_id]),
          template_path: 'dgfip/apim_mailer/approve',
          extra_assigns: {
            authorization: AutomaticEmailsCatalog::PreviewAuthorization.new('H-0001'),
            reopening: false,
            stage_label: '[BAS ou PROD]',
          },
        }
      end
    end
  end

  def add_hubee_spy_overrides(spy)
    spy.class_eval do
      private

      def applicant_and_administrateur_metier_are_different?
        true
      end

      def notify_administrateur_metier
        @captures << {
          recipient_type: :hubee_administrateur_metier,
          subject: HubEEMailer.new.subject_for(kind),
          template_path: "hubee_mailer/administrateur_metier_#{kind}",
        }
      end
    end
  end

  def resolve_notifier_class
    "#{@definition.authorization_request_class.to_s.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end

  class PreviewAuthorizationRequest
    Applicant = Struct.new(:full_name, :email)
    Organization = Struct.new(:name)
    Reason = Struct.new(:reason, :present?)

    def initialize(definition)
      @definition = definition
    end

    attr_reader :definition

    delegate :name, to: :definition

    def id = 0
    def to_param = '0'
    def model_name = ActiveModel::Name.new(AuthorizationRequest)
    def formatted_id = 'N°0001'
    def reopening? = false
    def latest_authorization = nil
    def last_submitted_at = Time.current
    def applicant = Applicant.new('[Nom du demandeur]', 'demandeur@example.org')
    def organization = Organization.new('[Organisation]')
    def denial = Reason.new('[Motif de refus]')
    def revocation = Reason.new('[Motif de révocation]')
    def modification_request = Reason.new('[Demande de modification]', false)
    def authorization_request_revocation_reason = '[Motif de révocation]'
    def with_france_connect? = false
    def responsable_traitement_given_name = '[Prénom Resp. Traitement]'
    def delegue_protection_donnees_given_name = '[Prénom DPD]'
    def administrateur_metier_given_name = '[Prénom Admin]'
    def administrateur_metier_family_name = '[Nom Admin]'
    def administrateur_metier_email = '[Email Admin]'
    def scopes = []
  end
end
