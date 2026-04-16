class EmailPreviewRenderer
  PLACEHOLDER_MESSAGE = '{{MESSAGE_PERSONNALISE}}'.freeze

  ACTION_TO_MAILER_ACTION = {
    approval: :approve,
    refusal: :refuse,
    request_changes: :request_changes
  }.freeze

  ACTION_TO_REOPENING_MAILER_ACTION = {
    approval: :reopening_approve,
    refusal: :reopening_refuse,
    request_changes: :reopening_request_changes
  }.freeze

  def initialize(authorization_request, action:)
    @authorization_request = authorization_request
    @action = action.to_sym
  end

  def render
    mail = AuthorizationRequestMailer.with(
      authorization_request: build_preview_request
    ).send(mailer_action)

    LinkifyUrlsInterceptor.delivering_email(mail)
    Nokogiri::HTML(mail.html_part.body.decoded).at('body').inner_html
  end

  private

  attr_reader :authorization_request, :action

  def mailer_action
    if authorization_request.reopening?
      ACTION_TO_REOPENING_MAILER_ACTION.fetch(action)
    else
      ACTION_TO_MAILER_ACTION.fetch(action)
    end
  end

  def build_preview_request
    authorization_request.dup.tap do |request|
      request.id = authorization_request.id
      request.define_singleton_method(:denial) { DenialOfAuthorization.new(reason: PLACEHOLDER_MESSAGE) }
      request.define_singleton_method(:modification_request) { InstructorModificationRequest.new(reason: PLACEHOLDER_MESSAGE) }

      authorization = Authorization.new(message: PLACEHOLDER_MESSAGE)
      request.define_singleton_method(:latest_authorization) { authorization }
    end
  end
end
