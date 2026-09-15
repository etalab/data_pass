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

  describe 'AEEH scope on tarification municipale enfance editor forms' do
    subject(:editor_forms) do
      AuthorizationRequestForm.all.select do |form|
        form.use_case.to_s == 'tarification_municipale_enfance' && form.service_provider.present?
      end
    end

    let(:aeeh_scope) { 'cnav_allocation_enfant_handicape' }

    def scope_displayed?(form, scope_value)
      hidden = form.scopes_config[:hide]
      return false if hidden.present? && hidden.include?(scope_value)

      displayed = form.scopes_config[:displayed]
      displayed.blank? || displayed.include?(scope_value)
    end

    it 'targets every editor form of the use case' do
      expect(editor_forms).not_to be_empty
    end

    it 'displays the scope on each editor form' do
      editor_forms.each do |form|
        expect(scope_displayed?(form, aeeh_scope)).to be_truthy, "Form: #{form.uid} does not display #{aeeh_scope}"
      end
    end

    it 'never pre-checks the scope' do
      editor_forms.each do |form|
        expect(form.initialize_with[:scopes] || []).not_to include(aeeh_scope), "Form: #{form.uid} pre-checks #{aeeh_scope}"
      end
    end
  end
end
