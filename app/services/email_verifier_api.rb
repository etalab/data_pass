class EmailVerifierAPI
  attr_reader :email

  class TimeoutError < StandardError; end

  def initialize(email)
    @email = email
  end

  def status
    return ok_status unless enable_email_verification?

    Emailable.verify(email).state
  rescue Emailable::TimeoutError
    raise TimeoutError
  end

  private

  def enable_email_verification?
    Emailable.api_key.present?
  end

  def ok_status
    'deliverable'
  end
end
