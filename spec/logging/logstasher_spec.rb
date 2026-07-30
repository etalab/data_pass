RSpec.describe 'LogStasher JSON logging', type: :request do
  subject(:request_events) do
    captured_output.string.each_line
      .map { |line| JSON.parse(line) }
      .select { |event| Array(event['tags']).include?('request') }
  end

  let(:captured_output) { StringIO.new }

  around do |example|
    original_logger = LogStasher.logger
    LogStasher.logger = Logger.new(captured_output)
    example.run
    LogStasher.logger = original_logger
  end

  it 'émet une ligne JSON de synthèse par requête' do
    get root_path

    expect(request_events.size).to eq(1)
  end

  it 'ajoute le champ « type » propre à data_pass' do
    get root_path

    expect(request_events.last).to include('type' => 'datapass')
  end

  it 'journalise la méthode HTTP et le statut de la réponse' do
    get root_path

    expect(request_events.last).to include(
      'method' => 'GET',
      'status' => 200
    )
  end

  describe 'filtrage des paramètres sensibles (log_controller_parameters actif, façon production)' do
    around do |example|
      original_flag = LogStasher.log_controller_parameters
      LogStasher.log_controller_parameters = true
      example.run
      LogStasher.log_controller_parameters = original_flag
    end

    it 'n’écrit jamais un paramètre sensible en clair dans le JSON' do
      get root_path, params: { password: 'SUPERSECRET', token: 'TOPSECRET' }

      expect(captured_output.string).not_to include('SUPERSECRET')
      expect(captured_output.string).not_to include('TOPSECRET')
      expect(request_events.last['parameters']).to include(
        'password' => '[FILTERED]',
        'token' => '[FILTERED]'
      )
    end
  end
end
