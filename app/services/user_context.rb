class UserContext
  attr_reader :user, :host

  def initialize(user, host = nil)
    @user = user
    @host = host
  end
end
