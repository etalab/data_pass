RSpec.describe 'Authorizations config files' do
  def block_exists?(kind, name)
    if kind == 'edit'
      base_path = 'app/views/authorization_request_forms/blocks/default'
    elsif kind == 'show'
      base_path = 'app/views/authorization_requests/blocks/default'
    else
      raise "Unknown kind: #{kind}"
    end

    path_parts = name.split('/')
    path_parts[-1] = "_#{path_parts[-1]}"
    name = path_parts.join('/')

    Rails.root.join(
      base_path,
      "#{name}.html.erb"
    ).exist?
  end

  describe 'blocks existences' do
    it 'defines each block views: edit and show' do
      AuthorizationDefinition.all.each do |authorization_definition|
        authorization_definition.blocks.each do |block|
          expect(block_exists?('edit', block[:name])).to be_truthy, "AuthorizationDefinition: #{authorization_definition.name}, block: #{block[:name]} for edit does not exist"
          expect(block_exists?('show', block[:name])).to be_truthy, "AuthorizationDefinition: #{authorization_definition.name}, block: #{block[:name]} for show does not exist"
        end
      end
    end
  end

  describe 'steps existences' do
    it 'defines each step views' do
      AuthorizationRequestForm.all.each do |authorization_request_form|
        authorization_request_form.steps.each do |step|
          expect(block_exists?('edit', step[:name])).to be_truthy, "Form: #{authorization_request_form.uid}, step: #{step[:name]} does not exist"
        end
      end
    end
  end

  describe 'API Particulier forms modalities blocks' do
    subject(:forms) { AuthorizationDefinition.find('api_particulier').available_forms }

    it 'is static for each form' do
      forms.each do |form|
        next if form.uid == 'api-particulier'

        expect(form.static_blocks.pluck(:name) & ['modalities']).to be_present, "Form #{form.uid} should have a static block named 'modalities'"
      end
    end
  end
end
