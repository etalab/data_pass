class AuthorizationRequestsMentionsQuery
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def perform(relation = AuthorizationRequest.all)
    relation.where("EXISTS (
      select 1
      from each(authorization_requests.data) as kv
      where kv.key like '%_email' and kv.value = ?
    )", user.email)
  end
end
