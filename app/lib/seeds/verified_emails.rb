class Seeds::VerifiedEmails
  def initialize(_context); end

  def perform
    User.find_each do |user|
      create_verified_email(user.email, 'deliverable')
    end

    create_verified_email('unknown-but-whitelisted@wanadoo.fr', 'whitelisted')

    AuthorizationRequest.find_each do |authorization_request|
      authorization_request.class.contact_types.each do |contact_type|
        create_verified_email(authorization_request.send(:"#{contact_type}_email"), 'deliverable')
      end
    end
  end

  private

  def create_verified_email(email, status)
    return if email.blank?
    return if VerifiedEmail.exists?(email:)

    VerifiedEmail.create!(
      email:,
      status:,
      verified_at: Time.zone.now,
    )
  end
end
