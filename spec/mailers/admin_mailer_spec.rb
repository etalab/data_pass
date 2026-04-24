require 'rails_helper'

RSpec.describe AdminMailer do
  describe '#notify_user_roles_change' do
    let(:mail) { described_class.with(user:, old_roles: %w[dinum:api_entreprise:reporter]).notify_user_roles_change }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
    let!(:admins) { create_list(:user, 2, :admin) }

    it 'sends emails to admins in bcc' do
      expect(mail.bcc).to match_array(User.admin.map(&:email))
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(user.email)
      expect(mail.body.encoded).to include('dinum:api_entreprise:instructor')
      expect(mail.body.encoded).to include('dinum:api_entreprise:reporter')
    end
  end
end
