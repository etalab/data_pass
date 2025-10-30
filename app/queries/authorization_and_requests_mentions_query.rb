class AuthorizationAndRequestsMentionsQuery
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def perform(relation)
    mentions_items = mentions_relation(relation)

    if relation.model == AuthorizationRequest
      mentions_items.where.not(applicant: user)
    else
      mentions_items.where.not(request_id: excluded_request_ids_for_user)
    end
  end

  private

  def mentions_relation(relation)
    table_name = relation.model.table_name
    relation.where("EXISTS (
      select 1
      from each(#{table_name}.data) as kv
      where kv.key like '%_email' and lower(kv.value) = ?
    )", user.email)
  end

  def excluded_request_ids_for_user
    @excluded_request_ids_for_user ||= AuthorizationRequest.where(applicant: user).pluck(:id)
  end
end
