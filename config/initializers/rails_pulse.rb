# rubocop:disable Metrics/BlockLength
RailsPulse.configure do |config|
  config.enabled = !Rails.env.test?

  config.route_thresholds = {
    slow: 500,
    very_slow: 1500,
    critical: 3000
  }

  config.request_thresholds = {
    slow: 700,
    very_slow: 2000,
    critical: 4000
  }

  config.query_thresholds = {
    slow: 100,
    very_slow: 500,
    critical: 1000
  }

  config.track_assets = false
  config.mount_path = '/rails_pulse'

  config.ignored_routes = [
    %r{^/workers},
    %r{^/lookbook},
    %r{^/rails_pulse}
  ]
  config.ignored_requests = []
  config.ignored_queries = []

  config.tags = %w[ignored critical experimental]

  config.track_jobs = true
  config.job_thresholds = {
    slow: 5_000,
    very_slow: 30_000,
    critical: 60_000
  }
  config.ignored_jobs = [
    'RailsPulse::SummaryJob',
    'RailsPulse::CleanupJob'
  ]
  config.ignored_queues = []
  config.capture_job_arguments = false

  config.authentication_enabled = true
  config.authentication_redirect_path = '/'
  config.authentication_method = proc {
    user_id_session = session[:user_id]
    valid_session = user_id_session.present? &&
                    user_id_session['value'].present? &&
                    user_id_session['expires_at'].present? &&
                    user_id_session['expires_at'] > Time.current

    current_user = valid_session ? User.find_by(id: user_id_session['value']) : nil

    redirect_to main_app.root_path unless current_user&.admin?
  }

  config.archiving_enabled = true
  config.full_retention_period = 2.weeks
  config.max_table_records = {
    rails_pulse_requests: 10_000,
    rails_pulse_operations: 50_000,
    rails_pulse_routes: 1_000,
    rails_pulse_queries: 500
  }
end
# rubocop:enable Metrics/BlockLength

Rails.application.config.after_initialize do
  ActionView::Helpers::UrlHelper.module_eval do
    def link_to(*args, &)
      if respond_to?(:controller) && rails_pulse_controller?
        options = args.extract_options!
        options[:data] ||= {}
        options[:data][:turbo] = false unless options[:data].key?(:turbo)
        args << options
      end
      original_link_to(*args, &)
    end

    private

    def rails_pulse_controller?
      controller_name = controller&.class&.name
      controller_name&.start_with?('RailsPulse::')
    end
  end
end
