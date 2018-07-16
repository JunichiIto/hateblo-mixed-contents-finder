require './lib/invalid_content'
class ElementValidator
  attr_reader :tag, :attr

  def initialize(tag, attr, root)
    @root = root
    @tag = tag
    @attr = attr
  end

  def validate(page)
    entry_title = find_entry_title(page)
    entry_id = find_entry_id(page)
    nodes = page.search("#{@root} #{tag}")
    nodes.map { |node|
      link_url = node[attr]
      if link_url && link_url.match?(/http:/)
        if tag != 'link' || (tag == 'link' && node['rel'] == 'stylesheet')
          InvalidContent.new(page.uri, entry_id, entry_title, tag, attr, link_url)
        end
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