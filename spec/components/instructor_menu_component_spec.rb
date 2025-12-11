RSpec.describe InstructorMenuComponent, type: :component do
  describe '#render?' do
    context 'when show_drafts and show_templates are false' do
      it 'does not render' do
        render_inline(described_class.new(show_drafts: false, show_templates: false))

        expect(page).to have_no_css('.fr-header__menu')
      end
    end

    context 'when show_drafts is true' do
      it 'renders the menu' do
        render_inline(described_class.new(show_drafts: true, show_templates: false))

        expect(page).to have_css('.fr-header__menu')
      end
    end

    context 'when show_templates is true' do
      it 'renders the menu' do
        render_inline(described_class.new(show_drafts: false, show_templates: true))

        expect(page).to have_css('.fr-header__menu')
      end
    end
  end

  describe 'menu links' do
    it 'always displays authorizations and requests link' do
      render_inline(described_class.new(show_drafts: true, show_templates: false))

      expect(page).to have_link(I18n.t('layouts.header.menu.instruction.authorizations_and_requests'))
    end

    context 'when show_drafts is true' do
      it 'displays instructor drafts link' do
        render_inline(described_class.new(show_drafts: true, show_templates: false))

        expect(page).to have_link(I18n.t('layouts.header.menu.instruction.instructor_authorization_requests'))
      end
    end

    context 'when show_drafts is false' do
      it 'does not display instructor drafts link' do
        render_inline(described_class.new(show_drafts: false, show_templates: true))

        expect(page).to have_no_link(I18n.t('layouts.header.menu.instruction.instructor_authorization_requests'))
      end
    end

    context 'when show_templates is true' do
      it 'displays message templates link' do
        render_inline(described_class.new(show_drafts: false, show_templates: true))

        expect(page).to have_link(I18n.t('layouts.header.menu.instruction.message_templates'))
      end
    end

    context 'when show_templates is false' do
      it 'does not display message templates link' do
        render_inline(described_class.new(show_drafts: true, show_templates: false))

        expect(page).to have_no_link(I18n.t('layouts.header.menu.instruction.message_templates'))
      end
    end
  end
end
