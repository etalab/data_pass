class APIUserContext < UserContext
  attr_reader :oauth_application

  def initialize(user, host = nil, oauth_application:)
    super(user, host)
    @oauth_application = oauth_application
  end
end
