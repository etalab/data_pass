module StatsHelper
  MIN_DURATION_THRESHOLD = 60

  def format_duration_seconds(seconds)
    return nil unless seconds

    clamped_seconds = [seconds, MIN_DURATION_THRESHOLD].max
    parts = build_duration_parts(clamped_seconds)
    return 'quelques secondes' if parts.empty?

    parts.join(' ')
  end

  private

  def build_duration_parts(seconds)
    return [] if seconds.zero?

    days, remaining = extract_days(seconds)
    hours, remaining = extract_hours(remaining)
    minutes, remaining_seconds = extract_minutes(remaining)

    if days.positive?
      [pluralize_unit(days, 'jour')]
    elsif hours.positive?
      [pluralize_unit(hours, 'heure')]
    elsif minutes.positive?
      [pluralize_unit(minutes, 'minute')]
    elsif remaining_seconds.positive?
      [pluralize_unit(remaining_seconds.round, 'seconde')]
    else
      []
    end
  end

  def extract_days(seconds)
    days = (seconds / 86_400).floor
    [days, seconds % 86_400]
  end

  def extract_hours(seconds)
    hours = (seconds / 3600).floor
    [hours, seconds % 3600]
  end

  def extract_minutes(seconds)
    minutes = (seconds / 60).floor
    [minutes, seconds % 60]
  end

  def pluralize_unit(count, unit)
    "#{count} #{unit}#{'s' if count > 1}"
  end
end
