require './lib/invalid_content'
class ElementValidator
  attr_reader :tag, :attr

  def initialize(tag, attr)
    @tag = tag
    @attr = attr
  end

  def validate(page)
    entry_title = find_entry_title(page)
    entry_id = find_entry_id(page)
    nodes = page.search(".entry-content #{tag}")
    nodes.map { |node|
      link_url = node[attr]
      if link_url && link_url.match?(/^http:/)
        InvalidContent.new(page.uri, entry_id, entry_title, tag, attr, link_url)
      end
    }.compact
  end

  def find_entry_title(page)
    page.search('.entry-title')[0].text.strip
  end

  def find_entry_id(page)
    page.search('article.entry')[0]['data-uuid']
  end
end