class Import::Users < Import::Base
  def initialize(organizations)
    @organizations = organizations
  end

  def perform
    log("Importing users")

    csv('users').each do |user_row|
      next unless import?(user_row)

      user = User.find_or_initialize_by(email: user_row['email'])

      user.assign_attributes(
        user_row.to_h.slice(
          'given_name',
          'family_name',
          'phone_number',
        ).merge(
          job_title: user_row['job'],
          external_id: user_row['uid'],
        )
      )

      user.save!

      break
    end
  end

  private

  def import?(user_row)
    false
  end
end
