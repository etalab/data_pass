class Molecules::WalletRegistry::OrganizationIdentityComponent < ApplicationComponent
  include Molecules::WalletRegistry::IdentityFormatting

  EXECUTIVE_VERIFICATION_FORM_ID = 'wallet-executive-verification-form'.freeze

  def initialize(authorization_request:, executive_certified: nil)
    @authorization_request = authorization_request
    @executive_certified = executive_certified
  end

  private

  attr_reader :authorization_request, :executive_certified

  delegate :wallet_identity_source, :wallet_public_sector?,
    :identity_legal_name,
    to: :authorization_request

  def sirene_available?
    %i[sirene non_diffusible].include?(wallet_identity_source)
  end

  def address_known?
    wallet_identity_source == :sirene
  end

  def legal_summary
    [short_legal_form, naf_summary].compact_blank.join(' · ')
  end

  def siret_label
    sirene_available? ? t('.siret') : t('.siret_from_pro_connect')
  end

  def applicant_capacity
    @applicant_capacity ||= authorization_request.applicant_capacity(executive_certified:)
  end

  def executive_verification_required?
    applicant_capacity == :executive_verification_required
  end

  def capacity_badge
    return if applicant_capacity == :unknown

    badge_kind = executive_verification_required? ? 'fr-badge--warning' : 'fr-badge--info'
    tag.p(t(".capacity.#{applicant_capacity}"), class: ['fr-badge', badge_kind, 'fr-badge--sm', 'wx-org__badge'], id: 'wallet-applicant-capacity')
  end
end
