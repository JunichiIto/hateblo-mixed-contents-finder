require './lib/invalid_content'

class ElementValidator
  attr_reader :tag, :attr, :root

  def initialize(tag, attr, root)
    @tag = tag
    @attr = attr
    @root = root
  end

  def validate(page)
    entry_title = find_entry_title(page)
    entry_id = find_entry_id(page)
    nodes = page.search("#{root} #{tag}")
    nodes.map { |node|
      link_url = node[attr].to_s
      if link_url.include?('http:') && target?(tag, node)
        InvalidContent.new(page.uri, entry_id, entry_title, tag, attr, link_url)
      end
    }.compact
  end

  private

  def target?(tag, node)
    tag != 'link' || (tag == 'link' && node['rel'] == 'stylesheet')
  end

  def find_entry_title(page)
    page.search('.entry-title')[0].text.strip
  end

  def find_entry_id(page)
    page.search('article.entry')[0]['data-uuid']
  end
end