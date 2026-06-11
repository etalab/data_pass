RSpec.describe 'Sentry initializer' do
  describe 'before_send_transaction' do
    subject(:filtered_event) { filter.call(event, nil) }

    let(:filter) { Sentry.get_current_client.configuration.before_send_transaction }

    let(:rails_pulse_span) do
      { op: 'db.sql.active_record', description: 'INSERT INTO "rails_pulse_operations" ("request_id") VALUES ($1)' }
    end
    let(:application_span) do
      { op: 'db.sql.active_record', description: 'SELECT * FROM "authorization_requests"' }
    end
    let(:render_span) do
      { op: 'view.render.template', description: 'dashboard/show.html.erb' }
    end

    let(:event) { Struct.new(:spans).new([rails_pulse_span, application_span, render_span]) }

    it 'drops rails_pulse instrumentation spans' do
      expect(filtered_event.spans).not_to include(rails_pulse_span)
    end

    it 'keeps application spans' do
      expect(filtered_event.spans).to contain_exactly(application_span, render_span)
    end

    context 'when the event has no spans' do
      let(:event) { Struct.new(:spans).new(nil) }

      it 'returns the event untouched' do
        expect(filtered_event.spans).to be_nil
      end
    end
  end
end
