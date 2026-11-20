require 'rails_helper'

RSpec.describe DsfrFormBuilder, type: :helper do
  subject(:builder) { described_class.new(:authorization_request, authorization_request, helper, {}) }

  let(:authorization_request) { AuthorizationRequest::APIImpotParticulier.new }

  describe '#dsfr_file_field' do
    context 'when the attribute has a presence validator' do
      it 'renders the required asterisk in the label' do
        result = builder.dsfr_file_field(:safety_certification_document)

        expect(result).to include('fr-text-error')
      end
    end

    context 'when the attribute has no presence validator' do
      it 'does not render the required asterisk in the label' do
        result = builder.dsfr_file_field(:maquette_projet)

        expect(result).not_to include('fr-text-error')
      end
    end
  end

  describe '#dsfr_tel_field' do
    it 'renders a telephone input' do
      expect(builder.dsfr_tel_field(:intitule)).to include('type="tel"')
    end
  end

  describe 'error messages linked to their field' do
    before { authorization_request.errors.add(:intitule, :blank) }

    it 'gives the error message an id' do
      expect(builder.dsfr_text_field(:intitule)).to include('id="authorization_request_intitule-messages"')
    end

    it 'describes the input by its error message' do
      expect(builder.dsfr_text_field(:intitule)).to include('aria-describedby="authorization_request_intitule-messages"')
    end

    it 'renders the error message under a checkbox' do
      expect(builder.dsfr_check_box(:intitule)).to include('fr-message--error')
    end
  end

  describe 'a field without error' do
    it 'is not described by an error message' do
      expect(builder.dsfr_text_field(:intitule)).not_to include('aria-describedby')
    end
  end
end
