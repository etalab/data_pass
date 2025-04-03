RSpec.describe 'OpenAPI files' do
  it 'works and render a valid OpenAPI file' do
    get '/api-docs/v1.yaml'

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq('application/yaml')
    expect(YAML.safe_load(response.body)).to be_a(Hash)

    document = Openapi3Parser.load(response.body)
    expect(document).to be_valid, "OpenAPI file is invalid: #{document.errors}"
  end
end
