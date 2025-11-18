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
    it 'returns the formatted title when title is set' do
      helper.set_title!('Dashboard')
      expect(helper.page_title).to eq('Dashboard - DataPass')
    end

    it 'returns only site name when no title is set' do
      expect(helper.page_title).to eq('DataPass')
    end
  end
end
