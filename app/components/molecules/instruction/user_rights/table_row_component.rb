class Molecules::Instruction::UserRights::TableRowComponent < ApplicationComponent
  ROLE_ORDER = %w[admin manager instructor developer reporter].freeze
  AGGREGATE_THRESHOLD = 2

  def initialize(user:, authority:, current_user:)
    @user = user
    @authority = authority
    @current_user = current_user
  end

  private

  attr_reader :user, :authority, :current_user

  def organization_title(organization)
    t('instruction.user_rights.index.table.organisation_title', name: organization.name, siret: organization.siret)
  end

  def role_types
    visible_role_types.sort_by { |role_type| ROLE_ORDER.index(role_type) || ROLE_ORDER.size }
  end

  def visible_role_types
    types = user.distinct_role_types
    return types if authority.covers_role?('admin')

    types - ['admin']
  end

  def droits
    @droits ||= user.specific_authorization_definitions.sort_by(&:name_with_stage)
  end

  def aggregate_droits?
    droits.size > AGGREGATE_THRESHOLD
  end

  def fd_wildcard_provider_labels
    @fd_wildcard_provider_labels ||= fd_wildcard_provider_slugs
      .map { |slug| t('instruction.user_rights.index.table.all_services', provider: provider_label(slug)) }
      .sort
  end

  def all_access?
    user.roles.include?('admin') && authority.covers_role?('admin')
  end

  def fd_wildcard_provider_slugs
    slugs = user.roles.filter_map do |role_string|
      parsed = ParsedRole.parse(role_string)
      parsed.provider_slug if parsed.fd_level?
    end
    slugs.uniq
  end

  def provider_label(slug)
    DataProvider.friendly.find(slug).name
  rescue ActiveRecord::RecordNotFound
    slug.to_s.upcase
  end

  def no_rights?
    user.roles.empty?
  end

  def own_row?
    user.id == current_user.id
  end

  def editable?
    !own_row? || authority.can_self_edit?
  end
end
