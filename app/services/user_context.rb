class UserContext
  attr_reader :user, :host, :authentication_session

  def initialize(user, host = nil, authentication_session: nil)
    @user = user
    @host = host
    @authentication_session = authentication_session
  end
end
