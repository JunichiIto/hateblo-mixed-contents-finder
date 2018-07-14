require './lib/invalid_content'
class ElementValidator
  attr_reader :tag, :attr

  def initialize(tag, attr)
    @tag = tag
    @attr = attr
  end

  def validate(page)
    nodes = page.search(".entry-content #{tag}")
    nodes.map { |node|
      link_url = node[attr]
      if link_url && link_url.match?(/^http:/)
        InvalidContent.new(page.uri, tag, attr, link_url)
      end
    }.compact
  end
end