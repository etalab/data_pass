class UserContext
  attr_reader :user, :host, :authentication_session, :dirigeant_verification

  def initialize(user, host = nil, authentication_session: nil, dirigeant_verification: nil)
    @user = user
    @host = host
    @authentication_session = authentication_session
    @dirigeant_verification = dirigeant_verification
  end
end
