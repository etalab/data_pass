class Molecules::Instruction::UserRights::RightFieldComponent < ApplicationComponent
  FORM_NAME = 'instruction_user_right_form'.freeze

  def initialize(index:, scope:, role_type:, permissions:)
    @index = index
    @scope = scope
    @role_type = role_type
    @permissions = permissions
  end

  private

  attr_reader :index, :scope, :role_type, :permissions

  def legend_label
    if index == 'NEW'
      t('instruction.user_rights.new.right_legend_new')
    else
      t('instruction.user_rights.new.right_legend', position: index.to_i + 1)
    end
  end

  def name_for(attr)
    "#{FORM_NAME}[rights][][#{attr}]"
  end

  def id_for(attr)
    "#{FORM_NAME}_rights_#{index}_#{attr}"
  end

  def grouped_scope_pairs
    permissions.managed_definitions
      .group_by(&:provider_slug)
      .sort_by { |slug, _| provider_name(slug) }
      .map { |slug, definitions| [provider_name(slug), scope_pairs_for(slug, definitions)] }
  end

  def scope_pairs_for(slug, definitions)
    pairs = []
    pairs << [t('instruction.user_rights.new.scope_fd_option', provider: provider_name(slug)), "#{slug}:*"] if permissions.fd_manager_for?(slug)
    definitions.sort_by(&:name).each { |ad| pairs << [ad.name, "#{slug}:#{ad.id}"] }
    pairs
  end

  def role_pairs
    permissions.allowed_role_types.map { |role_type| [t("instruction.user_rights.roles.#{role_type}"), role_type] }
  end

  def provider_name(slug)
    @provider_names ||= {}
    @provider_names[slug] ||= DataProvider.friendly.find(slug).name
  rescue ActiveRecord::RecordNotFound
    @provider_names[slug] = slug.upcase
  end
end
