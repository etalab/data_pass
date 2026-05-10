class Instruction::UserRightForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  attr_reader :rights

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }, if: :email_required?
  validate :rights_are_valid

  def self.for_edit(manager:, user:)
    rights = Instruction::UserRightsView.new(manager: manager, user: user).modifiable
    new(manager: manager, user: user, email: user.email, rights: rights)
  end

  def initialize(manager:, user: nil, **attrs)
    @manager = manager
    @user = user
    super(**attrs.except(:rights))
    self.rights = attrs[:rights]
  end

  def readonly_rights
    @readonly_rights ||= user ? Instruction::UserRightsView.new(manager: manager, user: user).readonly : []
  end

  def rights=(raw)
    list = case raw
           when Hash, ActionController::Parameters then raw.values
           else Array(raw)
           end
    @rights = list.map { |entry| normalize_right(entry) }.uniq
  end

  def to_roles
    rights.map { |r| "#{r[:scope]}:#{r[:role_type]}" }
  end

  def save_for(target, actor:)
    return false unless valid?

    @organizer_result = Instruction::UpdateUserRights.call(manager: actor, user: target, new_roles: to_roles)
    @organizer_result.success?
  end

  def organizer_failed?
    @organizer_result && !@organizer_result.success?
  end

  private

  attr_reader :manager, :user

  def permissions
    @permissions ||= Instruction::ManagerScopeOptions.new(manager)
  end

  def email_required?
    user.nil?
  end

  def normalize_right(entry)
    hash = entry.respond_to?(:to_unsafe_h) ? entry.to_unsafe_h : entry.to_h
    {
      scope: hash['scope'] || hash[:scope],
      role_type: hash['role_type'] || hash[:role_type]
    }
  end

  def rights_are_valid
    Instruction::RightValidator
      .new(rights, permissions)
      .errors
      .each { |attr, code| errors.add(attr, code) }
  end
end
