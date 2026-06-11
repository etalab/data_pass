class AutomaticEmailsCatalog
  EVENTS = %w[submit approve refuse request_changes revoke].freeze

  SUBJECT_DUMMY_VALUES = {
    authorization_request_id: 'N°0001',
    authorization_request_name: 'Ma demande d\'habilitation',
    api_name: 'API',
    organization_name: 'Mon organisation',
  }.freeze

  AutomaticEmailEntry = Struct.new(:event_name, :recipient_type, :subject, :body_text, keyword_init: true)

  def initialize(definition, preview_ar: nil)
    @definition = definition
    @preview_ar = preview_ar
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
    AutomaticEmailEntry.new(
      event_name:,
      recipient_type: capture[:recipient_type],
      subject: render_subject(capture[:mailer_class], capture[:mailer_action]),
      body_text: render_body(capture[:mailer_class], capture[:mailer_action]),
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

  def render_body(mailer_class, mailer_action)
    template = resolve_template_path(mailer_class, mailer_action)
    return nil unless template

    ar = @preview_ar || PreviewAuthorizationRequest.new(@definition)

    ApplicationController.render(
      template:,
      assigns: { authorization_request: ar },
      formats: [:text],
    )
  rescue StandardError
    nil
  end

  def resolve_template_path(mailer_class, mailer_action)
    if mailer_class == Instruction::AuthorizationRequestMailer
      path = "instruction/authorization_request_mailer/#{mailer_action}"
      template_exists?(path) ? path : nil
    else
      kind_specific = "authorization_request_mailer/#{@definition.id}/#{mailer_action}"
      generic = "authorization_request_mailer/#{mailer_action}"

      if template_exists?(kind_specific)
        kind_specific
      elsif template_exists?(generic)
        generic
      end
    end
  end

  def template_exists?(path)
    ApplicationController.new.lookup_context.exists?(path, [], false)
  end

  def build_spy_notifier
    notifier_class = resolve_notifier_class
    ar_stub = @definition.authorization_request_class.new
    spy_class = build_spy_class(notifier_class)
    spy_class.new(ar_stub)
  end

  def build_spy_class(notifier_class) # rubocop:disable Metrics/MethodLength
    Class.new(notifier_class) do
      attr_reader :captures

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

      def deliver_gdpr_emails; end

      def notify_france_connect; end

      def notify_dgfip_apim(_params); end
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
  end
end
