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

  describe 'forms uniqueness' do
    it 'never declares the same form uid twice across form files' do
      uids = Rails.root.glob('config/authorization_request_forms/*.y*ml').flat_map do |file|
        Psych.parse(File.read(file)).root.children.each_slice(2).map { |key, _value| key.value }
      end

      duplicates = uids.tally.select { |_uid, count| count > 1 }.keys

      expect(duplicates).to be_empty, "Formulaires déclarés plusieurs fois : #{duplicates.join(', ')}"
    end
  end
end
