class DataProvider < ApplicationRecord
  extend FriendlyId

  URL_REGEX = %r{\A((http|https)://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w\-._~:/?#\[\]@!$&'()*+,;%=]*)?\z}

  friendly_id :slug, use: :slugged

  has_one_attached :logo

  before_validation :set_slug_from_name, if: -> { slug.blank? && name.present? }
  before_validation :attach_placeholder_logo, if: -> { !logo.attached? }

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :link, presence: true, format: { with: URL_REGEX, message: I18n.t('activemodel.errors.messages.url_format') }
  validates :logo, attached: true, content_type: %w[image/png image/jpeg image/svg+xml]

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

  def set_slug_from_name
    self.slug = name.parameterize
  end

  def attach_placeholder_logo
    logo.attach(
      io: Rails.root.join('app/assets/images/artwork/pictograms/buildings/city-hall.svg').open,
      filename: 'city-hall.svg',
      content_type: 'image/svg+xml'
    )
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
