class EmailVerifierAPI
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def status
    'deliverable'
  end
end
