class Atoms::PublicRegistry::EntriesCountComponent < ApplicationComponent
  def initialize(count:, query: nil)
    @count = count
    @query = query
  end

  def call
    tag.p(safe_join([tag.strong(entries), ' ', context]), class: 'fr-mb-2w')
  end

  private

  attr_reader :count, :query

  def entries
    t('.entries', count:, formatted_count: number_with_delimiter(count))
  end

  def context
    query.present? ? t('.for_query', query:) : t('.in_registry')
  end
end
