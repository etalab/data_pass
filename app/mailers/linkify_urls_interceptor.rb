class LinkifyUrlsInterceptor
  URL_PATTERN = %r{https?://[^\s<>"']+}

  class << self
    def delivering_email(mail)
      return unless mail.html_part

      mail.html_part.body = linkify_html(mail.html_part.body.decoded)
    end

    def linkify_html(html)
      doc = Nokogiri::HTML(html)
      linkify_text_nodes(doc)
      doc.to_html
    end

    private

    def linkify_text_nodes(doc)
      doc.xpath('//text()[not(ancestor::a)]').each do |node|
        next unless node.content.match?(URL_PATTERN)

        node.replace(Nokogiri::HTML::DocumentFragment.parse(linkify_content(node.content)))
      end
    end

    def linkify_content(content)
      result = +''
      remaining = content

      while (match = URL_PATTERN.match(remaining))
        result << CGI.escapeHTML(remaining[0...match.begin(0)])
        result << anchor_tag_for(match[0])
        remaining = remaining[match.end(0)..]
      end
      result << CGI.escapeHTML(remaining)
      result
    end

    def anchor_tag_for(full_url)
      url = full_url.sub(/[.,!?:)]+$/, '')
      trailing = CGI.escapeHTML(full_url[url.length..])
      href = CGI.escapeHTML(url)
      %(<a href="#{href}" target="_blank" rel="noopener noreferrer">#{href}</a>#{trailing})
    end
  end
end
