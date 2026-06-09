class FormTemplate < ApplicationRecord
  extend FriendlyId

  has_paper_trail

  friendly_id :name, use: :slugged

  belongs_to :habilitation_type

  validates :slug, presence: true, uniqueness: true
  validate :service_provider_must_exist, if: -> { service_provider_id.present? }
  validate :slug_not_taken_by_yaml
  validate :ht_keeps_at_least_one_default, on: :update
  validate :only_one_default_per_habilitation_type, if: :default?
  before_destroy :ensure_not_last_default

  after_commit :reset_arf_cache, on: %i[create update destroy]

  def service_provider
    return nil if service_provider_id.blank?

    ServiceProvider.find(service_provider_id)
  rescue StaticApplicationRecord::EntryNotFound
    nil
  end

  private

  def reset_arf_cache
    AuthorizationRequestForm.reset!
  end

  def service_provider_must_exist
    return if ServiceProvider.exists?(id: service_provider_id)

    errors.add(:service_provider_id, :inclusion)
  end

  def slug_not_taken_by_yaml
    return if slug.blank?
    return unless AuthorizationRequestFormConfigurations.instance.all.key?(slug.to_sym)

    errors.add(:slug, :taken_by_yaml_form)
  end

  def other_defaults
    habilitation_type.form_templates.where(default: true).where.not(id: id)
  end

  def ht_keeps_at_least_one_default
    return unless default_was && !default

    errors.add(:default, :last_default_form_template) unless other_defaults.exists?
  end

  def only_one_default_per_habilitation_type
    errors.add(:default, :already_taken) if other_defaults.exists?
  end

  def ensure_not_last_default
    return if destroyed_by_association
    return unless default?
    return if other_defaults.exists?

    errors.add(:base, :last_default_form_template)
    throw :abort
  end
end
