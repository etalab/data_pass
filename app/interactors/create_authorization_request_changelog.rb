class CreateAuthorizationRequestChangelog < ApplicationInteractor
  def call
    if authorization_request.changelogs.empty?
      create_initial_changelog
    else
      create_changelog_with_diff
    end
  end

  private

  def create_initial_changelog
    create_changelog(
      authorization_request.data.transform_values { |v| [nil, v] }
    )
  end

  def create_changelog_with_diff
    create_changelog(
      reified_data.each_with_object({}) do |(key, old_value), diff|
        next if authorization_request.data[key] == old_value

        diff[key] = [old_value, authorization_request.data[key]]
      end
    )
  end

  def reified_data
    @reified_data ||= latest_changelog.diff.each_with_object(authorization_request.data.dup) do |(key, value), latest_data|
      latest_data[key] = value[1]
    end
  end

  def latest_changelog
    @latest_changelog ||= authorization_request.changelogs.last
  end

  def create_changelog(diff)
    context.changelog = authorization_request.changelogs.create!(
      diff:
    )
  end

  def authorization_request
    context.authorization_request
  end
end
