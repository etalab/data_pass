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
end
