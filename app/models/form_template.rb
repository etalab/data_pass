class FormTemplate < ApplicationRecord
  extend FriendlyId

  has_paper_trail

  friendly_id :name, use: :slugged

  belongs_to :habilitation_type

  validates :slug, presence: true, uniqueness: true
  validate :slug_not_taken_by_yaml
  validate :ht_keeps_at_least_one_default, on: :update
  before_destroy :ensure_not_last_default

  after_destroy :reset_arf_cache
  after_save :reset_arf_cache

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

  def slug_not_taken_by_yaml
    return if slug.blank?
    return unless AuthorizationRequestFormConfigurations.instance.all.key?(slug.to_sym)

    errors.add(:slug, :taken_by_yaml_form)
  end

  def ht_keeps_at_least_one_default
    return unless default_was && !default
    return if habilitation_type.form_templates.where(default: true).where.not(id: id).exists?

    errors.add(:default, :last_default_form_template)
  end

  def ensure_not_last_default
    return if destroyed_by_association
    return unless default?
    return unless habilitation_type.form_templates.where(default: true).one?

    errors.add(:base, :last_default_form_template)
    throw :abort
  end
end
