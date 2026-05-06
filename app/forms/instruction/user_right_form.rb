class Instruction::UserRightForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  attr_reader :rights, :authority

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }, if: :email_required?
  validate :rights_are_valid

  delegate :authorized_scopes, :managed_definitions, to: :authority

  def self.for_edit(authority:, user:)
    rights = Instruction::UserRightsView.new(authority: authority, user: user).modifiable
    new(authority: authority, user: user, email: user.email, rights: rights)
  end

  def initialize(authority:, user: nil, **attrs)
    @authority = authority
    @user = user
    super(**attrs.except(:rights))
    self.rights = attrs[:rights]
  end

  def readonly_rights
    @readonly_rights ||= user ? Instruction::UserRightsView.new(authority: authority, user: user).readonly : []
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

    @organizer_result = Instruction::UpdateUserRights.call(authority: authority, actor: actor, user: target, new_roles: to_roles)
    @organizer_result.success?
  end

  def organizer_failed?
    @organizer_result && !@organizer_result.success?
  end

  private

  attr_reader :user

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
      .new(rights, authority)
      .errors
      .each { |attr, code| errors.add(attr, code) }
  end
end
