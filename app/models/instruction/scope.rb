class Instruction::Scope
  def initialize(string)
    @string = string.to_s
    @provider_slug, @definition_id = @string.split(':', 2)
  end

  attr_reader :provider_slug, :definition_id

  def label
    return @string if blank?
    return I18n.t('instruction.user_rights.scope.fd_wildcard', provider: provider_name) if fd_wildcard?

    AuthorizationDefinition.find(@definition_id).name
  end

  def provider_name
    DataProvider.friendly.find(@provider_slug).name
  rescue ActiveRecord::RecordNotFound
    @provider_slug.upcase
  end

  def fd_wildcard?
    @definition_id == '*'
  end

  private

  def blank?
    @provider_slug.blank? || @definition_id.blank?
  end
end
