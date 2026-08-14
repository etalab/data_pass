require 'rails_helper'

RSpec.describe Molecules::Instruction::UserRights::TableRowComponent, type: :component do
  let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
  let(:other_user) { create(:user, email: 'other@gouv.fr', roles: ['dinum:api_entreprise:reporter']) }

  def render_row(user:, authority:, current_user:)
    render_inline(described_class.new(user:, authority:, current_user:))
  end

  context 'when the row belongs to another user' do
    it 'renders a single manage action' do
      render_row(user: other_user, authority: Rights::ManagerAuthority.new(manager), current_user: manager)

      expect(page).to have_link('Gérer les droits / modifier')
      expect(page).to have_no_css('.fr-icon-delete-line')
    end
  end

  context 'when the row belongs to the connected manager' do
    it 'hides the manage action (a manager cannot self-edit)' do
      render_row(user: manager, authority: Rights::ManagerAuthority.new(manager), current_user: manager)

      expect(page).to have_no_link('Gérer les droits / modifier')
    end
  end

  context 'when the row belongs to the connected admin' do
    let(:admin) { create(:user, roles: ['admin']) }

    it 'keeps the manage action (self-edit allowed)' do
      render_row(user: admin, authority: Rights::AdminAuthority.new(admin), current_user: admin)

      expect(page).to have_link('Gérer les droits / modifier')
    end
  end

  context 'when the user has more than two specific API rights' do
    let(:power_user) do
      create(:user, email: 'power@gouv.fr', roles: %w[
        dinum:api_entreprise:reporter dinum:api_particulier:reporter dinum:api_indicateurs_sociaux:reporter
      ])
    end

    it 'aggregates the droits behind a count summary' do
      render_row(user: power_user, authority: Rights::AdminAuthority.new(power_user), current_user: power_user)

      expect(page).to have_css('details summary', text: '3 API activées')
    end
  end

  context 'when the user has no specific API right' do
    let(:fd_only_user) { create(:user, email: 'fd@gouv.fr', roles: ['dinum:*:manager']) }

    it 'shows the « aucun droit assigné » badge' do
      render_row(user: fd_only_user, authority: Rights::AdminAuthority.new(fd_only_user), current_user: fd_only_user)

      expect(page).to have_css('p.fr-badge', text: 'aucun droit assigné')
    end
  end

  context 'when the role→API pairing is ambiguous (≥ 2 roles and ≥ 2 APIs)' do
    let(:ambiguous_user) do
      create(:user, email: 'ambiguous@gouv.fr', roles: %w[dinum:api_entreprise:manager dinum:api_particulier:instructor])
    end

    it 'exposes a tooltip detailing which role applies to which API' do
      render_row(user: ambiguous_user, authority: Rights::AdminAuthority.new(ambiguous_user), current_user: ambiguous_user)

      expect(page).to have_css('.fr-btn--tooltip[aria-describedby]')
      expect(page).to have_css('[role="tooltip"]', text: 'API Entreprise', visible: :all)
    end
  end

  context 'when the pairing is unambiguous (a single role type)' do
    let(:single_role_user) do
      create(:user, email: 'single@gouv.fr', roles: %w[dinum:api_entreprise:manager dinum:api_particulier:manager])
    end

    it 'does not render a tooltip' do
      render_row(user: single_role_user, authority: Rights::AdminAuthority.new(single_role_user), current_user: single_role_user)

      expect(page).to have_no_css('.fr-btn--tooltip')
    end
  end
end
