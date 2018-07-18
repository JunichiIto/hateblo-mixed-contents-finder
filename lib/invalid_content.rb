class InvalidContent
  attr_reader :page_url, :entry_id, :entry_title, :tag, :attr, :link_url

  def initialize(page_url, entry_id, entry_title, tag, attr, link_url)
    @page_url = page_url.to_s
    @entry_id = entry_id
    @entry_title = entry_title
    @tag = tag
    @attr = attr
    @link_url = link_url
  end

  def to_s
    [page_url, entry_id, entry_title, tag, attr, link_url].join("\t")
  end
end