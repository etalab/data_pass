class Instruction::AuthorizationRequestMailer < AbstractInstructionMailer
  attr_reader :authorization_request

  def submit
    @authorization_request = params[:authorization_request]

    return if instructors_or_reporters_to_notify.empty?

    mail(
      to: instructors_or_reporters_to_notify.pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end

  def reopening_submit
    @authorization_request = params[:authorization_request]

    return if instructors_or_reporters_to_notify.empty?

    mail(
      to: instructors_or_reporters_to_notify.pluck(:email),
      subject: t(
        '.subject',
      )
    )
  end
end
