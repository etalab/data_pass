# frozen_string_literal: true

class INSEECallsPause
  FLAG_KEY = 'insee_calls_pause'
  SKIPPED_CALLS_KEY = 'insee_skipped_calls'
  SKIPPED_CALLS_RETENTION = 7.days

  class << self
    def paused?
      pause_flag = flag

      pause_flag.failsafe(returning: true) { pause_flag.marked? }
    end

    def pause!(duration: default_duration)
      pause_flag = flag

      armed = pause_flag.failsafe(returning: false) do
        pause_flag.mark(expires_in: duration)
        pause_flag.marked?
      end

      report_unreachable_redis('arm') unless armed

      armed
    end

    def reset!
      pause_flag = flag

      released = pause_flag.failsafe(returning: false) do
        pause_flag.remove
        !pause_flag.marked?
      end

      report_unreachable_redis('release') unless released
      skipped_calls.reset

      released
    end

    def record_skipped_call
      skipped_calls.increment
    end

    def skipped_calls_count
      skipped_calls.value
    end

    def default_duration
      Setting.fetch(:insee_calls_pause_duration)
    end

    def flag
      Kredis.flag(FLAG_KEY)
    end

    private

    def skipped_calls
      Kredis.counter(SKIPPED_CALLS_KEY, expires_in: SKIPPED_CALLS_RETENTION)
    end

    def report_unreachable_redis(action)
      message = "INSEECallsPause: unable to #{action} the circuit breaker, Redis is unreachable"

      Sentry.capture_message(message, level: :error)
      Rails.logger.error(message)
    end
  end
end
