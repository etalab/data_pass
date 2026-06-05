require 'rails_helper'

RSpec.describe Molecules::Instruction::UserRights::TableRowComponent, type: :component do
  let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
  let(:other_user) { create(:user, email: 'other@gouv.fr', roles: ['dinum:api_entreprise:reporter']) }

  def render_row(user:, authority:, current_user:)
    render_inline(described_class.new(user:, authority:, current_user:))
  end

  context 'when the row belongs to another user' do
    it 'renders the edit and delete actions' do
      render_row(user: other_user, authority: Rights::ManagerAuthority.new(manager), current_user: manager)

      expect(page).to have_css('.fr-icon-edit-line')
      expect(page).to have_css('.fr-icon-delete-line')
    end
  end

  context 'when the row belongs to the connected manager' do
    it 'hides the edit and delete actions (a manager cannot self-edit)' do
      render_row(user: manager, authority: Rights::ManagerAuthority.new(manager), current_user: manager)

      expect(page).to have_no_css('.fr-icon-edit-line')
      expect(page).to have_no_css('.fr-icon-delete-line')
    end
  end

  context 'when the row belongs to the connected admin' do
    let(:admin) { create(:user, roles: ['admin']) }

    it 'keeps the edit action (self-edit allowed)' do
      render_row(user: admin, authority: Rights::AdminAuthority.new(admin), current_user: admin)

      expect(page).to have_css('.fr-icon-edit-line')
    end
  end
end
