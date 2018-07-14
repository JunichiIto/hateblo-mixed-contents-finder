class InvalidContent
  def initialize(page_url, entry_title, tag, attr, link_url)
    @page_url = page_url
    @entry_title = entry_title
    @tag = tag
    @attr = attr
    @link_url = link_url
  end

  def to_s
    [@page_url, @entry_title, @tag, @attr, @link_url].join("\t")
  end
end