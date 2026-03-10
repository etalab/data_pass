class HabilitationType < ApplicationRecord
  BLOCK_ORDER = %w[basic_infos legal personal_data scopes contacts].freeze
  VALID_RUBY_CLASSNAME = /\A[A-Z][a-zA-Z0-9]*\z/
  DEFAULT_BLOCKS = %w[basic_infos legal personal_data].freeze

  extend FriendlyId

  friendly_id :name, use: :slugged

  belongs_to :data_provider

  enum :kind, { api: 'api', service: 'service' }, validate: true

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :kind, presence: true
  validate :slug_not_taken_by_yaml
  validate :name_generates_reachable_uid
  validates :contact_types, presence: true, if: :contacts_block_selected?

  before_destroy :ensure_no_authorization_requests
  after_destroy :unregister_dynamic_class
  after_destroy :reset_static_caches
  after_save :register_dynamic_class
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

  def authorization_request_type
    "AuthorizationRequest::#{uid.classify}"
  end

  def ordered_steps
    block_names = block_name_list
    BLOCK_ORDER.select { |name| block_names.include?(name) }
  end

  def authorization_requests_count
    AuthorizationRequest.where(type: "AuthorizationRequest::#{uid.classify}").count
  end

  private

  def block_name_list
    (blocks || []).map { |b| b.is_a?(Hash) ? b['name'] || b[:name] : b }
  end

  def name_generates_reachable_uid
    return if slug.blank?

    class_name = uid.classify
    return if class_name.match?(VALID_RUBY_CLASSNAME) &&
              class_name.underscore == uid

    errors.add(:name, :unreachable_uid)
  end

  def contacts_block_selected?
    block_name_list.include?('contacts')
  end

  def slug_not_taken_by_yaml
    return if slug.blank?
    return unless AuthorizationDefinition.yaml_records.map(&:id).include?(uid)

    errors.add(:slug, :taken_by_yaml_type)
  end

  def ensure_no_authorization_requests
    return if authorization_requests_count.zero?

    errors.add(:base, :has_authorization_requests)
    throw :abort
  end

  def unregister_dynamic_class
    class_name = uid.classify
    AuthorizationRequest.send(:remove_const, class_name) if AuthorizationRequest.const_defined?(class_name, false)
  end

  def register_dynamic_class
    DynamicAuthorizationRequestRegistrar.call(self)
  end

  def reset_static_caches
    AuthorizationDefinition.reset!
    AuthorizationRequestForm.reset!
  end
end
