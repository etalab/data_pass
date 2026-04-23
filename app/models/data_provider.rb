class DataProvider < ApplicationRecord
  extend FriendlyId

  URL_REGEX = %r{\A((http|https)://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w\-._~:/?#\[\]@!$&'()*+,;%=]*)?\z}

  friendly_id :slug, use: :slugged

  has_paper_trail
  has_one_attached :logo, dependent: :purge_later

  attr_writer :linked_habilitation_types

  before_validation :set_slug_from_name, if: -> { slug.blank? && name.present? }

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :link, presence: true, format: { with: URL_REGEX, message: I18n.t('activemodel.errors.messages.url_format') }
  validates :logo, content_type: %w[image/png image/jpeg image/svg+xml], if: -> { logo.attached? }

  after_save :reset_static_caches

  def linked_habilitation_types?
    return @linked_habilitation_types if defined?(@linked_habilitation_types)

    @linked_habilitation_types = HabilitationType.exists?(data_provider: self)
  end

  def deletable?
    !linked_habilitation_types? && authorization_definitions.empty?
  end

  def self.preload_linked_habilitation_types!(data_providers)
    linked_ids = HabilitationType.where(data_provider: data_providers)
      .distinct
      .pluck(:data_provider_id)
      .to_set

    data_providers.each do |data_provider|
      data_provider.linked_habilitation_types = linked_ids.include?(data_provider.id)
    end
  end

  def authorization_definitions
    @authorization_definitions ||= AuthorizationDefinition.all.select do |authorization_definition|
      authorization_definition.provider&.slug == slug
    end
  end

  def reporters
    users_for_roles(%w[instructor reporter])
  end

  def instructors
    users_for_roles(%w[instructor])
  end

  private

  def reset_static_caches
    AuthorizationDefinition.reset!
    AuthorizationRequestForm.reset!
  end

  def set_slug_from_name
    self.slug = name.parameterize
  end

  def users_for_roles(roles)
    User.where(
      "EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role in (?)
      )",
      roles.map { |role| build_user_role_query_param(role) }.flatten,
    )
  end

  def build_user_role_query_param(role)
    authorization_definitions.map do |authorization_definition|
      "#{authorization_definition.id}:#{role}"
    end
  end
end
