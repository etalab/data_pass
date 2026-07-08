# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizationExtensions::CadreJuridiqueDinum do
  let(:klass) { AuthorizationRequest::ProduitsDinum }

  describe 'mass-assignment safety' do
    it 'exposes cadre_juridique_dinum_nature and cadre_juridique_dinum_url as permitted extra attributes' do
      expect(klass.extra_attributes).to include(:cadre_juridique_dinum_nature, :cadre_juridique_dinum_url)
    end
  end

  describe 'when submitted' do
    subject(:valid?) { demande.valid?(:submit) }

    let(:demande) { klass.new(**params) }
    let(:params) { {} }

    before { valid? }

    context 'without nature' do
      it { expect(demande.errors[:cadre_juridique_dinum_nature]).to be_present }
    end

    context 'with nature filled' do
      let(:params) { { cadre_juridique_dinum_nature: 'Établissement public administratif' } }

      it { expect(demande.errors[:cadre_juridique_dinum_nature]).to be_empty }
    end

    context 'without document nor url' do
      it { expect(demande.errors[:cadre_juridique_dinum_document]).to be_present }
      it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_present }
    end

    context 'with a document attached' do
      let(:demande) do
        klass.new.tap do |d|
          File.open('spec/fixtures/dummy.pdf') do |file|
            d.cadre_juridique_dinum_document.attach(io: file, filename: 'dummy.pdf')
          end
        end
      end

      it { expect(demande.errors[:cadre_juridique_dinum_document]).to be_empty }
      it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_empty }
    end

    context 'with a url' do
      let(:params) { { cadre_juridique_dinum_url: 'https://exemple.gouv.fr/loi' } }

      it { expect(demande.errors[:cadre_juridique_dinum_document]).to be_empty }
      it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_empty }
    end

    context 'with an invalid url format' do
      let(:params) { { cadre_juridique_dinum_url: 'pas une url' } }

      it { expect(demande.errors[:cadre_juridique_dinum_url]).to be_present }
    end
  end
end
