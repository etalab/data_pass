require 'rails_helper'

RSpec.describe PageTitleHelper do
  describe '#format_title' do
    it 'returns the full format when title is provided' do
      expect(helper.format_title('Accueil')).to eq('Accueil - DataPass')
    end

    it 'returns only site name when title is nil' do
      expect(helper.format_title(nil)).to eq('DataPass')
    end

    it 'returns only site name when title is empty string' do
      expect(helper.format_title('')).to eq('DataPass')
    end

    it 'works with custom separator' do
      expect(helper.format_title('Accueil', separator: ' | ')).to eq('Accueil | DataPass')
    end

    it 'works with custom site name' do
      expect(helper.format_title('Accueil', site_name: 'CustomSite')).to eq('Accueil - CustomSite')
    end
  end

  describe '#set_title!' do
    it 'stores the formatted title in content_for' do
      helper.set_title!('Test Title')
      expect(helper.content_for(:page_title)).to eq('Test Title - DataPass')
    end

    it 'works with custom separator' do
      helper.set_title!('Test Title', separator: ' | ')
      expect(helper.content_for(:page_title)).to eq('Test Title | DataPass')
    end
  end

  describe '#page_title' do
    context 'when a title has been set' do
      it 'returns the formatted title' do
        helper.set_title!('Dashboard')
        expect(helper.page_title).to eq('Dashboard - DataPass')
      end
    end

    context 'when no title has been set' do
      context 'when in the test environment' do
        before do
          allow(helper).to receive_messages(controller_path: 'non_existent', action_name: 'show')
        end

        it 'raises TitleNotDefinedError to surface the missing set_title!' do
          expect { helper.page_title }.to raise_error(
            TitleDefinedChecker::TitleNotDefinedError,
            /No page title has been defined for the current page \(non_existent#show\)/
          )
        end
      end

      context 'when outside the test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        it 'falls back to the site name' do
          expect(helper.page_title).to eq('DataPass')
        end
      end
    end
  end
end
