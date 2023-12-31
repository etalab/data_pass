RSpec.describe 'Profile' do
  describe 'MonComptePro interactions' do
    let(:user) { create(:user) }

    before do
      sign_in(user)

      OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
        provider: :mon_compte_pro,
        uid: info_attributes[:sub],
        info: info_attributes,
        credentials: {
          token: 'token',
          expires_at: 1.hour.from_now.to_i,
          expires: true
        }
      })
    end

    after do
      OmniAuth.config.mock_auth[:mon_compte_pro] = nil
    end

    describe 'change current organization' do
      subject(:change_current_organization) do
        visit profile_path

        click_link_or_button 'change_current_organization'
      end

      let(:info_attributes) { attributes_for(:mon_compte_pro_payload, email: user.email, sub: user.external_id, given_name: 'Jacques') }

      it 'changes current organization, displays success and redirects to profile path' do
        expect {
          change_current_organization
        }.to change { user.reload.current_organization }

        expect(page).to have_css('.fr-alert')
        expect(page).to have_current_path(profile_path, ignore_query: true)
      end

      describe 'when current user is not the same' do
        let(:info_attributes) { attributes_for(:mon_compte_pro_payload, email: another_email) }
        let(:another_email) { 'new_user@gouv.fr' }

        it 'changes current user too' do
          change_current_organization

          expect(page).to have_css('.fr-alert')
          expect(page).to have_content(another_email)
        end
      end
    end

    describe 'update user infos' do
      subject(:update_user_infos) do
        visit profile_path

        click_link_or_button 'update_infos'
      end

      let(:info_attributes) { attributes_for(:mon_compte_pro_payload, email: user.email, sub: user.external_id, given_name: 'Jacques') }

      it 'update user infos, displays success and redirects to profile path' do
        expect {
          update_user_infos
        }.to change { user.reload.given_name }.to('Jacques')

        expect(page).to have_css('.fr-alert')
        expect(page).to have_current_path(profile_path, ignore_query: true)
      end

      describe 'when current user is not the same' do
        let(:info_attributes) { attributes_for(:mon_compte_pro_payload, email: another_email) }
        let(:another_email) { 'new_user@gouv.fr' }

        it 'changes current user too' do
          update_user_infos

          expect(page).to have_css('.fr-alert')
          expect(page).to have_content(another_email)
        end
      end
    end
  end
end
