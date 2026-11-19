require 'rails_helper'

RSpec.describe Organisms::HeroComponent, type: :component do
  context 'with the blue variant' do
    subject(:rendered) do
      render_inline(described_class.new(variant: :blue, kicker: 'Surtitre', title: 'Titre', heading: { tag: :h1 })) do |hero|
        hero.with_lead { 'Chapô' }
        hero.with_footer { 'Tuiles' }
      end
    end

    it 'renders a full width blue section with the heading' do
      expect(rendered).to have_css('section.lp-hero')
      expect(rendered).to have_css('section > .fr-container > p.lp-kicker', text: 'Surtitre')
      expect(rendered).to have_css('h1', text: 'Titre')
      expect(rendered).to have_text('Chapô')
      expect(rendered).to have_text('Tuiles')
      expect(rendered).to have_no_css('.lp-compo')
    end
  end

  context 'with the band variant' do
    subject(:rendered) do
      render_inline(described_class.new(title: 'Titre', heading: { class: 'fr-h3', id: 'titre' }, section: { id: 'encart', class: 'lp-teaser' })) do |hero|
        hero.with_actions { 'Action' }
        hero.with_illustration { 'Illustration' }
      end
    end

    it 'renders the text and the illustration side by side, labelled by the title' do
      expect(rendered).to have_css('section#encart.lp-band.lp-teaser[aria-labelledby="titre"]')
      expect(rendered).to have_css('.lp-compo__text h2.fr-h3#titre', text: 'Titre')
      expect(rendered).to have_css('.lp-compo__text', text: 'Action')
      expect(rendered).to have_css('.lp-compo__img', text: 'Illustration')
    end
  end

  context 'without illustration' do
    subject(:rendered) { render_inline(described_class.new(title: 'Titre')) }

    it 'renders no image column and no aria-labelledby' do
      expect(rendered).to have_no_css('.lp-compo__img')
      expect(rendered).to have_no_css('section[aria-labelledby]')
    end
  end

  context 'with an unknown variant' do
    it 'raises ArgumentError' do
      expect {
        described_class.new(title: 'Titre', variant: :rouge)
      }.to raise_error(ArgumentError, /variant must be one of/)
    end
  end
end
