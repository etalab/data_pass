# rubocop:disable Style/FormatStringToken
RSpec.describe MessageTemplate do
  it 'has a valid factory' do
    expect(build(:message_template)).to be_valid
  end

  describe 'validations' do
    it 'validates authorization_definition_uid existence' do
      expect(build(:message_template, authorization_definition_uid: 'invalid_uid')).not_to be_valid
    end

    it 'accepts valid variables' do
      template = build(:message_template, content: 'Bonjour, voici votre demande %{demande_url}')
      expect(template).to be_valid
    end

    it 'rejects unknown variables' do
      template = build(:message_template, content: 'Hello %{unknown_variable}')
      expect(template).not_to be_valid
    end

    it 'allows up to 3 templates per type' do
      create_list(:message_template, 2,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)

      template = build(:message_template,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)
      expect(template).to be_valid
    end

    it 'rejects more than 3 templates per type' do
      create_list(:message_template, 3,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)

      template = build(:message_template,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)
      expect(template).not_to be_valid
    end

    it 'allows 3 templates per type independently' do
      create_list(:message_template, 3,
        authorization_definition_uid: 'api_entreprise',
        template_type: :modification_request)

      template = build(:message_template,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)
      expect(template).to be_valid
    end

    it 'allows approval template type' do
      template = build(:message_template,
        authorization_definition_uid: 'api_entreprise',
        template_type: :approval)
      expect(template).to be_valid
    end

    it 'allows 3 approval templates independently from other types' do
      create_list(:message_template, 3,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)

      template = build(:message_template,
        authorization_definition_uid: 'api_entreprise',
        template_type: :approval)
      expect(template).to be_valid
    end

    it 'allows updating an existing template without counting it' do
      template = create(:message_template,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)

      create_list(:message_template, 2,
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal)

      template.title = 'Updated title'
      expect(template).to be_valid
    end
  end
end
# rubocop:enable Style/FormatStringToken
