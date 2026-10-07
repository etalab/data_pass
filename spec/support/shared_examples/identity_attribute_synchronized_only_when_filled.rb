RSpec.shared_examples 'an identity attribute synchronized only when filled' do |attribute, payload_key, filled_value|
  context "when #{payload_key} is missing from the payload" do
    let(:removed_payload_keys) { [payload_key] }

    it "keeps the existing #{attribute}" do
      expect { find_or_create_user }.not_to(change { user.reload.public_send(attribute) })
    end
  end

  [nil, '', '   '].each do |blank_value|
    context "when #{payload_key} is #{blank_value.inspect}" do
      let(:payload_overrides) { { payload_key.to_sym => blank_value } }

      it "keeps the existing #{attribute}" do
        expect { find_or_create_user }.not_to(change { user.reload.public_send(attribute) })
      end
    end
  end

  context "when #{payload_key} is filled" do
    let(:payload_overrides) { { payload_key.to_sym => filled_value } }

    it "updates #{attribute}" do
      expect { find_or_create_user }.to change { user.reload.public_send(attribute) }.to(filled_value)
    end
  end
end
