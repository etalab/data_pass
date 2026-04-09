class HabilitationType < ApplicationRecord
  BLOCK_ORDER = %w[basic_infos legal personal_data scopes contacts].freeze
  VALID_RUBY_CLASSNAME = /\A[A-Z][a-zA-Z0-9]*\z/
  DEFAULT_BLOCKS = %w[basic_infos legal personal_data].freeze
  EDITORIAL_PARAMS = %i[name description form_introduction link cgu_link access_link support_email].freeze
  EDITORIAL_SCOPE_PARAMS = %w[name group].freeze

  extend FriendlyId

  has_paper_trail

  friendly_id :name, use: :slugged

  belongs_to :data_provider

  enum :kind, { api: 'api', service: 'service' }, validate: true

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :kind, presence: true
  validate :slug_not_taken_by_yaml
  validate :name_generates_reachable_uid
  validates :contact_types, presence: true, if: :contacts_block_selected?
  validates :scopes, presence: true, if: :scopes_block_selected?
  validate :validate_each_scope, if: :scopes_block_selected?

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

  def normalize_friendly_id(input)
    "#{input.to_s.parameterize}-dyn"
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def authorization_request_type
    "AuthorizationRequest::#{uid.classify}"
  end

  def ordered_steps
    block_names = block_name_list
    BLOCK_ORDER.select { |name| block_names.include?(name) }
  end

  def self.preload_requests_counts!(habilitation_types)
    types = habilitation_types.map(&:authorization_request_type)
    counts = AuthorizationRequest.where(type: types).group(:type).count

    habilitation_types.each do |ht|
      ht.authorization_requests_count = counts[ht.authorization_request_type] || 0
    end
  end

  attr_writer :authorization_requests_count

  def authorization_requests_count
    @authorization_requests_count ||= AuthorizationRequest.where(type: authorization_request_type).count
  end

  private

  def block_name_list
    (blocks || []).map { |b| b.is_a?(Hash) ? b['name'] || b[:name] : b }
  end

  def classify_stable?(candidate)
    candidate_uid = candidate.underscore
    class_name = candidate_uid.classify
    class_name.match?(VALID_RUBY_CLASSNAME) && class_name.underscore == candidate_uid
  end

  def name_generates_reachable_uid
    return if slug.blank?

    errors.add(:name, :unreachable_uid) unless classify_stable?(slug)
  end

  def contacts_block_selected?
    block_name_list.include?('contacts')
  end

  def validate_each_scope
    (scopes || []).each_with_index do |scope, index|
      scope_name = scope['name']
      scope_value = scope['value']
      errors.add(:scopes, :scope_name_blank, index: index) if scope_name.blank?
      errors.add(:scopes, :scope_value_blank, index: index) if scope_value.blank?
    end
  end

  def scopes_block_selected?
    block_name_list.include?('scopes')
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
    User.add_instruction_boolean_settings(:submit_notifications, :messages_notifications)
  end
end
