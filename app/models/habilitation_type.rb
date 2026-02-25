class HabilitationType < ApplicationRecord
  BLOCK_ORDER = %w[basic_infos legal personal_data scopes contacts].freeze

  extend FriendlyId

  friendly_id :name, use: :slugged

  belongs_to :data_provider

  enum :kind, { api: 'api', service: 'service' }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :kind, presence: true, inclusion: { in: kinds.keys }
  validate :slug_not_taken_by_yaml

  after_create :register_dynamic_class
  after_destroy :reset_static_caches
  after_save :reset_static_caches

  def public
    true
  end

  def unique
    false
  end

  def startable_by_applicant
    true
  end

  def uid
    slug.underscore
  end

  def ordered_steps
    block_names = block_name_list
    BLOCK_ORDER.select { |name| block_names.include?(name) }
  end

  private

  def block_name_list
    (blocks || []).map { |b| b.is_a?(Hash) ? b['name'] || b[:name] : b }
  end

  def slug_not_taken_by_yaml
    return if slug.blank?
    return unless AuthorizationDefinition.yaml_records.map(&:id).include?(uid)

    errors.add(:slug, 'correspond à un type YAML existant')
  end

  def register_dynamic_class
    DynamicAuthorizationRequestRegistrar.call(self)
  end

  def reset_static_caches
    AuthorizationDefinition.reset!
    AuthorizationRequestForm.reset!
  end
end
