class DemandesHabilitationsViewableByUser
  attr_reader :user, :scoped_relation, :model_class

  def initialize(user, scoped_relation, model_class)
    @user = user
    @scoped_relation = scoped_relation
    @model_class = model_class
  end

  delegate :count, to: :relation

  def count_by_states(states)
    relation.where(state: states).count
  end

  private

  def relation
    scoped_items = scoped_relation.includes(includes_for_model)

    scoped_items = scoped_items.not_archived if model_class.name == 'AuthorizationRequest'

    mentions_items = AuthorizationAndRequestsMentionsQuery
      .new(user)
      .perform(model_class.all)

    scoped_items.or(mentions_items)
  end

  def includes_for_model
    case model_class.name
    when 'Authorization'
      %i[request applicant]
    when 'AuthorizationRequest'
      %i[applicant authorizations]
    else
      []
    end
  end
end
