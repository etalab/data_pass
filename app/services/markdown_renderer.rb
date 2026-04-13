class MarkdownRenderer
  def initialize(content)
    @content = content
  end

  def to_html
    markdown.render(@content).html_safe
  end

  private

  def markdown
    Redcarpet::Markdown.new(renderer, fenced_code_blocks: true, tables: true, autolink: true)
  end

  def renderer
    Redcarpet::Render::HTML.new(with_toc_data: true)
  end
end
