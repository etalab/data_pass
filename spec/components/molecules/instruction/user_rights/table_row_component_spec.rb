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

  context 'when an admin also holds a role inside the manager perimeter' do
    let(:admin_with_role) do
      create(:user, email: 'admin-too@gouv.fr', roles: ['admin', 'dinum:api_entreprise:instructor'])
    end

    it 'hides the admin badge from a manager' do
      render_row(user: admin_with_role, authority: Rights::ManagerAuthority.new(manager), current_user: manager)

      expect(page).to have_text('Instructeur')
      expect(page).to have_no_text('Admin')
    end

    it 'does not betray the admin through the rights column either' do
      render_row(user: admin_with_role, authority: Rights::ManagerAuthority.new(manager), current_user: manager)

      expect(page).to have_no_text('Tous les accès')
      expect(page).to have_text('API Entreprise')
    end

    it 'keeps the admin badge for an admin' do
      other_admin = create(:user, :admin)
      render_row(user: admin_with_role, authority: Rights::AdminAuthority.new(other_admin), current_user: other_admin)

      expect(page).to have_text('Admin')
    end
  end

  context 'when the user holds no role at all' do
    let(:admin) { create(:user, :admin) }
    let(:plain_user) { create(:user, email: 'plain@gouv.fr', roles: []) }

    before { render_row(user: plain_user, authority: Rights::AdminAuthority.new(admin), current_user: admin) }

    it 'announces the absence of role and of API' do
      expect(page).to have_text('Aucun rôle')
      expect(page).to have_text('aucune API activée')
    end

    it 'offers to add rights rather than to manage them' do
      expect(page).to have_link('Ajouter des droits')
      expect(page).to have_no_link('Gérer les droits / modifier')
    end

    it 'pre-fills the form with the user email' do
      expect(page).to have_link('Ajouter des droits', href: /email=plain%40gouv\.fr/)
    end
  end

  context 'when the user has more than two specific API rights' do
    let(:power_user) do
      create(:user, email: 'power@gouv.fr', roles: %w[
        dinum:api_entreprise:reporter dinum:api_particulier:reporter dinum:api_indicateurs_sociaux:reporter
      ])
    end

    it 'aggregates the droits behind a count that opens the detail' do
      render_row(user: power_user, authority: Rights::AdminAuthority.new(power_user), current_user: power_user)

      expect(page).to have_link('3 API activées')
    end
  end

  context 'when the user only holds an FD-wildcard role' do
    let(:fd_only_user) { create(:user, email: 'fd@gouv.fr', roles: ['dinum:*:manager']) }

    it 'shows « Tous les services … » instead of « aucun droit assigné »' do
      render_row(user: fd_only_user, authority: Rights::AdminAuthority.new(fd_only_user), current_user: fd_only_user)

      expect(page).to have_text('Tous les services')
      expect(page).to have_no_css('p.fr-badge', text: 'aucun droit assigné')
    end
  end

  context 'when the user is an admin' do
    let(:admin_user) { create(:user, email: 'adminuser@gouv.fr', roles: %w[admin dinum:api_entreprise:manager]) }

    it 'shows « Tous les accès », which subsumes any specific right' do
      render_row(user: admin_user, authority: Rights::AdminAuthority.new(admin_user), current_user: admin_user)

      expect(page).to have_text('Tous les accès')
      expect(page).to have_no_text('API Entreprise')
    end
  end

  context 'when the rights are folded behind a count' do
    let(:many_rights_user) do
      create(:user, email: 'many@gouv.fr', roles: %w[
        dinum:api_entreprise:manager dinum:api_particulier:instructor dinum:formulaire_qf:reporter
      ])
    end

    before { render_row(user: many_rights_user, authority: Rights::AdminAuthority.new(many_rights_user), current_user: many_rights_user) }

    it 'opens the detail modal instead of expanding in place' do
      expect(page).to have_link('3 API activées')
      expect(page).to have_css('[aria-controls="main-modal"]')
      expect(page).to have_no_css('details')
    end

    it 'no longer carries the tooltip it replaces' do
      expect(page).to have_no_css('.fr-btn--tooltip')
      expect(page).to have_no_css('[role="tooltip"]', visible: :all)
    end
  end

  context 'when two rights or fewer are held' do
    let(:two_rights_user) do
      create(:user, email: 'two@gouv.fr', roles: %w[dinum:api_entreprise:manager dinum:api_particulier:manager])
    end

    it 'spells them out without any trigger' do
      render_row(user: two_rights_user, authority: Rights::AdminAuthority.new(two_rights_user), current_user: two_rights_user)

      expect(page).to have_text('API Entreprise')
      expect(page).to have_no_css('[aria-controls="main-modal"]')
    end
  end
end
