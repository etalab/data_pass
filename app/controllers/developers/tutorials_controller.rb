class Developers::TutorialsController < DevelopersController
  allow_unauthenticated_access

  TUTORIALS = {
    'lecture' => 'lecture.md',
    'ecriture' => 'ecriture.md',
    'webhooks' => 'webhooks.md'
  }.freeze

  def index; end

  def show
    filename = TUTORIALS.fetch(params[:slug]) { raise ActionController::RoutingError, 'Not Found' }
    @slug = params[:slug]
    @html_content = MarkdownRenderer.new(Rails.root.join('docs/developers/tutorials', filename).read).to_html
  end
end
