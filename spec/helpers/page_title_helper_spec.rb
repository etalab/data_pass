require 'rails_helper'

RSpec.describe PageTitleHelper do
  describe '#page_title' do
    it 'returns the full format when title is provided' do
      expect(helper.page_title('Accueil')).to eq('Accueil - DataPass')
    end

    it 'returns only site name when title is nil' do
      expect(helper.page_title(nil)).to eq('DataPass')
    end

    it 'returns only site name when title is empty string' do
      expect(helper.page_title('')).to eq('DataPass')
    end

    it 'works with custom separator' do
      expect(helper.page_title('Accueil', separator: ' | ')).to eq('Accueil | DataPass')
    end

    it 'works with custom site name' do
      expect(helper.page_title('Accueil', site_name: 'CustomSite')).to eq('Accueil - CustomSite')
    end
  end

  describe '#provide_title' do
    it 'stores the title in content_for' do
      helper.provide_title('Test Title')
      expect(helper.content_for(:page_title)).to eq('Test Title')
    end
  end

  describe '#display_page_title' do
    it 'returns the formatted title when title is set' do
      helper.provide_title('Dashboard')
      expect(helper.display_page_title).to eq('Dashboard - DataPass')
    end

    it 'returns only site name when no title is set' do
      expect(helper.display_page_title).to eq('DataPass')
    end
  end
end
