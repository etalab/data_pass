class Instruction::NotificationRecipients
  def self.submit(authorization_request)
    new(
      authorization_request,
      :submit_notifications,
      authorization_request.definition.instructors_or_reporters,
    ).to_notify
  end

  def self.messages(authorization_request)
    new(
      authorization_request,
      :messages_notifications,
      authorization_request.definition.instructors_and_managers,
    ).to_notify
  end

  def initialize(authorization_request, toggle, candidates)
    @authorization_request = authorization_request
    @toggle = toggle
    @candidates = candidates
  end

  def to_notify
    @candidates.reject do |user|
      !user.public_send(setting_key) && user != @authorization_request.applicant
    end
  end

  private

  def setting_key
    "instruction_#{@toggle}_for_#{@authorization_request.definition.id.underscore}"
  end
end
