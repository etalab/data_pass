module StatsHelper
  MIN_DURATION_THRESHOLD = 60

  def format_duration_seconds(seconds)
    return nil unless seconds

    clamped_seconds = [seconds, MIN_DURATION_THRESHOLD].max
    parts = build_duration_parts(clamped_seconds)
    return 'quelques secondes' if parts.empty?

    parts.join(' ')
  end

  def format_duration_range(median_seconds, stddev_seconds)
    return 'de quelques secondes à quelques jours' unless median_seconds && stddev_seconds

    calculated_min = median_seconds - stddev_seconds
    max_seconds = [median_seconds + stddev_seconds, MIN_DURATION_THRESHOLD].max

    min_formatted = format_lower_bound(median_seconds, calculated_min)
    max_formatted = format_duration_seconds(max_seconds)

    "de #{min_formatted} à #{max_formatted}"
  end

  private

  def format_lower_bound(median_seconds, calculated_min)
    median_days = median_seconds / 86_400.0

    realistic_floor = if median_days >= 7
                        3600
                      elsif median_days >= 1
                        1800
                      elsif median_seconds >= 3600
                        600
                      else
                        MIN_DURATION_THRESHOLD
                      end

    if calculated_min >= realistic_floor
      format_duration_seconds(calculated_min)
    elsif median_days >= 7
      'quelques jours'
    elsif median_days >= 1
      'quelques heures'
    else
      'quelques minutes'
    end
  end

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
